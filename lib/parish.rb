# frozen_string_literal: true

class Parish
  attr_reader :pastor, :name

  def initialize(name, district_president)
    @name = name
    @pastor = nil
    @called_pastor = nil
    @district_president = district_president
    @time_till_next_call = 0
  end

  def lose_pastor
    @pastor = nil
  end

  def receive_returned_call
    @called_pastor = nil
  end

  def receive_accepted_call
    @pastor = @called_pastor
    @called_pastor = nil
  end

  def receive_assignment(pastor)
    @pastor = pastor
  end

  def tick
    raise 'misassigned pastor' if @pastor && @pastor.parish != self

    return unless @pastor.nil?
    return unless @called_pastor.nil?

    call_meeting
  end

  def vacant?
    @pastor.nil?
  end

  def status
    if !@pastor.nil?
      :filled
    elsif !@called_pastor.nil?
      :calling
    else
      :empty
    end
  end

  def to_s
    @name
  end

  private

  def call_meeting
    if @time_till_next_call > 0
      @time_till_next_call -= 1
      return
    end

    # puts "Call meeting for #{@name}!"
    list = @district_president.candidate_list(self)
    if list.empty?
      # Only meet once a week if there are no available candidates.
      @time_till_next_call = 7
      # raise 'No eligible pastors!!!'
      # puts 'No eligible pastors!!! :\'('
      return
    end
    # puts 'List:'
    # list.each { |pastor| puts "* #{pastor.name}" }
    @called_pastor = list.shuffle.first
    # puts "Selected: #{@called_pastor.name}"

    @called_pastor.receive_call(self)
  end
end
