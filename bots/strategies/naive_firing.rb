module Strategies
  module NaiveFiring
    def naive_firing!
      fire_when_ready!
    end

    def fire_power(distance)
      if distance < 250
        5
      else
        10
      end
    end

    def fire_when_ready!
      if @target
        if (self.sensors.radar_heading.to_degrees - @target.heading.to_degrees).abs < 2
          # control your firepower
          self.command.fire(fire_power(@target.distance))
        end
      end
    end

  end
end
