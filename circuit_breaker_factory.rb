require_relative 'circuit_breaker'
require_relative 'text_monitor'

class CircuitBreakerFactory
  attr_accessor :monitor

  def get_instance &block
    c = CircuitBreaker.new(&block)
    c.monitor = monitor || TextMonitor.new
    c
  end
end
