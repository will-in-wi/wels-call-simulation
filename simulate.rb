# frozen_string_literal: true

# This system makes the poor assumption that a month is 30 days.
MONTH = 30

# Config params
CALL_ACCEPTANCE_PROBABILITY = 0.2 # 0.2 would be a 20% chance of accepting the call.
DAYS_BETWEEN_CALLS_POST_ACCEPTANCE = MONTH*12*4 # 4 years
DAYS_BETWEEN_CALLS_POST_RETURN = MONTH*6 # Six months
CALL_DURATION = MONTH
CALL_DEVIATION = 14 # Plus or minus variation from the CALL_DURATION

NUMBER_OF_PARISHES = 1150 # Stolen from Wikipedia
GAP_PERCENTAGE = 0.07 # 0.07 would mean 7% fewer pastors than parishes.
NUMBER_OF_PASTORS = (NUMBER_OF_PARISHES * (1 - GAP_PERCENTAGE)).to_i

require 'colorize'

require_relative './lib/action_taken'
require_relative './lib/pastor'
require_relative './lib/parish'
require_relative './lib/district_president'

# puts "Beginning simulation with a #{NUMBER_OF_PARISHES.to_f / NUMBER_OF_PASTORS.to_f - 1}% gap between pastors and positions."

pastors = NUMBER_OF_PASTORS.times.to_a.map { |i| Pastor.new "Pastor #{i}" }
district_president = DistrictPresident.new pastors
parishes = NUMBER_OF_PARISHES.times.to_a.map { |i| Parish.new "Parish #{i}", district_president }

# puts

# puts 'Assignment day!!!'
pastors.shuffle.zip(parishes.shuffle).each do |tuple|
  pastor, parish = tuple
  # puts "#{pastor} assigned to #{parish}"
  pastor.assign(parish)
end

day = 1

loop do
  # puts

  pastor_statuses = pastors.shuffle.map(&:tick).compact

  # puts 'Call report'
  pastor_statuses.each do |status|
    # puts "#{status.pastor}, presently serving at #{status.origin}, #{status.type} a call to #{status.destination}"
  end
  # puts 'End of call report'

  parishes.shuffle.each(&:tick)

  if day % 10 == 0
    # puts "Statistics report for day #{day}"
    average_lifetime_calls = pastors.map(&:lifetime_calls).inject(0, :+).to_f / pastors.size.to_f
    # puts "Average number of lifetime calls: #{average_lifetime_calls}"
    min, max = pastors.minmax_by(&:lifetime_calls)
    # puts "Maximum number of lifetime calls: #{max.lifetime_calls}"
    # puts "Minimum number of lifetime calls: #{min.lifetime_calls}"
    # puts "Vacancy number: #{parishes.count(&:vacant?)}"
  end

  # Parish visualization
  if day % 30 == 0
    system('clear')
    puts "Day: #{day}"
    puts 'Parishes:'
    parishes.each do |parish|
      case parish.status
      when :filled
        print '█'.green
      when :calling
        print '█'.yellow
      when :empty
        print '█'.red
      end
    end
    puts
    puts 'Pastors:'
    pastors.each do |pastor|
      case pastor.state
      when :is_holding
        print '█'.blue
      when :available
        if pastor.next_action > 0
          print '█'.yellow
        else
          print '█'.green
        end
      end
    end
    puts
    average_lifetime_calls = pastors.map(&:lifetime_calls).inject(0, :+).to_f / pastors.size.to_f
    puts "Average number of lifetime calls: #{average_lifetime_calls}"
    min, max = pastors.minmax_by(&:lifetime_calls)
    puts "Maximum number of lifetime calls: #{max.lifetime_calls}"
    puts "Minimum number of lifetime calls: #{min.lifetime_calls}"
    puts "Vacancy number: #{parishes.count(&:vacant?)}"
  end

  # puts "End of day #{day}"

  # sleep 10
  day += 1

  break if day > 10000
end
