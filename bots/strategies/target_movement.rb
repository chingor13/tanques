module Strategies
  module TargetMovement
    def record_target_position!
      return unless target

      if @target_name != target.name
        # new target
        @target_positions = Array.new(10)
        @target_movements = Array.new(10)
        @target_movement_deltas = Array.new(10)
        @target_name = target.name
      end
      @target_positions[sensors.ticks % 10] = calculate_position(sensors.position, target.heading, target.distance)
      if target_last_position
        @target_movements[sensors.ticks % 10] = [RTanque::Heading.new_between_points(target_last_position, target_position), target_last_position.distance(target_position)]
        if last_movement_vector
          @target_movement_deltas[sensors.ticks % 10] = [this_movement_vector[0].delta(last_movement_vector[0]), this_movement_vector[1] - last_movement_vector[0]]
        end
      end
    end

    def target_position
      @target_positions[sensors.ticks % 10]
    end

    def target_last_position
      @target_positions[(sensors.ticks - 1) % 10]
    end

    def next_movement_vector
      if moving_linearly?
        if @movement_type != :linear
          puts "#{sensors.ticks}: linear"
          @movement_type = :linear
        end
        this_movement_vector
      elsif moving_circularly?
        if @movement_type != :circular
          puts "#{sensors.ticks}: circular"
          @movement_type = :circular
        end
        [this_movement_vector[0] + this_movement_vector_delta[0], this_movement_vector[1] + this_movement_vector_delta[0]]
      else
        @movement_type = :erratic
        puts "moving erratically"
        nil
      end
    end

    def last_movement_vector
      @target_movements[(sensors.ticks - 1) % 10]
    end

    def this_movement_vector
      @target_movements[sensors.ticks % 10]
    end

    def last_movement_vector_delta
      @target_movement_deltas[(sensors.ticks - 1) % 10]
    end

    def this_movement_vector_delta
      @target_movement_deltas[sensors.ticks % 10]
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
