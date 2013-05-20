module Strategies
  module NaiveFiring
    def naive_firing!
      fire_when_ready!
    end

    def fire_when_ready!
      if @target
        if (self.sensors.radar_heading.to_degrees - @target.heading.to_degrees).abs < 2
          # control your firepower
          if sensors.gun_energy >= 5
            log "firing"
            command.fire(5)
          end
        end
      end
    end

  end
end
