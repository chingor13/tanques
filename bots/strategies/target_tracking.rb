module Strategies
  module TargetTracking

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
