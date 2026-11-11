class MetricsController < ApplicationController
  before_action :set_years

  # GET /metrics, GET /metrics/2025
  def show
    year = params[:year]&.to_i || @years.first || Date.current.year
    @metrics = YearMetrics.new(year)
    @all_years = @years.map { |y| y == year ? @metrics : YearMetrics.new(y) }
  end

  # GET /metrics/all
  def all_time
    @metrics = AllTimeMetrics.new
  end

  private

  def set_years
    @years = YearMetrics.years
  end
end
