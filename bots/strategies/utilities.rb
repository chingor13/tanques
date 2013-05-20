module Strategies
  module Utilities
    def log(message)
      puts "#{self.class.const_get('NAME')} (#{sensors.ticks}): #{message}"
    end

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

    def calculate_position(start_position, heading, distance, heading_delta = 0, ticks = 1)
      pos = start_position
      head = heading
      ticks.times do
        pos = RTanque::Point.new(
          start_position.x + Math.sin(heading) * distance,
          start_position.y + Math.cos(heading) * distance,
          self.arena
        )
        heading += heading_delta
      end
      pos
    end

    def nearest_corner(offset = 0)
      if sensors.position.x > arena.width / 2
        x = arena.width - offset
      else
        x = offset
      end
      if sensors.position.y > arena.height / 2
        y = arena.height - offset
      else
        y = offset
      end
      RTanque::Point.new(x, y, arena)
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
