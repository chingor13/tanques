module Strategies
  module SafeFiring
    def safe_firing!
      sensors.radar.sort_by(&:distance).each do |bot|
        if bot.name == my_name
          return if will_hit?(bot)
        else
          naive_firing!
        end
      end
    end

    def will_hit?(reflection, power = 5)
      reflection.heading.delta(sensors.turret_heading) < RTanque::Heading::ONE_DEGREE
    end
  end
end