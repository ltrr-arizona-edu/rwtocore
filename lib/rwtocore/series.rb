# -*- coding: utf-8 -*-

module Rwtocore
  # A tree-ring measurement series in the obsolete RW format produced by old
  # measuring machines.
  class Series
    # Label for the series (should be a locally unique ID).
    # @return [String] the label in free text
    attr_reader :name
    # Initials of the person who measured the series (not checked or used).
    # @return [String] arbitrary text (conventionally, a few capital letters)
    attr_reader :initials
    # Date the series was measured, in DD/MM/YYYY format.
    # @return [String] plain text (not a Time or other better representation)
    attr_reader :measured
    # Series start date as a calendar or relative year.
    # @return [Integer] date of the first ring in the series.
    attr_reader :start_date

    # End-of-series sentinel, marking the end of measurements.
    EOS = "999"
    
    # Create a new ring-width measurement series.
    # @param [String] name the arbitrary name to associate with the series
    # @param [IO] str the input stream, text in RW format
    # @param [#message] err an error logging facility
    def initialize(name, str, err)
      @ring_data, @name, @initials, @measured, @start_date, @r_init = [], name, "", "", 0, 0
      begin
        @initials = str.readline until @initials =~ /\W/
        @initials.strip!
        @measured = str.readline.strip
        unless @measured =~ /\d{1,2}\/\d{1,2}\/(\d{2}|\d{4})/
          err.message "The meaurement date #{@measured} was in an unexpected format"
        end
        start = str.readline.strip
        if start =~ /[+-]?\d+/
          @start_date = start.to_i
        else
          err.message "Expected a numeric start date but found the text #{start}"
        end
        r_in = @r_init
        str.each do |line|
          line.strip!
          break if line == EOS
          if line =~ /\d+/
            w = line.to_i
            @ring_data.push([w, r_in])
            r_in += w
          else
            err.message "Expected a number but found the text #{line} at line #{str.lineno}"
          end
        end
      rescue => except
        if str
          err.message "Unexpected error at line #{str.lineno} (#{except.class}, #{except.message})"
        else
          err.message "Unexpected error when reading (#{except.class}, #{except.message})"
        end
        @ring_data, @name, @initials, @measured, @start_date = [], name, "", "", 0
      end
    end

    # Number of rings.
    # @return [Integer] the number of rings in the displayable sub-series.
    def full_nrings
      @ring_data.size
    end

    # Total series length.
    # @return [Integer] the distance from the start of the first displayable
    #   ring to the end of the last, in the original measurement units.
    def total
      @ring_data.inject(0) {|dist, ring| dist + ring[0] }
    end

    # Starting distance from the tree pith.
    # @return [Integer] offset to the first ring in the displayable series.
    def offset
      @r_init
    end

    # Absolute and incremental ring widths.
    # @return [Enumerable<Array>] the measurements of the displayable rings,
    #   each represented as a pair of values
    #   * ring_width, the width of that ring as an increment
    #   * ring_start, the total distance from the start of the series to the start of the ring.
    def rings
      @ring_data.to_enum
    end

  end
  
  # Create a new sub-series from the start of some RW format ring-width data.
  # @param [String] name the arbitrary name to associate with the series
  # @param [IO] str the input stream, text in RW format
  # @param [#message] err an error logging facility
  # @param [Integer] maxlen maximum length of the sub-series
  class InnerSeries < Series
    def initialize(name, str, err, maxlen)
      @n = maxlen.abs
      super(name, str, err)
    end

    # @see Series#total
    def total
      @ring_data.first(@n).inject(0) {|dist, ring| dist + ring[0] }
    end

    # @see Series#offset
    def offset
      @ring_data.first(@n)[0][1]
    end

    # @see Series#rings
    def rings
      @ring_data.first(@n).to_enum
    end

  end

  # Create a new sub-series from the end of some RW format ring-width data.
  # @param [String] name the arbitrary name to associate with the series
  # @param [IO] str the input stream, text in RW format
  # @param [#message] err an error logging facility
  # @param [Integer] maxlen maximum length of the sub-series
  class OuterSeries < Series
    def initialize(name, str, err, maxlen)
      @n = maxlen.abs
      super(name, str, err)
    end

    # @see Series#total
    def total
      @ring_data.last(@n).inject(0) {|dist, ring| dist + ring[0] }
    end

    # @see Series#offset
    def offset
      @ring_data.last(@n)[0][1]
    end

    # @see Series#rings
    def rings
      @ring_data.last(@n).to_enum
    end

  end
end