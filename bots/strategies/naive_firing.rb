module Strategies
  module NaiveFiring
    def naive_firing!
      fire_when_ready!
    end

    def fire_when_ready!
      if target && command.turret_heading
        if (sensors.turret_heading.to_degrees - command.turret_heading.to_degrees).abs < 3
          if target.distance < 75
            command.fire(1)
          else
            # control your firepower
            command.fire(5)
          end
        elsif sensors.gun_energy >= 5
          command.fire(1)
        end
      end
    end

  end
end
