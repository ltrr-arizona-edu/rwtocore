# -*- coding: utf-8 -*-

module Rwtocore  

  # Log messages to a stream, prefixed by label identifying the error location.
  class Messenger
    # Separator between label and message.
    SEP = ": "
    # Terminator for the entire log message.
    TERM = "."
    
    # Associate the label with the logging stream.
    # @param [String] name name of a file, program, etc
    # @param [IO] stream where to send the log entries 
    def initialize(name, stream)
      @label = name
      @log = stream
    end

    # Emit a log entry.
    # @param [String] text the particular message for this entry
    def message(text)
      @log.puts [@label, SEP, text, TERM].join('')
    end
  end
end