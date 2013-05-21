module Strategies
  module Utilities
    def log(message)
      puts "#{self.class.const_get('NAME')} (#{sensors.ticks}): #{message}"
    end

    def bound_value(val, min, max)
      [[max, val].min, min].max
    end

    def bot_count
      count = 0
      sensors.radar.each do |bot|
        count += 1
      end
      count
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
      ticks.times do
        pos = RTanque::Point.new(
          pos.x + Math.sin(heading) * distance,
          pos.y + Math.cos(heading) * distance,
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

    def my_name
      self.class.const_get("NAME")
    end

    def nearest_enemy
      sensors.radar.sort_by(&:distance).reject{|bot| bot.name == my_name}.first
    end

    BULLET_SPEED = {
      1 => 4.65,
      2 => 9.23,
      3 => 13.79,
      4 => 18.18,
      5 => 22.64
    }

    def calculate_ticks_until_hit(distance, fire_power)
      (distance / BULLET_SPEED[bound_value(fire_power, 0, 5)]).floor
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
