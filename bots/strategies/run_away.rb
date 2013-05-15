module Strategies
  module RunAway
    def run_away!
      if target
        self.command.heading = target.heading - RTanque::Heading::HALF_ANGLE
      end
      self.command.speed = 10
    end
  end
end
