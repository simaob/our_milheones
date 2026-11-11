module MetricsHelper
  PRIZE_TIER_LABELS = {
    less_than_its_week: "Less than a week",
    one_to_three_weeks: "1 to 3 weeks",
    four_to_twelve_weeks: "4 to 12 weeks",
    thirteen_weeks_or_more: "13 weeks or more"
  }.freeze

  # €1,234.50, or −€12.00. With signed: true positive amounts get a "+".
  def euros(amount, signed: false)
    text = number_to_currency(amount.to_f.abs, unit: "€", format: "%u%n")
    if amount.to_f.round(2).negative? then "−#{text}"
    elsif signed && amount.to_f.round(2).positive? then "+#{text}"
    else text
    end
  end

  def net_class(amount)
    rounded = amount.to_f.round(2)
    if rounded.positive? then "text-success"
    elsif rounded.negative? then "text-danger"
    end
  end

  # 0.25 is "25%", -0.75 is "−75%". With signed: true gains get a "+".
  def percent(ratio, signed: false)
    return "—" unless ratio

    rounded = (ratio * 100).round
    text = "#{rounded.abs}%"
    if rounded.negative? then "−#{text}"
    elsif signed && rounded.positive? then "+#{text}"
    else text
    end
  end

  # A return as a signed, coloured percentage: "+5%" in green, "−75%" in red.
  def return_tag(ratio, tag_name = :span, **options)
    content_tag(tag_name, percent(ratio, signed: true),
                **options, class: [options[:class], (net_class(ratio) if ratio)].compact.join(" ").presence)
  end

  # Round axis ticks from 0 that cover max: [0, 50, 100, 150].
  def chart_ticks(max, count: 4)
    return [0, 1] unless max.to_f.positive?

    raw = max.to_f / count
    magnitude = 10.0**Math.log10(raw).floor
    step = [1, 2, 2.5, 5, 10].map { |m| m * magnitude }.find { |s| s >= raw }
    (0..(max.to_f / step).ceil).map { |i| (i * step).round(2) }
  end

  # Position of value on a 0..max scale, as a CSS percentage.
  def chart_pct(value, max)
    max.to_f.positive? ? "#{(value.to_f / max * 100).round(3)}%" : "0%"
  end

  # Index of the first week of each month: { 0 => "Jan", 4 => "Feb", ... }
  def month_starts(weeks)
    weeks.each_with_index.chunk_while { |(a, _), (b, _)| a.friday.month == b.friday.month }
         .to_h { |run| [run.first.last, run.first.first.friday.strftime("%b")] }
  end

  # Index of the first week of each year: { 0 => "2015", 47 => "2016", ... }
  def year_starts(weeks)
    weeks.each_with_index.chunk_while { |(a, _), (b, _)| a.friday.year == b.friday.year }
         .to_h { |run| [run.first.last, run.first.first.friday.year.to_s] }
  end
end
