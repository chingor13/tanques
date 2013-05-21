module Strategies
  module AvoidCenter

    def avoid_center!
      if in_center?
        log "in center"
        turn_to_corner!
      else
        clear_corner!
        pick_spot_in_margin!
        turn_to_spot!
      end
    end

    def turn_to_corner!
      @corner ||= nearest_corner
      command.heading = RTanque::Heading.new_between_points(sensors.position, @corner)
      command.speed = 3
    end

    def clear_corner!
      @corner = nil
    end

    def pick_spot_in_margin!(percent = 25)
      @spot ||= begin
        log "picking spot in margin"
        margin_width = arena.width / 100 * percent
        margin_height = arena.width / 100 * percent
        if sensors.position.x < margin_width
          x = rand(margin_width)
        else
          x = arena.width - rand(margin_width)
        end
        if sensors.position.y < margin_height
          y = rand(margin_height)
        else
          y = arena.height - rand(margin_width)
        end
        RTanque::Point.new(x, y, arena)
      end
    end

    def in_center?(percent = 25)
      x_margin = arena.width / 100.0 * percent
      y_margin = arena.height / 100.0 * percent
      sensors.position.x > x_margin &&
        sensors.position.x < arena.width - x_margin &&
        sensors.position.y > y_margin &&
        sensors.position.y < arena.height - y_margin
    end
  end
end