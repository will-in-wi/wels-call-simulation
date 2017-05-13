# frozen_string_literal: true

require 'securerandom'

class Pastor
  attr_reader :parish, :name, :state, :next_action

  def initialize(name)
    @name = name
    @calls_received = []
    @parish = nil
    @state = :available
    @next_action = 0 # Number of days until next action can be taken.
  end

  def lifetime_calls
    @calls_received.size
  end

  def eligible?(potential_parish)
    return :serving_at if @serving_at == potential_parish
    return :previously_called if @calls_received.include?(potential_parish)
    return :holding_or_just_held_call if @next_action > 0

    true
  end

  def assign(parish)
    @calls_received << parish
    @parish = parish
    @parish.receive_assignment(self)
  end

  def receive_call(parish)
    raise 'Already holding call, cannot receive another one!' if @holding_parish
    @state = :is_holding
    @holding_parish = parish
    duration = SecureRandom.random_number(CALL_DEVIATION * 2)
    @next_action = CALL_DURATION + (duration - CALL_DEVIATION)
  end

  def tick
    raise 'Misassigned parish!' if @parish.pastor != self

    @next_action -= 1 unless @next_action == 0

    if @next_action > 0
      if @state == :is_holding
        return ActionTaken.new(:is_holding, @parish, @holding_parish, self)
      else
        return
      end
    end

    case @state
    when :available
      # Noop
    when :is_holding
      if SecureRandom.random_number >= CALL_ACCEPTANCE_PROBABILITY
        # Return call.
        report = ActionTaken.new(:returned, @parish, @holding_parish, self)
        @holding_parish.receive_returned_call
        @calls_received << @holding_parish
        @holding_parish = nil
        @state = :available
        @next_action = DAYS_BETWEEN_CALLS_POST_RETURN
        report
      else
        # Accept call.
        report = ActionTaken.new(:accepted, @parish, @holding_parish, self)
        @parish.lose_pastor
        @holding_parish.receive_accepted_call
        @parish = @holding_parish
        @calls_received << @holding_parish
        @holding_parish = nil
        @state = :available
        @next_action = DAYS_BETWEEN_CALLS_POST_ACCEPTANCE
        report
      end
    end
  end

  def to_s
    @name
  end
end
