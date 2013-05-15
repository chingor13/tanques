$:.unshift(File.dirname(__FILE__))
require 'strategies/utilities'
require 'strategies/random_location'
require 'strategies/predictive_targetting'
require 'strategies/naive_firing'
require 'strategies/run_away'
require 'strategies/strafe'
require 'strategies/charge'
require 'strategies/damage_detection'
require 'strategies/game_mode_detect'
require 'pp'

class Strategist < RTanque::Bot::Brain
  NAME = 'strategist'
  include RTanque::Bot::BrainHelper

  def tick!
    game_mode_detect!
    damage_detection!

    if game_mode_known?
      if melee?
        melee_tick!
      else
        one_on_one_tick!
      end
    else
      determine_game_mode!
    end
  end

  def melee_tick!
    predictive_targetting!
    naive_firing!
    random_location!
  end

  def one_on_one_tick!
    puts "playing for one on one"
    predictive_targetting!
    naive_firing!
    if false && target
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
  include Strategies::Charge
  include Strategies::DamageDetection
  include Strategies::GameModeDetect
end
