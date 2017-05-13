# frozen_string_literal: true

class ActionTaken
  attr_reader :type, :origin, :destination, :pastor
  def initialize(type, origin, destination, pastor)
    @type = type
    @origin = origin
    @destination = destination
    @pastor = pastor
  end
end
