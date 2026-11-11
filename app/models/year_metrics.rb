# The numbers behind the Metrics page: how one year of betting went.
#
# A year is the set of weeks whose Friday draw falls in it. Bet charges belong
# to the week they paid for (weeks run Saturday to Friday, see
# config.beginning_of_week), so the Monday charge on 29/12 for the draw on
# Friday 2/1 counts in the new year. Prize shares are counted on the day they
# were credited, as they appear in each person's transactions, and so are the
# payments people send in to top up their balance.
class YearMetrics
  # Winning weeks are grouped by how many weeks of bet charges their prize
  # paid back, i.e. the prize divided by what was charged for that week.
  PRIZE_TIERS = {
    less_than_its_week: 0...1,
    one_to_three_weeks: 1...4,
    four_to_twelve_weeks: 4...13,
    thirteen_weeks_or_more: 13..
  }.freeze

  DrawWeek = Data.define(:friday, :week, :bets, :spent, :won) do
    def won? = won.positive?
    def net = won - spent
    # 1 for the first Friday of the month, up to 5 for a fifth one.
    def friday_of_month = (friday.day - 1) / 7 + 1
    # Reads the stored filename, so it doesn't check the upload on disk for every week.
    def bet_slip? = week&.weeks_bet_identifier.present?
  end

  # payments: [date, value] pairs in date order. last_payment_before: the date
  # of their last payment before this year, so a gap can span the new year.
  Person = Data.define(:user, :bets, :spent, :won, :payments, :last_payment_before) do
    def net = won - spent
    def return_rate = spent.positive? ? won / spent : nil
    def paid = payments.sum(0.0) { |_date, value| value }
    def last_payment = payments.last&.first
    # How much of the year's bet charges their payments covered.
    def coverage = spent.positive? ? paid / spent : nil

    # Average number of days between one payment and the next.
    def days_between_payments
      dates = [last_payment_before, *payments.map(&:first)].compact
      (dates.last - dates.first).fdiv(dates.size - 1) if dates.size > 1
    end
  end

  # A group of draw weeks: a month, a Friday of the month, or a whole year.
  class Period
    attr_reader :weeks

    def initialize(weeks)
      @weeks = weeks
    end

    def spent = weeks.sum(0.0, &:spent)
    def won = weeks.sum(0.0, &:won)
    def net = won - spent
    def bets = weeks.sum(&:bets)
    def return_rate = spent.positive? ? won / spent : nil
    def winning_weeks = weeks.select(&:won?)
    def hit_rate = weeks.any? ? winning_weeks.size.fdiv(weeks.size) : nil
    def bet_slips = weeks.count(&:bet_slip?)
  end

  # Consecutive draw weeks: a winning streak or a run without prizes.
  Run = Data.define(:weeks) do
    def length = weeks.size
    def from = weeks.first.friday
    def to = weeks.last.friday
    def won = weeks.sum(0.0, &:won)
  end

  attr_reader :year

  # Every year from the first draw or bet charge to the last one, newest first.
  def self.years
    dates = [Week.minimum(:friday), Week.maximum(:friday),
             bet_charges.minimum(:date), bet_charges.maximum(:date)].compact
    return [] if dates.empty?

    first, last = dates.map { |date| date.end_of_week.year }.minmax
    last.downto(first).to_a
  end

  def self.bet_charges
    Transaction.where(kind: TransactionKind::BET)
  end

  def initialize(year)
    @year = year
  end

  # From the Saturday that starts the year's first draw week to its last Friday.
  def window
    @window ||= Date.new(year).beginning_of_week..(Date.new(year + 1).beginning_of_week - 1)
  end

  def weeks
    @weeks ||= begin
      records = Week.where(friday: window).group_by { |week| week.friday.end_of_week }
      charged = charges.group_by { |_user_id, date, _value| date.end_of_week }

      (records.keys | charged.keys).sort.map do |friday|
        DrawWeek.new(
          friday: friday,
          week: records[friday]&.first,
          bets: charged.fetch(friday, []).size,
          spent: -charged.fetch(friday, []).sum(0.0) { |_user_id, _date, value| value },
          won: records.fetch(friday, []).sum(0.0) { |week| week.prize.to_f }
        )
      end
    end
  end

  def totals
    @totals ||= Period.new(weeks)
  end

  delegate :spent, :won, :net, :bets, :return_rate, :winning_weeks, :hit_rate, to: :totals

  def empty? = weeks.empty?

  def biggest_win = winning_weeks.max_by(&:won)

  def average_win = winning_weeks.any? ? won / winning_weeks.size : nil

  # How many draws, on average, between two winning weeks.
  def weeks_per_win = winning_weeks.any? ? weeks.size.fdiv(winning_weeks.size) : nil

  # Running totals after each draw week, for the cumulative chart.
  def running_totals
    spent = won = 0.0
    weeks.map do |week|
      spent += week.spent
      won += week.won
      { friday: week.friday, spent: spent, won: won }
    end
  end

  # Month number (1-12) => Period, for the months that had draws.
  def months
    weeks.group_by { |week| week.friday.month }.transform_values { |weeks| Period.new(weeks) }
  end

  # 1..5 => Period. Everyone is charged every week but the bets are placed once
  # a month, so this shows whether prizes fall evenly across the month.
  def fridays_of_month
    weeks.group_by(&:friday_of_month).sort.to_h.transform_values { |weeks| Period.new(weeks) }
  end

  # Tier name => number of winning weeks, in PRIZE_TIERS order.
  def prize_tiers
    weekly_cost = spent / weeks.count { |week| week.spent.positive? } if spent.positive?
    counts = PRIZE_TIERS.transform_values { 0 }

    winning_weeks.each do |week|
      cost = week.spent.positive? ? week.spent : weekly_cost
      next unless cost

      weeks_paid = (week.won / cost).floor
      tier, _range = PRIZE_TIERS.find { |_tier, range| range.cover?(weeks_paid) }
      counts[tier] += 1
    end
    counts
  end

  # The longest run of consecutive draw weeks without a prize, if any.
  def longest_dry_spell = longest_run { |week| !week.won? }

  # The longest run of consecutive winning weeks, if any. The earliest one on a tie.
  def longest_winning_streak = longest_run(&:won?)

  def people
    @people ||= begin
      charged = charges.group_by(&:first)
      shares = Transaction.where(kind: TransactionKind::PRIZE, date: calendar_year)
                          .group(:user_id).sum(:value)
      paid = payments.group_by(&:first)
      paid_before = Transaction.where(kind: TransactionKind::PAYMENT, date: ...calendar_year.begin)
                               .group(:user_id).maximum(:date)

      User.where(id: charged.keys | shares.keys | paid.keys).order(:name).map do |user|
        user_charges = charged.fetch(user.id, [])
        Person.new(
          user: user,
          bets: user_charges.size,
          spent: -user_charges.sum(0.0) { |_user_id, _date, value| value },
          won: shares.fetch(user.id, 0.0),
          payments: paid.fetch(user.id, []).map { |_user_id, date, value| [date, value] },
          last_payment_before: paid_before[user.id]
        )
      end
    end
  end

  # Money people sent in to top up their balance during the year.
  def paid = payments.sum(0.0) { |_user_id, _date, value| value }

  def payment_count = payments.size

  # Month number (1-12) => amount paid in that month.
  def paid_by_month
    payments.group_by { |_user_id, date, _value| date.month }
            .transform_values { |rows| rows.sum(0.0) { |_user_id, _date, value| value } }
  end

  # Payments are counted by the day they were recorded, January to December.
  def calendar_year = Date.new(year).all_year

  private

  def longest_run(&matches)
    runs = weeks.chunk_while { |a, b| matches.(a) && matches.(b) }.select { |run| matches.(run.first) }
    longest = runs.max_by(&:size)
    Run.new(weeks: longest) if longest
  end

  # [user_id, date, value] for every payment in the calendar year, oldest first.
  def payments
    @payments ||= Transaction.where(kind: TransactionKind::PAYMENT, date: calendar_year)
                             .order(:date, :id).pluck(:user_id, :date, :value)
  end

  # [user_id, date, value] for every bet charge in the year's draw weeks.
  def charges
    @charges ||= self.class.bet_charges.where(date: window).pluck(:user_id, :date, :value)
  end
end
