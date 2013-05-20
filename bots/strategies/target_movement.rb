module Strategies
  module TargetMovement
    def record_target_position!
      return unless target

      if @target_name != target.name
        # new target
        clear_store!(:target_position)
        clear_store!(:target_movement)
        clear_store!(:target_movement_delta)
        @target_name = target.name
      end

      store!(:target_position, calculate_position(sensors.position, target.heading, target.distance))
      if target_last_position
        store!(:target_movement, [RTanque::Heading.new_between_points(target_last_position, target_position), target_last_position.distance(target_position)])
        if last_movement_vector
          store!(:target_movement_delta, [this_movement_vector[0].delta(last_movement_vector[0]), this_movement_vector[1] - last_movement_vector[0]])
        end
      end
    end

    def target_position
      fetch(:target_position)
    end

    def target_last_position
      fetch_relative(:target_position, -1)
    end

    def movement_type
      if moving_linearly?
        return :linear
      elsif moving_circularly?
        return :circular
      else
        return :erratic
      end
    end

    def last_movement_vector
      fetch_relative(:target_movement, -1)
    end

    def this_movement_vector
      fetch(:target_movement)
    end

    def last_movement_vector_delta
      fetch_relative(:target_movement_delta, -1)
    end

    def this_movement_vector_delta
      fetch(:target_movement_delta)
    end

    def moving_linearly?
      this_movement_vector_delta && this_movement_vector_delta[0] < RTanque::Heading::ONE_DEGREE
    end

    def moving_circularly?
      if this_movement_vector_delta && last_movement_vector_delta
        (this_movement_vector_delta[0] - last_movement_vector_delta[0]).abs < 0.001
      end
    end
  end
end
