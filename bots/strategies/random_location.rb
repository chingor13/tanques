module Strategies
  module RandomLocation
    def random_location!
      pick_spot!
      turn_to_spot!
    end

    def at_spot?
      return false if @spot.nil?

      self.sensors.position.within_radius?(@spot, 10)
    end

    def time_for_new_spot?
      return false if @tick_count.nil?

      @tick_count > 60 && rand(20) <= 1
    end

    def pick_spot!
      if at_spot? || time_for_new_spot?
        @spot = nil
      end
      if @spot.nil?
        @tick_count = 0
        @spot = RTanque::Point.new(rand(self.arena.width), rand(self.arena.height), self.arena)
      end
      @tick_count += 1
    end

    def turn_to_spot!
      self.command.heading = self.sensors.position.heading(@spot)

      distance_to_spot = self.sensors.position.distance(@spot)
      if distance_to_spot < 25
        self.command.speed = 1
      elsif distance_to_spot < 50
        self.command.speed = 2
      else
        self.command.speed = 3
      end
    end
  end
end
