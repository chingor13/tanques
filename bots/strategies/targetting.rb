module Strategies
  module Targetting
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
  end
end
