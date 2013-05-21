module Strategies
  module RandomHeading

    def random_heading!
      pick_heading!
      turn_to_heading!
    end

    def pick_heading!
      if time_for_new_heading?
        @heading = nil
      end
      if @heading.nil?
        log "picking new heading"
        @heading_tick_count = 0
        random_change = RTanque::Heading.new_from_degrees(rand(60) + 30)  # 30-90 degrees
        @heading = sensors.heading + ([true,false].sample ? random_change : -1 * random_change).to_f
      end
      @heading_tick_count += 1
    end

    def turn_to_heading!
      command.heading = @heading
      command.speed = 3
    end

    def time_for_new_heading?
      return false if @heading_tick_count.nil?

      @heading_tick_count > 60 && rand(20) <= 1
    end

  end
end