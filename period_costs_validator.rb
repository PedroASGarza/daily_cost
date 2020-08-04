require 'pry'

class PeriodCostsValidator
  attr_reader :errors

  def initialize(time_period_costs)
    @valid_periods = %w(daily weekly monthly)
    @time_period_costs = time_period_costs
    @errors = []
  end

  def validate
    validate_time_periods
    validate_costs
  end

  private
  def validate_time_periods
    time_periods = @time_period_costs.pluck(:time_period)

    time_periods.each_with_index do |time_period, index|
      return if @valid_periods.include?(time_period)

      @errors << {time_period: "#{time_period} is not a valid period"}
    end
  end

  def validate_costs
    @time_period_costs.pluck(:cost).each_with_index do |cost, index|
      return if cost.is_a?(Float) || cost.is_a?(Integer)

      @errors << {cost: "#{cost} at line #{index+1} is not a valid entry"}
    end
  end
end
