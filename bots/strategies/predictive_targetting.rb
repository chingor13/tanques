module Strategies
  module PredictiveTargetting
    def predictive_targetting!
      return unless target

      if this_movement_vector
        heading = this_movement_vector[0]
        speed = this_movement_vector[1]
        ticks_until_bullet_hits = calculate_ticks_until_hit(target.distance, 5)

        movement_delta = this_movement_vector_delta ? this_movement_vector_delta[0] : 0
        target_expected_location = calculate_position(
          target_position, 
          heading,
          speed,
          movement_delta,
          ticks_until_bullet_hits
        )
        store!(:expected_location, target_expected_location)

        log "ticks til hit: #{ticks_until_bullet_hits}"
puts "now (#{sensors.ticks}): #{target_position}"
puts "exp (#{sensors.ticks + ticks_until_bullet_hits}): #{target_expected_location}"
log sensors.turret_heading.to_degrees

        # figure out where the target will be next tick, and where we will be next tick
#        target_expected_location = calculate_position(target_position, heading, speed * ticks_until_bullet_hits)
        my_expected_location = calculate_position(self.sensors.position, 
          self.command.heading || self.sensors.heading, 
          self.command.speed || self.sensors.speed)
        self.command.turret_heading = my_expected_location.heading(target_expected_location)
log command.turret_heading.to_degrees
      end
    end

    BULLET_SPEED = {
      1 => 4.65,
      2 => 9.23,
      3 => 13.79,
      4 => 18.18,
      5 => 22.64
    }

    def calculate_ticks_until_hit(distance, fire_power)
      (distance / BULLET_SPEED[[[5, fire_power].min, 0].max]).floor
    end
  end
end
