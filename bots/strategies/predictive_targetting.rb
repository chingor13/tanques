module Strategies
  module PredictiveTargetting
    def predictive_targetting!
      return unless target
      if this_movement_vector
        heading = this_movement_vector[0]
        speed = this_movement_vector[1]
        ticks_until_bullet_hits = target.distance / fire_power(target.distance) / 2

        target_expected_location = target_position
puts "ticks: #{ticks_until_bullet_hits}"
        ticks_until_bullet_hits.floor.times do
          target_expected_location = calculate_position(target_expected_location, heading, speed)

          heading = heading + this_movement_vector_delta[0] if this_movement_vector_delta
        end
puts "now: #{target_position}"
puts "exp: #{target_expected_location}"

        # figure out where the target will be next tick, and where we will be next tick
#        target_expected_location = calculate_position(target_position, heading, speed * ticks_until_bullet_hits)
        my_expected_location = calculate_position(self.sensors.position, self.command.heading || self.sensors.heading, self.command.speed || self.sensors.speed)
        self.command.turret_heading = my_expected_location.heading(target_expected_location)
      end
    end
  end
end
