$:.unshift(File.dirname(__FILE__))
require 'strategies/utilities'
require 'strategies/storage'
require 'strategies/random_location'
require 'strategies/random_heading'
require 'strategies/targetting'
require 'strategies/predictive_targetting'
require 'strategies/naive_firing'
require 'strategies/run_away'
require 'strategies/strafe'
require 'strategies/charge'
require 'strategies/damage_detection'
require 'strategies/game_mode_detect'
require 'strategies/target_movement'
require 'strategies/safe_firing'
require 'strategies/avoid_center'
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
    acquire_target!
    follow_target!
    record_target_position!

    avoid_center!

    predictive_targetting!
    safe_firing!

    # default to spin
    command.radar_heading ||= sensors.radar_heading - RTanque::Heading::EIGHTH_ANGLE
    command.turret_heading ||= command.radar_heading
  end

  def one_on_one_tick!
    # radar
    acquire_target!
    follow_target!
    record_target_position!

    # movement - pick a random movement strategy
    @strategy = :random_location
    every_x_ticks(200) do
      @strategy = [:random_location, :strafe_right, :strafe_left].sample
    end
    case @strategy
    when :strafe_right
      strafe_right!(RTanque::Heading::ONE_DEGREE * 15) if target
    when :strafe_left
      strafe_left!(RTanque::Heading::ONE_DEGREE * 15) if target
    when :random_location
    end
    random_location!

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
  include Strategies::RandomHeading
  include Strategies::Targetting
  include Strategies::PredictiveTargetting 
  include Strategies::NaiveFiring
  include Strategies::RunAway
  include Strategies::Strafe
  include Strategies::Charge
  include Strategies::DamageDetection
  include Strategies::GameModeDetect
  include Strategies::TargetMovement
  include Strategies::SafeFiring
  include Strategies::AvoidCenter
end
