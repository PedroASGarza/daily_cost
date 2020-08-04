require 'rspec/autorun'
require 'pry'
require_relative './daily_cost.rb'

describe DailyCost do
  describe 'succesful attempts' do
    let(:all_time_periods) { %w(daily weekly monthly) }

    it "returns no errors with mixed daily and weekly periods" do
      time_period_costs = [
        {
          time_period: all_time_periods[0], # daily
          cost: 10.0
        },
        {
          time_period: all_time_periods[1], # weekly
          cost: 70.0,
        }
      ]

      params = {
        start_date: Date.new(2019, 10, 1),
        end_date: Date.new(2019, 10, 3),
        time_period_costs: time_period_costs
      }

      daily_cost = DailyCost.new(params)
      daily_cost.execute
      expect(daily_cost.errors).to be_empty
      expect(daily_cost.days_costs.to_s).to eq(
        "[{:date=>Tue, 01 Oct 2019, :cost=>20.0}, {:date=>Wed, 02 Oct 2019," \
        " :cost=>20.0}, {:date=>Thu, 03 Oct 2019, :cost=>20.0}]"
      )
    end

    it "return the right hash with daily period only" do
      time_period_costs = [
        {
          time_period: all_time_periods[0], # daily
          cost: 20.0
        }
      ]

      params = {
        start_date: Date.new(2019, 10, 1),
        end_date: Date.new(2019, 10, 5),
        time_period_costs: time_period_costs
      }

      daily_cost = DailyCost.new(params)
      daily_cost.execute
      expect(daily_cost.errors).to be_empty
      expect(daily_cost.days_costs.to_s).to eq(
        "[{:date=>Tue, 01 Oct 2019, :cost=>20.0}, {:date=>Wed, 02 Oct 2019, "\
        ":cost=>20.0}, {:date=>Thu, 03 Oct 2019, :cost=>20.0}, {:date=>Fri, "\
        "04 Oct 2019, :cost=>20.0}, {:date=>Sat, 05 Oct 2019, :cost=>20.0}]"
      )
    end

    it "return the right hash with a monthly period" do
      time_period_costs = [
        {
          time_period: all_time_periods[2], # monthly
          cost: 300.0
        }
      ]

      params = {
        start_date: Date.new(2019, 10, 1),
        end_date: Date.new(2019, 10, 7),
        time_period_costs: time_period_costs
      }

      # 300.0/31
      daily_cost = DailyCost.new(params)
      daily_cost.execute
      expect(daily_cost.errors).to be_empty
      expect(daily_cost.days_costs.to_s).to eq(
        "[{:date=>Tue, 01 Oct 2019, :cost=>9.67741935483871}, {:date=>Wed, "\
        "02 Oct 2019, :cost=>9.67741935483871}, {:date=>Thu, 03 Oct 2019, "\
        ":cost=>9.67741935483871}, {:date=>Fri, 04 Oct 2019, "\
        ":cost=>9.67741935483871}, {:date=>Sat, 05 Oct 2019, "\
        ":cost=>9.67741935483871}, {:date=>Sun, 06 Oct 2019, "\
        ":cost=>9.67741935483871}, {:date=>Mon, 07 Oct 2019, "\
        ":cost=>9.67741935483871}]"
      )
    end
  end

  describe "with errors" do
    it 'returns invalid time period error' do
      time_periods = %w(dairy wrecky moody)
      time_period_costs = [
        {
          time_period: time_periods[0],
          cost: 300.0
        },
        {
          time_period: time_periods[1],
          cost: 300.0
        },
        {
          time_period: time_periods[2],
          cost: 300.0
        }
      ]

      params = {
        start_date: Date.new(2019, 10, 1),
        end_date: Date.new(2019, 10, 7),
        time_period_costs: time_period_costs
      }
      daily_cost = DailyCost.new(params)
      daily_cost.execute
      expect(daily_cost.errors).not_to be_empty
      expect(daily_cost.errors.to_s)
        .to eq("[[{:time_period=>\"dairy is not a valid period\"}, "\
          "{:time_period=>\"wrecky is not a valid period\"}, "\
          "{:time_period=>\"moody is not a valid period\"}]]")
    end

    it 'returns invalid cost error' do
      time_periods = %w(daily weekly monthly)
      time_period_costs = [
        {
          time_period: time_periods[0],
          cost: "this is text!"
        },
        {
          time_period: time_periods[1],
          cost: nil
        },
        {
          time_period: time_periods[2],
          cost: 300.0
        }
      ]

      params = {
        start_date: Date.new(2019, 10, 1),
        end_date: Date.new(2019, 10, 7),
        time_period_costs: time_period_costs
      }
      daily_cost = DailyCost.new(params)
      daily_cost.execute
      expect(daily_cost.errors).not_to be_empty
      expect(daily_cost.errors.to_s)
        .to eq("[[{:cost=>\"this is text! at line 1 is not a valid entry\"}, "\
          "{:cost=>\" at line 2 is not a valid entry\"}]]")
    end
  end
end
