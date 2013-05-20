$:.unshift(File.dirname(__FILE__))
require 'strategies/utilities'
require 'strategies/storage'
require 'strategies/random_location'
require 'strategies/targetting'
require 'strategies/predictive_targetting'
require 'strategies/naive_firing'
require 'strategies/run_away'
require 'strategies/strafe'
require 'strategies/charge'
require 'strategies/damage_detection'
require 'strategies/game_mode_detect'
require 'strategies/target_movement'
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
    # radar
    acquire_target!
    follow_target!
    record_target_position!

    # movement
    #random_location!
command.speed = 0
log "movement_type: #{movement_type}"

    # turret / gun
    predictive_targetting!
    naive_firing!

    # default to spin
    command.radar_heading ||= sensors.radar_heading - RTanque::Heading::EIGHTH_ANGLE
    command.turret_heading ||= command.radar_heading
  end

  protected

  include Strategies::Utilities
  include Strategies::Storage
  include Strategies::RandomLocation
  include Strategies::Targetting
  include Strategies::PredictiveTargetting 
  include Strategies::NaiveFiring
  include Strategies::RunAway
  include Strategies::Strafe
  include Strategies::Charge
  include Strategies::DamageDetection
  include Strategies::GameModeDetect
  include Strategies::TargetMovement
end
