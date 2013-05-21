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
      command.speed = 3
    end

    def strafe_left!(offset = 0)
      command.heading = target.heading - (Math::PI/2 + offset)
    end

    def strafe_right!(offset = 0)
      command.heading = target.heading + (Math::PI/2 + offset)
    end
  end
end
