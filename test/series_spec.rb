#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'bundler/setup'

require_relative "helper"
require_relative "../lib/rwtocore/messenger"

include Rwtocore

describe "Series" do
  
  let(:good) { RWTestData::GoodData.new }
  let(:errlog) { Messenger.new("Series test", StringIO.new) }
  let(:blocksize) { 25 }
  let(:sublength) { blocksize < good.widths.length ? blocksize : good.widths.length }
  
  describe "Rwtocore::Series entire series" do
    let(:series) { Series.new(good.slabel, good.rwfile, errlog) }
  
    it "takes its name from the initial label" do
      series.name.must_equal good.slabel
    end
  
    it "has the measurer initials" do
      series.initials.must_equal good.measurer
    end
  
    it "has the meaurement date string" do
      series.measured.must_equal good.mday
    end
  
    it "has the correct starting date" do
      series.start_date.must_equal good.innerdate
    end

    it "records incremental measurements" do
      s = series.rings
      good.widths.each do |width|
        s_incr, s_abs = s.next
        s_incr.must_equal width
      end
    end
  
    it "records cumulative measurements" do
      series.offset.must_equal 0
      s = series.rings
      disp = good.widths.inject(0) do |d, w|
        s_incr, s_abs = s.next
        s_abs.must_equal d
        d + w
      end
      series.total.must_equal disp
    end
    
    it "has all the measurements" do
      series.full_nrings.must_equal good.widths.length
    end
  end
  
  describe "Rwtocore::InnerSeries initial sub-series" do
    let(:series) { InnerSeries.new(good.slabel, good.rwfile, errlog, blocksize) }

    it "contains the initial sub-series incremental measurements" do
      i, s, width = sublength, series.rings, good.widths.each
      while i > 0 do
        s_incr, s_abs = s.next
        s_incr.must_equal width.next
        i -= 1
      end
    end
    
    it "contains the initial sub-series cumulative measurements" do
      series.offset.must_equal 0
      disp, i, s, width = 0, sublength, series.rings, good.widths.each
      while i > 0 do
        s_incr, s_abs = s.next
        s_abs.must_equal disp
        disp, i = disp + width.next, i - 1
      end
      series.total.must_equal disp
    end
  end
  
  describe "Rwtocore::OuterSeries final sub-series" do
    let(:series) { OuterSeries.new(good.slabel, good.rwfile, errlog, blocksize) }

    it "contains the final sub-series incremental measurements" do
      i, s, width = sublength, series.rings, good.widths.last(sublength).each
      while i > 0 do
        s_incr, s_abs = s.next
        s_incr.must_equal width.next
        i -= 1
      end
    end
    
    it "contains the final sub-series cumulative measurements" do
      skiplength, skipdisp = good.widths.length - sublength, 0
      while skiplength > 0
        skiplength -= 1
        skipdisp += good.widths[skiplength]
      end
      series.offset.must_equal skipdisp
      disp, i, s, width = skipdisp, sublength, series.rings, good.widths.last(sublength).each
      while i > 0 do
        s_incr, s_abs = s.next
        s_abs.must_equal disp
        disp, i = disp + width.next, i - 1
      end
      series.total.must_equal disp - skipdisp
    end
  end
  
  describe "Rwtocore::Series data format checks" do

    it "rejects data files with malformed headers" do
      badday = RWTestData::BadDayData.new
      errs = StringIO.new
      Series.new(badday.slabel, badday.rwfile, Messenger.new("Date format test", errs))
      errs.string.must_match /unexpected format/i
    end

    it "rejects data files with non-numeric measurements" do
      baddata = RWTestData::BadData.new
      errs = StringIO.new
      Series.new(baddata.slabel, baddata.rwfile, Messenger.new("Series data test", errs))
      errs.string.must_match /expected a number/i
    end
  end
end

