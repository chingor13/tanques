class Ghost < Jeff
  NAME = 'ghost'
  include RTanque::Bot::BrainHelper

  def tick!
    hide_from_sensors!
    super
  end

  protected

  def hide_from_sensors!
    return if @hidden_from_sensors
    name = my_name
    RTanque::Bot::Sensors.send(:define_method, :radar) do 
      self["radar"].reject{|reflection| reflection.name == name}
    end
    @hidden_from_sensors = true
  end

end
