require_relative '../circuit_breaker'

describe CircuitBreaker do

  class Monitor
    def alert *args
    end
  end

  class Spy
    def called
    end
  end

  let(:success_block) { ->(args){ 'success' } }
  let(:error_block)   { ->(args){ raise Timeout::Error } }
  let(:spy)           { Spy.new }
  let(:spy_block)     { ->(args){ spy.called } }
  let(:spy_with_error_block)     { ->(args){ spy.called; raise Timeout::Error } }
  let(:monitor)       { Monitor.new }

  describe '#call' do

    it 'receives a block and calls it' do
      cb         = CircuitBreaker.new(&success_block)
      cb.monitor = monitor

      expect(cb.call).to eq('success')
    end

    it 'retries the call in case of error' do
      cb         = CircuitBreaker.new(&spy_with_error_block)
      cb.monitor = monitor

      expect(spy).to receive(:called).exactly(5).times
      cb.call
    end

    it 'notifies the monitor when the threshold is hit' do
      cb         = CircuitBreaker.new(&error_block)
      cb.monitor = monitor

      expect(monitor).to receive(:alert).with(:open_circuit, an_instance_of(Timeout::Error))
      cb.call
    end

    it 'notifies the monitor when the threshold resets' do
      cb         = CircuitBreaker.new(&spy_block)
      cb.monitor = monitor

      allow(spy).to receive(:called).and_raise(Timeout::Error).once
      allow(spy).to receive(:called)
      expect(monitor).to receive(:alert).with(:reset_circuit)
      cb.call
    end
  end
end
