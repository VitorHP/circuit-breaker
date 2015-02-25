class TextMonitor
  def alert state, e = nil
    case state
      when :open_circuit
        puts "There was an error trying to connect to the remote server"
        puts e.class
        puts e.message
      when :reset_circuit
        puts "All normal"
      else
        raise UnexpectedMonitorState
    end
  end
end

class UnexpectedMonitorState < StandardError; end
