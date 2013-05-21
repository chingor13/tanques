module Strategies
  module PredictiveTargetting
    def predictive_targetting!
      return unless target

      if target_heading
        ticks_until_bullet_hits = calculate_ticks_until_hit(target.distance, 5)

        target_expected_location = calculate_position(
          target_position, 
          target_heading,
          target_speed,
          target_heading_delta,
          ticks_until_bullet_hits
        )
        store!(:expected_location, target_expected_location)

        # figure out where the target will be next tick, and where we will be next tick
        my_expected_location = calculate_position(self.sensors.position, 
          self.command.heading || self.sensors.heading, 
          self.command.speed || self.sensors.speed)
        self.command.turret_heading = my_expected_location.heading(target_expected_location)
      end
    end
  end
end
