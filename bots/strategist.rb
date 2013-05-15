$:.unshift(File.dirname(__FILE__))
require 'strategies/utilities'
require 'strategies/random_location'
require 'strategies/predictive_targetting'
require 'strategies/naive_firing'
require 'strategies/run_away'
require 'strategies/strafe'

class Strategist < RTanque::Bot::Brain
  NAME = 'strategist'
  include RTanque::Bot::BrainHelper

  def tick!
    predictive_targetting!
    naive_firing!
    if target
      #run_away!
      strafe!
    else
      random_location!
    end
  end

  protected

  include Strategies::Utilities
  include Strategies::RandomLocation
  include Strategies::PredictiveTargetting 
  include Strategies::NaiveFiring
  include Strategies::RunAway
  include Strategies::Strafe
end