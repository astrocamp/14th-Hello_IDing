# frozen_string_literal: true

class RestaurantsController < ApplicationController
  before_action :set_restaurant, :set_holidays, :set_timelist, :set_daylist, only: [:show]

  def index
    @restaurants = Restaurant.order(:id)
  end

  def show
    @open_time = @restaurant.open_times.order(start_time: :asc)
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  # TimeRange
  def time_slot
    @time_period = @restaurant.open_times.reduce([]) { |arr, time| arr.push(time.start_time.to_i..time.end_time.to_i) }
  end

  def set_timelist
    time_slot
    @timerange = @time_period.each_with_object([]) do |time, arr|
      time.step(@restaurant.reserve_interval.minutes) { |t| arr.push(Time.at(t).utc.strftime('%R')) }
    end
  end

  # DateRange
  def set_holidays
    @holidays = @restaurant.holidays.where.not(dayoff: nil).pluck(:dayoff)
  end

  def set_daylist
    @end_day = Date.today + @restaurant.bookday_advance.days
    @daterange = (Date.today..@end_day).select { |date| @holidays.exclude?(date.strftime('%a')) }
  end
end
