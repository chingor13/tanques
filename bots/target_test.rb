$:.unshift(File.dirname(__FILE__))
require 'strategies/utilities'
require 'strategies/damage_detection'

class TargetTest < RTanque::Bot::Brain
  NAME = 'target_test'
  include RTanque::Bot::BrainHelper
  include Strategies::Utilities
  include Strategies::DamageDetection

  def tick!
    damage_detection!
    
    # go to top right
    command.heading = RTanque::Heading.new_between_points(sensors.position, 
      RTanque::Point.new(arena.width, 50, arena)
    )
    command.speed = 1
    if damage_taken?
      log "damage_taken"
    end
  end
end