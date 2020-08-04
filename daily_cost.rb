require 'date'
require 'active_support/core_ext'
require 'pry'
require './date_validator'
require './period_costs_validator'

class DailyCost
  attr_reader :errors, :days_costs

  def initialize(params = {})
    @days_costs = []
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @time_period_costs = params[:time_period_costs]
    @errors = []
  end

  def execute
    check_validations
    return if @errors.any?

    daily_cost
  end

  private
  def check_validations
    validate_range_date
    validate_costs_and_periods
  end

  def validate_range_date
    validator = DateValidator.new({ start_date: @start_date,
                                    end_date: @end_date })

    validator.validate
    @errors << validator.errors if validator.errors.any?
  end

  def validate_costs_and_periods
    validator = PeriodCostsValidator.new(@time_period_costs)

    validator.validate
    @errors << validator.errors if validator.errors.any?
  end

  def daily_cost
    (@start_date..@end_date).each do |date|
      @cost = 0
      @time_period_costs.each do |time_period_cost|
        @cost = @cost + add_time_period_cost(time_period_cost, date)
      end
      @days_costs << {date: date, cost: @cost}
    end
  end

  def add_time_period_cost(time_period_cost, date)
    cost = time_period_cost[:cost]
    time_period = time_period_cost[:time_period]

    return cost if time_period == "daily"
    return cost/7 if time_period == "weekly"
    calculate_monthly_cost(cost, date) if time_period == "monthly"
  end

  def calculate_monthly_cost(cost, date)
    cost/date.end_of_month.day
  end
end
