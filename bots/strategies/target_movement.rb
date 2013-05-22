module Strategies
  module TargetMovement
    def record_target_position!
      if target
        if @target_name != target.name
          # new target
          clear_store!(:target_position)
          clear_store!(:target_heading)
          clear_store!(:target_speed)
          clear_store!(:target_heading_delta)
          clear_store!(:target_speed_delta)
          @target_name = target.name
        end

        store!(:target_position, calculate_position(sensors.position, target.heading, target.distance))
        if target_last_position
          store!(:target_heading, RTanque::Heading.new_between_points(target_last_position, target_position))
          store!(:target_speed, target_last_position.distance(target_position))
          if target_last_heading
            store!(:target_heading_delta, target_last_heading.delta(target_heading))
            store!(:target_speed_delta, target_last_speed - target_speed)
          end
        end
      else
        # lost target
        if target_last_position
          if sensors.heading.delta(RTanque::Heading.new_between_points(sensors.position, target_last_position)) > 0
            command.heading = sensors.heading + Math::PI/4
          else
            command.heading = sensors.heading - Math::PI/4
          end
        end
      end
    end

    def target_position
      fetch(:target_position)
    end

    def target_last_position
      fetch_relative(:target_position, -1)
    end

    def target_heading
      fetch(:target_heading)
    end

    def target_last_heading
      fetch_relative(:target_heading, -1)
    end

    def target_speed
      fetch(:target_speed)
    end

    def target_last_speed
      fetch_relative(:target_speed, -1)
    end

    def target_heading_delta
      fetch(:target_heading_delta)
    end

    def target_last_heading_delta
      fetch_relative(:target_heading_delta, -1)
    end

    def target_speed_delta
      fetch(:target_speed_delta)
    end

    def target_last_speed_delta
      fetch_relative(:target_speed_delta, -1)
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

    def moving_linearly?
      target_heading_delta && target_heading_delta < RTanque::Heading::ONE_DEGREE
    end

    def moving_circularly?
      if target_heading_delta && target_last_heading_delta
        (target_heading_delta - target_last_heading_delta).abs < 0.001
      end
    end
  end
end
