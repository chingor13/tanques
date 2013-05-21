$:.unshift(File.dirname(__FILE__))

class Strategist < RTanque::Bot::Brain
  NAME = 'strategist'
  include RTanque::Bot::BrainHelper

  def tick!
    game_mode_detect!
    damage_detection!

    if game_mode_known?
      if melee?
        melee_tick!
      else
        one_on_one_tick!
      end
    else
      determine_game_mode!
    end
  end

  def melee_tick!
    acquire_target!
    follow_target!
    record_target_position!

    avoid_center!

    predictive_targetting!
    safe_firing!
  end

  def one_on_one_tick!
    # radar
    acquire_target!
    follow_target!
    record_target_position!

    # movement
    random_location!

    # turret / gun
    predictive_targetting!
    naive_firing!

    # default to spin
    command.radar_heading ||= sensors.radar_heading - RTanque::Heading::EIGHTH_ANGLE
    command.turret_heading ||= command.radar_heading
  end

  protected

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
    STORAGE_SIZE = 20
    def store!(type, value, tick = nil)
      tick ||= sensors.ticks
      @storage ||= {}
      @storage[type] ||= Array.new(STORAGE_SIZE)
      @storage[type][tick % STORAGE_SIZE] = value
    end
    def clear_store!(type)
      @storage ||= {}
      @storage[type] = Array.new(STORAGE_SIZE)
    end
    def fetch(type, tick = nil)
      tick ||= sensors.ticks
      @storage ||= {}
      @storage[type] ||= Array.new(STORAGE_SIZE)
      @storage[type][tick % STORAGE_SIZE]
    end
    def fetch_relative(type, relative)
      fetch(type, sensors.ticks + relative)
    end
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
    def target
      @target
    end
    def last_target_name
      @last_target_name
    end
    def nearest_target
      sensors.radar.select{|t| t.name != self.class.const_get('NAME')}.sort_by(&:distance).first
    end
    def nearest_target_named(name)
      sensors.radar.select{|t| t.name == name}.sort_by(&:distance).first
    end
    def acquire_target!
      @target = nearest_target
      @last_target_name = @target.name if @target
    end
    def sticky_target!
      @target = nearest_target_named(last_target_name) ||
                nearest_target
      @last_target_name = @target.name if @target
    end
    def follow_target!
      if target
        command.radar_heading = target.heading
        command.turret_heading = target.heading
      end
    end
    def predictive_targetting!
      return unless target
      if target_heading
        ticks_until_bullet_hits = calculate_ticks_until_hit(target.distance, 5)
        target_expected_location = calculate_position(
          target_position, 
          target_heading,
          target_speed,
          target_heading_delta,
          ticks_until_bullet_hits
        )
        store!(:expected_location, target_expected_location)
        # figure out where the target will be next tick, and where we will be next tick
        my_expected_location = calculate_position(self.sensors.position, 
          self.command.heading || self.sensors.heading, 
          self.command.speed || self.sensors.speed)
        self.command.turret_heading = my_expected_location.heading(target_expected_location)
      end
    end
    def naive_firing!
      fire_when_ready!
    end
    def fire_when_ready!
      if target && command.turret_heading
        if (sensors.turret_heading.to_degrees - command.turret_heading.to_degrees).abs < 1
          # control your firepower
          if sensors.gun_energy >= 5
            command.fire(5)
          end
        end
      end
    end
    def run_away!
      if target
        self.command.heading = target.heading - RTanque::Heading::HALF_ANGLE
      end
      self.command.speed = 10
    end
    def strafe!
      if target
        if near_top?
          if westish?(target.heading)
            strafe_left!
          else
            strafe_right!
          end
        elsif near_bottom?
          if westish?(target.heading)
            strafe_right!
          else
            strafe_left!
          end
        elsif near_left?
          if northish?(target.heading)
            strafe_right!
          else
            strafe_left!
          end
        elsif near_right?
          if northish?(target.heading)
            strafe_left!
          else
            strafe_right!
          end
        else
          strafe_left!
        end
      end
      self.command.speed = 10
    end
    def strafe_left!
      self.command.heading = target.heading - Math::PI/2
    end
    def strafe_right!
      self.command.heading = target.heading + Math::PI/2
    end
    def charge!
      if target
        self.command.heading = target.heading
      end
    end
    def damage_detection!
      @previous_health ||= 100
      if sensors.health < @previous_health
        log("damage taken: #{@previous_health - sensors.health}")
        damage_taken << [sensors.ticks, @previous_health - sensors.health, sensors.health]
      end
      @previous_health = sensors.health
    end
    def damage_taken?
      damage_taken.last && damage_taken.last.first == sensors.ticks
    end
    def damage_taken
      @damage_taken ||= []
    end
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
      @game_mode ||= :one_on_one if sensors.ticks > 120
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
    def record_target_position!
      return unless target
      if @target_name != target.name
        # new target
        clear_store!(:target_position)
        clear_store!(:target_heading)
        clear_store!(:target_speed)
        clear_store!(:target_heading_delta)
        clear_store!(:target_speed_delta)
        @target_name = target.name
      end
      store!(:target_position, calculate_position(sensors.position, target.heading, target.distance))
      if target_last_position
        store!(:target_heading, RTanque::Heading.new_between_points(target_last_position, target_position))
        store!(:target_speed, target_last_position.distance(target_position))
        if target_last_heading
          store!(:target_heading_delta, target_last_heading.delta(target_heading))
          store!(:target_speed_delta, target_last_speed - target_speed)
        end
      end
    end
    def target_position
      fetch(:target_position)
    end
    def target_last_position
      fetch_relative(:target_position, -1)
    end
    def target_heading
      fetch(:target_heading)
    end
    def target_last_heading
      fetch_relative(:target_heading, -1)
    end
    def target_speed
      fetch(:target_speed)
    end
    def target_last_speed
      fetch_relative(:target_speed, -1)
    end
    def target_heading_delta
      fetch(:target_heading_delta)
    end
    def target_last_heading_delta
      fetch_relative(:target_heading_delta, -1)
    end
    def target_speed_delta
      fetch(:target_speed_delta)
    end
    def target_last_speed_delta
      fetch_relative(:target_speed_delta, -1)
    end
    def movement_type
      if moving_linearly?
        return :linear
      elsif moving_circularly?
        return :circular
      else
        return :erratic
      end
    end
    def moving_linearly?
      target_heading_delta && target_heading_delta < RTanque::Heading::ONE_DEGREE
    end
    def moving_circularly?
      if target_heading_delta && target_last_heading_delta
        (target_heading_delta - target_last_heading_delta).abs < 0.001
      end
    end
    def safe_firing!
      sensors.radar.sort_by(&:distance).each do |bot|
        if bot.name == my_name
          return if will_hit?(bot)
        else
          naive_firing!
        end
      end
    end
    def will_hit?(reflection, power = 5)
      reflection.heading.delta(sensors.turret_heading) < RTanque::Heading::ONE_DEGREE
    end
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
