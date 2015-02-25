class CircuitBreaker
  attr_accessor :invocation_timeout, :failure_threshold, :monitor

  def initialize &block
    @circuit            = block
    @invocation_timeout = 2
    @failure_threshold  = 5
    @failure_count      = 0
    @monitor          = nil
  end

  def call args = nil
    returned = false

    case state
    when :closed
      while !returned && state == :closed
        begin
          result = do_call(args)
          returned = true
        rescue StandardError
          record_failure($!)
        end
      end
    when :open then raise CircuitBreaker::Open
    else raise 'Unreachable Code'
    end

    result
  end

  private

  def do_call args
    result = Timeout::timeout(@invocation_timeout) do
      @circuit.call(args)
    end

    reset

    return result
  end

  def record_failure e
    @failure_count += 1
    @monitor.alert(:open_circuit, e) if :open == state
  end

  def reset
    @failure_count = 0
    @monitor.alert :reset_circuit
  end

  def state
    (@failure_count >= @failure_threshold) ? :open : :closed
  end
end

class CircuitBreaker::Open < StandardError; end
