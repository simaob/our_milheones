require 'test_helper'

class MetricsControllerTest < ActionController::TestCase
  setup do
    @user = users(:two)
    sign_in @user
  end

  test "shows the latest year by default" do
    get :show
    assert_response :success
    assert_equal weeks(:one).friday.year, assigns(:metrics).year
  end

  test "shows a year's totals and everyone's share" do
    week = Week.create!(number: 1, friday: Date.new(2030, 1, 4), prize: 30.0)
    [users(:one), users(:two)].each do |user|
      Transaction.create!(user: user, value: Bet::BET_COST, kind: TransactionKind::BET,
                          date: Date.new(2029, 12, 31), details: "Bet")
      Transaction.create!(user: user, value: 15.0, kind: TransactionKind::PRIZE,
                          date: Date.new(2030, 1, 5), details: "Prize")
    end
    Transaction.create!(user: users(:two), value: 8.0, kind: TransactionKind::PAYMENT,
                        date: Date.new(2030, 1, 10), details: "Transfer")

    get :show, params: { year: 2030 }
    assert_response :success
    assert_select "h1", /2030 in numbers/
    assert_select ".metric-tile-value", "€4.00"
    assert_select ".metric-tile-value", "+€26.00"
    assert_select "td.num", text: "€15.00", count: 2
    assert_select "a[href=?]", week_path(week)
    assert_select "p", /1 payment totalling €8.00/
    assert_select ".payment-dot", 1
    assert_select ".metrics-years a[href=?]", metrics_path(year: 2015)
  end

  test "shows all time, with the years to compare" do
    Week.create!(number: 1, friday: Date.new(2030, 1, 4), prize: 30.0)
    Transaction.create!(user: users(:one), value: Bet::BET_COST, kind: TransactionKind::BET,
                        date: Date.new(2029, 12, 31), details: "Bet")
    # A bet in the fixtures' prizeless 2015 week.
    Transaction.create!(user: users(:one), value: Bet::BET_COST, kind: TransactionKind::BET,
                        date: weeks(:one).friday, details: "Bet")

    get :all_time
    assert_response :success
    assert_select "h1", /All time/
    assert_select ".metrics-years li.active a[href=?]", all_time_metrics_path
    assert_select ".metric-tile", text: /Best year\s+2030/
    assert_select ".metric-tile", text: /Worst year\s+2015/
    assert_select ".metric-tile", text: /Biggest prize\s+€30.00/
    assert_select ".metric-tile", text: /Best winning streak\s+1 week/
    assert_select "a.chart-slot[href=?]", metrics_path(year: 2030)
  end

  test "all time before anything was bet" do
    Week.delete_all
    get :all_time
    assert_response :success
    assert_select "p.lead", /Nothing has been bet or won yet/
  end

  test "a year without draws" do
    get :show, params: { year: 1999 }
    assert_response :success
    assert_select "p.lead", /Nothing was bet or won in 1999/
  end

  test "needs a signed in user" do
    sign_out @user
    get :show
    assert_redirected_to new_user_session_path
  end
end
