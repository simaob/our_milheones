require 'test_helper'

class YearMetricsTest < ActiveSupport::TestCase
  # Six draws in 2030, two users charged €2 each every Monday. Prizes of €10 on
  # 11/01 and €60 on 25/01, split between the two users the next day.
  FRIDAYS = %w[2030-01-04 2030-01-11 2030-01-18 2030-01-25 2030-02-01 2030-02-08].map(&:to_date)
  PRIZES = { "2030-01-11".to_date => 10.0, "2030-01-25".to_date => 60.0 }

  setup do
    @users = [users(:one), users(:two)]
    FRIDAYS.each_with_index do |friday, i|
      week = Week.create!(number: 100 + i, friday: friday, prize: PRIZES.fetch(friday, 0.0))
      @users.each do |user|
        # The Monday before the Friday; the first one is Monday 31/12/2029.
        Transaction.create!(user: user, value: Bet::BET_COST, kind: TransactionKind::BET,
                            date: friday - 4, details: "Bet for week #{week.number}")
        next unless week.prize.positive?
        Transaction.create!(user: user, value: week.prize / 2, kind: TransactionKind::PRIZE,
                            date: friday + 1, details: "Prize for week #{week.number}")
      end
    end
    @metrics = YearMetrics.new(2030)
  end

  test "totals for the year" do
    assert_equal FRIDAYS, @metrics.weeks.map(&:friday)
    assert_equal 12, @metrics.bets
    assert_in_delta 24.0, @metrics.spent
    assert_in_delta 70.0, @metrics.won
    assert_in_delta 46.0, @metrics.net
    assert_in_delta 46.0 / 24, @metrics.return_rate # €70 back on €24 bet: +192%
    assert_equal 2, @metrics.winning_weeks.size
    assert_in_delta 3.0, @metrics.weeks_per_win
    assert_in_delta 35.0, @metrics.average_win
    assert_equal "2030-01-25".to_date, @metrics.biggest_win.friday
  end

  test "a Monday charge in late December counts for the next year's first draw" do
    assert_in_delta 4.0, @metrics.weeks.first.spent
    assert_equal 0, YearMetrics.new(2029).bets
    assert YearMetrics.new(2029).empty?
  end

  test "years run from the first draw to the last, newest first" do
    years = YearMetrics.years
    assert_equal 2030, years.first
    assert_equal weeks(:one).friday.year, years.last
    assert_equal years.first.downto(years.last).to_a, years
  end

  test "each person's bets, spending and prize share" do
    people = @metrics.people
    assert_equal @users.map(&:id).sort, people.map { |p| p.user.id }.sort
    people.each do |person|
      assert_equal 6, person.bets
      assert_in_delta 12.0, person.spent
      assert_in_delta 35.0, person.won
      assert_in_delta 23.0, person.net
    end
  end

  test "groups winning weeks by how many weeks of charges they paid back" do
    # €10 against €4 of charges is 2.5 weeks, €60 is 15 weeks.
    assert_equal({ less_than_its_week: 0, one_to_three_weeks: 1,
                   four_to_twelve_weeks: 0, thirteen_weeks_or_more: 1 },
                 @metrics.prize_tiers)
  end

  test "longest run of draws without a prize" do
    spell = @metrics.longest_dry_spell
    assert_equal 2, spell.length
    assert_equal "2030-02-01".to_date, spell.from
    assert_equal "2030-02-08".to_date, spell.to
  end

  test "best winning streak" do
    # Prizes on 11/01 and 25/01 only: the streaks are one week long, the earliest wins the tie.
    streak = @metrics.longest_winning_streak
    assert_equal 1, streak.length
    assert_equal "2030-01-11".to_date, streak.from

    Week.find_by!(friday: "2030-01-18".to_date).update!(prize: 5.0)
    streak = YearMetrics.new(2030).longest_winning_streak
    assert_equal 3, streak.length
    assert_equal "2030-01-11".to_date, streak.from
    assert_equal "2030-01-25".to_date, streak.to
    assert_in_delta 75.0, streak.won
  end

  test "splits the draws by month and by Friday of the month" do
    assert_equal [1, 2], @metrics.months.keys
    assert_in_delta 70.0, @metrics.months[1].won
    assert_in_delta 8.0, @metrics.months[2].spent

    fridays = @metrics.fridays_of_month
    assert_equal [1, 2, 3, 4], fridays.keys
    assert_equal [2, 2, 1, 1], fridays.values.map { |period| period.weeks.size }
    assert_equal [0, 1, 0, 1], fridays.values.map { |period| period.winning_weeks.size }
  end

  test "running totals end at the year's totals" do
    last = @metrics.running_totals.last
    assert_equal FRIDAYS.last, last[:friday]
    assert_in_delta 24.0, last[:spent]
    assert_in_delta 70.0, last[:won]
  end

  test "payments: how much, how often and how much of the bets they covered" do
    one, two = users(:one), users(:two)
    pay = ->(user, date, value) {
      Transaction.create!(user: user, value: value, kind: TransactionKind::PAYMENT,
                          date: date.to_date, details: "Transfer")
    }
    pay.(one, "2029-11-20", 30.0) # before the year: only starts the first gap
    pay.(one, "2030-01-15", 10.0)
    pay.(one, "2030-03-16", 10.0)
    pay.(two, "2030-02-01", 24.0)
    metrics = YearMetrics.new(2030)

    assert_equal 3, metrics.payment_count
    assert_in_delta 44.0, metrics.paid
    assert_equal({ 1 => 10.0, 2 => 24.0, 3 => 10.0 }, metrics.paid_by_month)

    first, second = metrics.people.find { |p| p.user == one }, metrics.people.find { |p| p.user == two }
    assert_equal ["2030-01-15".to_date, "2030-03-16".to_date], first.payments.map(&:first)
    assert_in_delta 20.0, first.paid
    assert_in_delta 20.0 / 12, first.coverage
    assert_equal "2030-03-16".to_date, first.last_payment
    # 20/11 -> 15/01 is 56 days, 15/01 -> 16/03 is 60.
    assert_in_delta 58.0, first.days_between_payments
    assert_nil second.days_between_payments
    assert_in_delta 2.0, second.coverage
  end

  test "a year without draws" do
    metrics = YearMetrics.new(1999)
    assert metrics.empty?
    assert_nil metrics.return_rate
    assert_nil metrics.longest_dry_spell
    assert_nil metrics.longest_winning_streak
    assert_empty metrics.people
  end
end
