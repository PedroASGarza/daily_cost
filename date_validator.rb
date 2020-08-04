require 'date'
require 'pry'

class DateValidator
  attr_reader :errors

  def initialize(params = {})
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @errors = []
  end

  def validate
    date_range_is_present?
    date_range_is_valid?
  end

  private

  def date_range_is_present?
    return if @start_date.is_a?(Date) && @end_date.is_a?(Date)

    @errors << { date_range: "Date range is not valid" }
  end

  def date_range_is_valid?
    return unless @end_date < @start_date

    @errors << { date_range: "End date should be further ahead than start date" }
  end
end
