require 'test_helper'

class WeeksControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    sign_in @user
    @week = weeks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:weeks)
  end

  test "index highlights the weeks a bet was made, after members stopped picking bets" do
    with_bet = Week.create!(number: 40, friday: Date.new(2026, 10, 2),
                            weeks_bet: fixture_file_upload("proof.png", "image/png"))
    Week.create!(number: 41, friday: Date.new(2026, 10, 9))

    get :index
    assert_response :success
    assert_select "tr.info", 1
    assert_select "tr.info a.label[href=?]", week_path(with_bet), text: "Bet made"
    # The fixtures' 2015 month keeps the member bets columns, October 2026 doesn't.
    assert_select "th", text: "Your bet", count: 1
    assert_select "th", text: "Bet", count: 1
  end

  test "should show week" do
    get :show, params: { id: @week }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @week }
    assert_response :success
  end

  test "should update week's solution" do
    solution = { numbers: @week.solution['numbers'].join(","),
                 stars: @week.solution['stars'].join(",") }
    patch :update, params: { id: @week, week: { solution: solution } }
    assert_redirected_to week_path(assigns(:week))
  end

  test "should update week's prize" do
    patch :update, params: { id: @week, week: { prize: '20.0' } }
    assert_redirected_to week_path(assigns(:week))
    assert_equal 20.0, assigns(:week).prize
  end
end
