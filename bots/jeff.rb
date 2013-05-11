class Jeff < RTanque::Bot::Brain
  NAME = 'jeff'
  include RTanque::Bot::BrainHelper

  def tick!
    ## main logic goes here
    pick_spot!
    turn_to_spot!
    acquire_target!
    fire_when_ready!    
  end

  protected

  def at_spot?
    return false if @spot.nil?

    self.sensors.position.within_radius?(@spot, 10)
  end

  def time_for_new_spot?
    return false if @tick_count.nil?

    @tick_count > 60 && rand(4) <= 1
  end

  def pick_spot!
    if at_spot? || time_for_new_spot?
      @spot = nil
      @tick_count = 0
    end
    if @spot.nil?
      @spot = RTanque::Point.new(rand(self.arena.width), rand(self.arena.height), self.arena)
    end
  end

  def turn_to_spot!
    self.command.heading = self.sensors.position.heading(@spot)

    distance_to_spot = self.sensors.position.distance(@spot)
    if distance_to_spot < 15
      self.command.speed = 1
    elsif distance_to_spot < 25
      self.command.speed = 2
    else
      self.command.speed = 3
    end
  end

  def acquire_target!
    if @target = self.sensors.radar.sort_by(&:distance).first
      # lock radar and turret on target
      self.command.radar_heading = @target.heading
      self.command.turret_heading = @target.heading
    else
      # naively spit left
      self.command.radar_heading = self.sensors.radar_heading - RTanque::Heading::EIGHTH_ANGLE
    end
  end

  def fire_when_ready!
    if @target
      if (self.sensors.turret_heading.to_degrees - @target.heading.to_degrees).abs < 2
        # control your firepower
        if @target.distance < 250
          self.command.fire(5)
        elsif @target.distance < 500
          self.command.fire(10)
        else
          self.command.fire(1)
        end
      end
    end
  end

  def calculate_target_position(target)
    RTanque::Point.new(
      self.sensors.position.x + Math.cos(target.heading) * target.distance,
      self.sensors.position.y + Math.sin(target.heading) * target.distance
    )
  end

end
