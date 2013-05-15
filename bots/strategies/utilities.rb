module Strategies
  module Utilities
    def near_edge?(distance = 100)
      near_top?(distance) ||
        near_bottom?(distance) ||
        near_left?(distance) ||
        near_right?(distance)
    end

    def near_top?(distance = 100)
      sensors.position.y >= arena.height - distance
    end

    def near_bottom?(distance = 100)
      sensors.position.y <= distance
    end

    def near_right?(distance = 100)
      sensors.position.x >= arena.width - distance
    end

    def near_left?(distance = 100)
      sensors.position.x <= distance
    end

    def northish?(heading)
      Math.sin(heading) < 0
    end

    def southish?(heading)
      Math.sin(heading) > 0
    end

    def westish?(heading)
      Math.cos(heading) > 0
    end

    def eastish?(heading)
      Math.cos(heading) < 0
    end

    def calculate_position(start_position, heading, distance)
      RTanque::Point.new(
        start_position.x + Math.sin(heading) * distance,
        start_position.y + Math.cos(heading) * distance,
        self.arena
      )
    end

    module ClassMethods
      def send(*args, &block)
        puts "#{caller[0].split(":").first} is trying to hack me!!!"
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end
  end
end
