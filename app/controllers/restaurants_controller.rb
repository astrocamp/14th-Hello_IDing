# frozen_string_literal: true

class RestaurantsController < ApplicationController
  before_action :set_restaurant, :set_holidays, :set_timelist, :set_daylist, only: [:show]
  before_action :set_restaurant, :time_slot, only: [:filter_timelist]

  def index
    @restaurants = Restaurant.order(id: :desc).page(params[:page])
  end

  def show
    @open_time = @restaurant.open_times.order(:start_time)
  end

  def filter_timelist
    selected_date = params[:date]
    @timerange = []
    reservations = @restaurant.reservations.where(date: selected_date)

    @time_period.map do |time_range|
      time_range.step(@restaurant.reserve_interval.minutes) do |time|
        begin_time = Time.at(time - @restaurant.mealtime.minutes + 1)
        end_time = Time.at(time + @restaurant.mealtime.minutes - 1)
        reservations_count = reservations.where(time: begin_time..end_time).count
        available_tables = @restaurant.tables.count - reservations_count

        @timerange << Time.at(time).strftime('%R') if available_tables.positive?
      end
    end

    @timerange = @timerange.filter { |time| Time.parse(time) > Time.current } if selected_date.to_date == Date.today

    render json: { timerange: @timerange }
  end

  private

  def set_restaurant
    @restaurant = Restaurant.friendly.find(params[:id])
  end

  # TimeRange

  def time_slot
    @time_period = @restaurant.open_times.pluck(:start_time, :end_time)
                              .map { |start_time, end_time| start_time.to_i..end_time.to_i }
                              .sort_by { |range| range&.begin }
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
    @end_day = Date.today + @restaurant.bookday_advance
    @daterange = (Date.today..@end_day).select { |date| @holidays.exclude?(date.strftime('%a')) }
  end
end
