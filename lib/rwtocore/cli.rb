# -*- coding: utf-8 -*-

require "optparse"

module Rwtocore
  # The command line interface to the ring width to core drawing conversion,
  # handling the simple case of reading several RW formatted text files and
  # generating a SVG drawing on Standard Output; the file names provide the
  # identifying labels for the ring-width series.
  class CLI
    # Displayable sub-series length within each series.
    # @return [Integer] the sub-series length
    attr_reader :blocksize
    # File paths from which to read the RW formatted text.
    # @return [Array<String>] the files paths (possibly invalid)
    attr_reader :filelist
    
    # Set up the options and streams for running the program; the only
    # interesting option is the displayable sub-series length.
    # @param [String] program_name the program name to use in messages
    # @param [Array] args command-line arguments
    # @param [#<<] outstream the destination of the output
    # @param [#puts] errstream where to send error and help messages
    # @raise [SystemExit] on early termination
    #   * false, option parse errors
    #   * true, help and informational messages
    def initialize(program_name, args, outstream, errstream)
      @outs, @errs = outstream, errstream
      @blocksize = 0
      @filelist = []
      opt_parser =  OptionParser.new do |opts|
        opts.banner = "Usage: #{program_name} [options] rwfile [rwfile ...]"
        opts.separator ""
        opts.separator "Options:"
        opts.on("-m", "--maxlength RINGS", 
          "Maximum number of rings; if positive, count from the start, if negative, count from the end", Integer) do |val|
            @blocksize = val
        end
        opts.on_tail("-v", "--version", "Show version") do
          @errs.puts VERSION
          exit true
        end
        opts.on_tail("-h", "--help", "Show this message") do
          @errs.puts opts
          exit true
        end
      end
      begin
        @filelist = opt_parser.parse(args)
      rescue OptionParser::InvalidOption
        @errs.puts opt_parser.to_s
        exit false
      end
    end

    # Run an instance of the application, with the previously defined options.
    def run
      slist = []
      @filelist.each do |fname|
        err = Logger.new(fname, @errs)
        begin
          File.open(fname) do |infile|
            series = case
              when @blocksize == 0 then Series.new(File.basename(fname, '.*'), infile, err)
              when @blocksize < 0 then OuterSeries.new(File.basename(fname, '.*'), infile, err, @blocksize)
              else InnerSeries.new(File.basename(fname, '.*'), infile, err, @blocksize)
              end
            slist.push(series) if series.full_nrings > 0
          end
        rescue => fexcept
          # log the error but don't exit
          err.message "File error #{fexcept.class} #{fexcept.message}"
        end
      end
      drawing = Drawing.new(slist)
      drawing.draw(@outs)
    end
  end
end