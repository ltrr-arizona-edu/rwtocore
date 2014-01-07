#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

gem "minitest"
require "minitest/autorun"
require "stringio"

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(string)
      require File.join(File.dirname(caller.first), string)
    end
  end
end

require_relative "../lib/rwtocore/cli.rb"
include Rwtocore

describe "Rwtocore::CLI" do
  let(:progname) { "our proper name" }
  let(:usagepat) { /^Usage: #{progname}/o }
  let(:versionpat) { v = VERSION.split(".").join('\.') ; /#{v}/o }
  let(:filenames) { %w(file00.rw file01.rw file02.rw) }
  let(:helpargs) { %w(--help) }
  let(:versionargs) { %w(-v) }
  let(:posblock) { 50 }
  let(:negblock) { -120 }
  let(:goodargslong) { ["--maxlength", posblock.to_s] + filenames }
  let(:goodargsshort) { ["-m", posblock.to_s] + filenames }
  let(:goodargsneg) { ["-m", negblock.to_s] + filenames }
  let(:badargs) { %w(--omicron 570) }
  let(:messagestream) { StringIO.new }
  let(:dummystream) { StringIO.new }
  
  it "returns successfully when given the help option" do
    ok = false
    begin
      prog = CLI.new(progname, helpargs, dummystream, messagestream)
    rescue SystemExit => xx
      ok = xx.success?
    end
    ok.must_equal true
  end

  it "emits usage text when given the help option" do
    begin
      prog = CLI.new(progname, helpargs, dummystream, messagestream)
    rescue SystemExit
    end
    messagestream.rewind
    messagestream.read.must_match(usagepat)
  end
  
  it "returns successfully when given the version option" do
    ok = false
    begin
      prog = CLI.new(progname, versionargs, dummystream, messagestream)
    rescue SystemExit => xx
      ok = xx.success?
    end
    ok.must_equal true
  end

  it "emits the version number when given the version option" do
    begin
      prog = CLI.new(progname, versionargs, dummystream, messagestream)
    rescue SystemExit
    end
    messagestream.rewind
    messagestream.read.must_match(versionpat)
  end
  
  it "returns unsuccessfully when given bad arguments" do
    ok = true
    begin
      prog = CLI.new(progname, badargs, dummystream, messagestream)
    rescue SystemExit => xx
      ok = xx.success?
    end
    ok.must_equal false
  end

  it "emits usage text when given bad arguments" do
    begin
      prog = CLI.new(progname, badargs, dummystream, messagestream)
    rescue SystemExit
    end
    messagestream.rewind
    messagestream.read.must_match(usagepat)
  end

  it "records additional arguments as file paths" do
    prog = CLI.new(progname, goodargslong, dummystream, messagestream)
    paths = prog.filelist
    filenames.each do |f|
      f.must_equal(paths.shift)
    end
  end

  it "records a subseries length for verbose options" do
    prog = CLI.new(progname, goodargslong, dummystream, messagestream)
    prog.blocksize.must_equal(posblock)
  end

  it "records a subseries length for abbreviated options" do
    prog = CLI.new(progname, goodargsshort, dummystream, messagestream)
    prog.blocksize.must_equal(posblock)
  end

  it "records negative subseries lengths" do
    prog = CLI.new(progname, goodargsneg, dummystream, messagestream)
    prog.blocksize.must_equal(negblock)
  end
end