module Strategies
  module GameModeDetect
    def game_mode_detect!
      if target.nil?
        @bots_seen = {}
        @game_mode = nil
      end
      @bots_seen ||= {}
      sensors.radar.each do |reflection|
        @bots_seen[reflection.name] = true
      end

      if @bots_seen.size > 1
        @game_mode = :melee
      end

      # after x ticks, default to one_on_one
      @game_mode ||= :one_on_one if sensors.ticks > 60
    end

    def determine_game_mode!
      # if undetermined game type, figure it out
      unless game_mode_known?
        # find nearest corner, go there
        @nearest_corner ||= nearest_corner(100)
        @starting_radar_heading ||= sensors.radar_heading

        command.heading = RTanque::Heading.new_between_points(sensors.position, @nearest_corner)
        command.speed = 3
        command.radar_heading = sensors.radar_heading - RTanque::Heading::EIGHTH_ANGLE
        if nearest = nearest_enemy
          command.turret_heading = nearest.heading
        end
        command.turret_heading ||= command.radar_heading
      end
    end

    def melee?
      @game_mode == :melee
    end

    def one_on_one?
      @game_mode == :one_on_one
    end

    def game_mode_known?
      !!@game_mode
    end

    def reset_game_mode!
      @game_mode = nil
    end

  end
end
