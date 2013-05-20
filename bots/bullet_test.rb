$:.unshift(File.dirname(__FILE__))
require 'strategies/utilities'
require 'strategies/damage_detection'

class BulletTest < RTanque::Bot::Brain
  NAME = 'bullet_test'
  include RTanque::Bot::BrainHelper
  include Strategies::Utilities
  include Strategies::DamageDetection

  def tick!

    # go to top left
    command.heading = RTanque::Heading.new_between_points(sensors.position, 
      RTanque::Point.new(0, 50, arena)
    )
    command.speed = 3

    if @position
      log "distance travelled: #{@position.distance(sensors.position)}"
    end
    @position = sensors.position
    log "pos: #{sensors.position}"

    command.turret_heading = RTanque::Heading::EAST
    if sensors.ticks % 300 == 0
      log "Firing"
      command.fire(5)
    end
  end
end