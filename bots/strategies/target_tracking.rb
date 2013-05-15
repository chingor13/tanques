module Strategies
  module TargetTracking

    def nearest_reflection
      self.sensors.radar.sort_by(&:distance).reject{|ref| ref.name == self.class.const_get('NAME')}.first
    end

    def track_reflection!(reflection)
      @target = reflection
    end

    def target_locked?
      @target.present?
    end

    def target
      @target
    end

  end
end
