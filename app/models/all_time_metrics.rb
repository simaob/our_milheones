# The whole history at once, for the all-time Metrics page: the same numbers
# as YearMetrics, over every draw and transaction, plus how the years compare.
class AllTimeMetrics < YearMetrics
  EVERYTHING = Date.new(1900)..Date.new(9999, 12, 31)

  def initialize
    super(nil)
  end

  def window = EVERYTHING

  def calendar_year = EVERYTHING

  # One YearMetrics per year with draws, newest first.
  def by_year
    @by_year ||= YearMetrics.years.map { |year| YearMetrics.new(year) }.reject(&:empty?)
  end

  # The years with the best and the worst return (won / spent). Return, not
  # net in euros, so a year with fewer members or one still running isn't
  # penalised for spending less.
  def best_year = ranked_years.last

  def worst_year = ranked_years.first

  # The biggest prizes ever, biggest first.
  def top_wins(count = 5) = winning_weeks.max_by(count, &:won)

  private

  def ranked_years = by_year.select(&:return_rate).sort_by(&:return_rate)
end
