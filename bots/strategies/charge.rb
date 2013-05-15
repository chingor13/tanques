module Strategies
  module Charge
    def charge!
      if target
        self.command.heading = target.heading
      end
    end
  end
end
