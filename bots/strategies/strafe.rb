module Strategies
  module Strafe
    def strafe!
      if target
        #strafe_left!
        strafe_right!
      end
      self.command.speed = 10
    end

    def strafe_left!
      self.command.heading = target.heading - Math::PI/2
    end

    def strafe_right!
      self.command.heading = target.heading + Math::PI/2
    end
  end
end
