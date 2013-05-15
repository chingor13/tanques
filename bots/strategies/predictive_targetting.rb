module Strategies
  module PredictiveTargetting
    def target
      @target
    end

    def predictive_targetting!
      acquire_target!
      determine_target_vectors!
    end

    def acquire_target!
      if @target = self.sensors.radar.sort_by(&:distance).reject{|t| t.name == self.class.const_get('NAME')}.first
        # lock radar and turret on target
        self.command.radar_heading = @target.heading
        #self.command.turret_heading = @target.heading
      else
        # naively spit left
        @target_last_position = nil
        @expected_location = nil
        self.command.radar_heading = self.sensors.radar_heading - RTanque::Heading::EIGHTH_ANGLE
        self.command.turret_heading = self.command.radar_heading
      end
    end

    def determine_target_vectors!
      return unless @target

      target_position = calculate_position(self.sensors.position, @target.heading, @target.distance)
      if @target_last_position
        target_movement_vector = @target_last_position.heading(target_position)
        target_speed = @target_last_position.distance(target_position)

        # figure out where the target will be next tick, and where we will be next tick
        ticks_until_bullet_hits = @target.distance / fire_power(@target.distance) / 2
        target_expected_location = calculate_position(target_position, target_movement_vector, target_speed * ticks_until_bullet_hits)
        my_expected_location = calculate_position(self.sensors.position, self.sensors.heading, self.sensors.speed)
        self.command.turret_heading = my_expected_location.heading(target_expected_location)
      end
      @target_last_position = target_position
    end
  end
end
