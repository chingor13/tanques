module Strategies
  module Strafe
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
  end
end
