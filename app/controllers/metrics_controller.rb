class MetricsController < ApplicationController
  # GET /metrics, GET /metrics/2025
  def show
    @years = YearMetrics.years
    year = params[:year]&.to_i || @years.first || Date.current.year
    @metrics = YearMetrics.new(year)
    @all_years = @years.map { |y| y == year ? @metrics : YearMetrics.new(y) }
  end
end
