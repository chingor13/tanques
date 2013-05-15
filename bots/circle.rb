class Circle < RTanque::Bot::Brain
  NAME = 'circle'
  include RTanque::Bot::BrainHelper

  def tick!

    if sensors.ticks > 120
      # circle in the middle
      self.command.speed = 3
      self.command.heading = self.sensors.heading - RTanque::Heading::EIGHTH_ANGLE
    else
      middle = RTanque::Point.new(arena.width / 2, arena.height / 2, arena)
      self.command.heading = RTanque::Heading.new_between_points(sensors.position, middle)
      self.command.speed = 2
    end
  end
end
