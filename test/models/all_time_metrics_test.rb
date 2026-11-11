require 'test_helper'

class AllTimeMetricsTest < ActiveSupport::TestCase
  # Two draws in 2029 (a €50 prize) and two in 2030 (a €4 prize), two users
  # charged €2 each per draw. The fixtures add a prizeless week in 2015.
  setup do
    Transaction.delete_all # the fixtures' 2015 payments would count too
    @one, @two = users(:one), users(:two)
    { "2029-03-02" => 0.0, "2029-03-09" => 50.0, "2030-01-04" => 0.0, "2030-01-11" => 4.0 }
      .each_with_index do |(friday, prize), i|
        week = Week.create!(number: 200 + i, friday: friday.to_date, prize: prize)
        [@one, @two].each do |user|
          Transaction.create!(user: user, value: Bet::BET_COST, kind: TransactionKind::BET,
                              date: week.friday - 4, details: "Bet for week #{week.number}")
        end
      end
    [["2029-04-01", 12.0], ["2030-01-20", 8.0]].each do |date, value|
      Transaction.create!(user: @one, value: value, kind: TransactionKind::PAYMENT,
                          date: date.to_date, details: "Transfer")
    end
    @metrics = AllTimeMetrics.new
  end

  test "totals over every year" do
    assert_in_delta 16.0, @metrics.spent
    assert_in_delta 54.0, @metrics.won
    assert_equal 8, @metrics.bets
    assert_equal 2, @metrics.winning_weeks.size
    assert_equal @metrics.by_year.sum { |year| year.weeks.size }, @metrics.weeks.size
  end

  test "compares the years that had draws, newest first" do
    assert_equal [2030, 2029, weeks(:one).friday.year], @metrics.by_year.map(&:year)
    assert_equal 2029, @metrics.best_year.year
    assert_equal 2030, @metrics.worst_year.year
  end

  test "biggest prizes ever, biggest first" do
    assert_equal [50.0, 4.0], @metrics.top_wins.map(&:won)
    assert_equal "2029-03-09".to_date, @metrics.biggest_win.friday
  end

  test "payment gaps span the years" do
    person = @metrics.people.find { |p| p.user == @one }
    assert_in_delta 20.0, person.paid
    assert_in_delta 294.0, person.days_between_payments # 01/04/2029 -> 20/01/2030
  end
end
