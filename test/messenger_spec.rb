#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

gem "minitest"
require "minitest/autorun"
require "stringio"

require_relative "../lib/rwtocore/messenger.rb"
include Rwtocore

describe Rwtocore::Messenger do
  
  let(:proglabel) { "Your Program Name Here" }
  let(:progpat) { Regexp.new(proglabel) }
  let(:logstream) { StringIO.new }
  let(:log) { Messenger.new(proglabel, logstream) }
  let(:firsttext) { "The first craw was greetin for his ma" }
  let(:secondtext) { ["The second craw", Messenger::SEP, "fell and broke his jaw"].join('') }
  let(:thirdtext) { ["The third craw", Messenger::TERM, " Couldnae flee at a"].join('') }
  
  it "prefixes the program name" do
    log.message(firsttext)
    logstream.rewind
    labelfield, messagefield = logstream.string.split(Messenger::SEP, 2)
    labelfield.must_match(progpat)
  end
  
  it "appends the message text" do
    log.message(firsttext)
    logstream.rewind
    labelfield, messagefield = logstream.string.split(Messenger::SEP, 2)
    (messagefield.slice(0, messagefield.rindex(Messenger::TERM))).must_equal(firsttext)
  end
  
  it "emits the same prefix on multiple log entries" do
    log.message(firsttext)
    log.message(secondtext)
    log.message(thirdtext)
    logstream.rewind
    logstream.each do |logentry|
      labelfield, messagefield = logentry.split(Messenger::SEP, 2)
      labelfield.must_match(progpat)
    end
  end
  
  it "emits distict messages in multiple log entries"  do 
    log.message(firsttext)
    log.message(secondtext)
    log.message(thirdtext)
    texts = [firsttext, secondtext, thirdtext]
    logstream.rewind
    logstream.each do |logentry|
      labelfield, messagefield = logentry.split(Messenger::SEP, 2)
      (messagefield.slice(0, messagefield.rindex(Messenger::TERM))).must_equal(texts.shift)
    end
  end
end