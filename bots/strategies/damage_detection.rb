module Strategies
  module DamageDetection
    def damage_detection!
      @previous_health ||= 100
      if sensors.health < @previous_health
        damage_taken << [sensors.ticks, @previous_health - sensors.health, sensors.health]
      end
      @previous_health = sensors.health
    end

    def damage_taken
      @damage_taken ||= []
    end
  end
end
