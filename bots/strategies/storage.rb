module Strategies
  module Storage
    STORAGE_SIZE = 20

    def store!(type, value, tick = nil)
      tick ||= sensors.ticks
      @storage ||= {}
      @storage[type] ||= Array.new(STORAGE_SIZE)
      @storage[type][tick % STORAGE_SIZE] = value
    end

    def clear_store!(type)
      @storage ||= {}
      @storage[type] = Array.new(STORAGE_SIZE)
    end

    def fetch(type, tick = nil)
      tick ||= sensors.ticks
      @storage ||= {}
      @storage[type] ||= Array.new(STORAGE_SIZE)
      @storage[type][tick % STORAGE_SIZE]
    end

    def fetch_all(type)
      @storage ||= {}
      @storage[type] ||= Array.new(STORAGE_SIZE)
    end

    def fetch_relative(type, relative)
      fetch(type, sensors.ticks + relative)
    end

    def every_x_ticks(x, &block)
      if sensors.ticks % x.to_i == 0
        yield(block)
      end
    end

  end
end