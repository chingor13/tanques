module Strategies
  module RunAway
    def run_away!
      if target
        log "target is northish" if northish?(target.heading)
        log "target is southish" if southish?(target.heading)
        log "target is westish" if westish?(target.heading)
        log "target is eastish" if eastish?(target.heading)
        command.heading ||= target.heading - RTanque::Heading::HALF_ANGLE
      end
      command.speed ||= 3
    end
  end
end
