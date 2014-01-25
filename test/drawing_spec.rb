#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'bundler/setup'

require "builder"
require "nokogiri"

require_relative "helper"
require_relative "../lib/rwtocore/messenger"
require_relative "../lib/rwtocore/drawing"

include Rwtocore

describe "Rwtocore::Drawing SVG ring image" do
  let(:good) { RWTestData::GoodData.new }
  let(:extra) { RWTestData::ExtraData.new }
  let(:errlog) { Messenger.new("Drawing test", StringIO.new) }
  let(:firsthorizontal) { /^[^H]*H(\d+)/o }
  let(:firstradius) { /^[^A]*A(\d+)/o }
  
  describe "using full series" do
    let(:svg) do
      drawing = Drawing.new([Series.new(good.slabel, good.rwfile, errlog),
                             Series.new(extra.slabel, extra.rwfile, errlog)])
      doc = String.new
      drawing.draw(doc)
      Nokogiri::XML(doc).at_xpath("//xmlns:svg")
    end

    it "must draw a SVG image" do
      svg.wont_be_nil
    end
   
    it "must draw latewood paths" do
      attrs = svg.xpath(".//xmlns:path").map { |p| p.attr("d") }
      attrs.wont_be_empty
    end
  
    it "puts the paths at the measured ring boundaries" do
      d = (svg.xpath("xmlns:g[1]/xmlns:g[2]/xmlns:path").map { |p| p.attr("d") }).each
      ringxpos = 0
      good.widths.each do |width|
        ringxpos += width
        latewoodend = firsthorizontal.match(d.next)[1].to_i
        latewoodend.must_equal ringxpos
      end
    end
  
    it "can draw more than one core" do
      d = (svg.xpath("xmlns:g[2]/xmlns:g[2]/xmlns:path").map { |p| p.attr("d") }).each
      ringxpos = 0
      extra.widths.each do |width|
        ringxpos += width
        latewoodend = firsthorizontal.match(d.next)[1].to_i
        latewoodend.must_equal ringxpos
      end
    end
    
    it "draws ring radii that match the cumulative width" do
      d = (svg.xpath("xmlns:g[1]/xmlns:g[2]/xmlns:path").map { |p| p.attr("d") }).each
      cumwidth = 0
      good.widths.each do |width|
        cumwidth += width
        ring_radius = firstradius.match(d.next)[1].to_i
        ring_radius.must_equal cumwidth
      end
    end
  
    it "draws a background rectangle the same size as the core" do
      svg.at_xpath("xmlns:g[1]/xmlns:g[2]/xmlns:rect")["width"].to_i.must_equal good.widths.inject { |d, w| d + w }
    end
    
  end
  
  describe "using offset series" do
    let(:blocksize) { 25 }
    let(:offsvg) do
      drawing = Drawing.new([OuterSeries.new(good.slabel, good.rwfile, errlog, blocksize),
                             OuterSeries.new(extra.slabel, extra.rwfile, errlog, blocksize)])
      doc = String.new
      drawing.draw(doc)
      Nokogiri::XML(doc).at_xpath("//xmlns:svg")
    end
  
    it "draws boundaries like a full series" do
      d = (offsvg.xpath("xmlns:g[2]/xmlns:g[2]/xmlns:path").map { |p| p.attr("d") }).each
      ringxpos = 0
      extra.widths.last(blocksize).each do |width|
        ringxpos += width
        latewoodend = firsthorizontal.match(d.next)[1].to_i
        latewoodend.must_equal ringxpos
      end
    end
    
    it "draws ring radii centered on a notional pith position" do
      d = (offsvg.xpath("xmlns:g[1]/xmlns:g[2]/xmlns:path").map { |p| p.attr("d") }).each
      cumwidth = good.widths.first(good.widths.length - blocksize).inject {|tot, rw| tot + rw }
      good.widths.last(blocksize).each do |width|
        cumwidth += width
        ring_radius = firstradius.match(d.next)[1].to_i
        ring_radius.must_equal cumwidth
      end
    end
  end
  
  describe "drawing latewood bands" do
    let(:totlen) { 1000 }
    let(:transition) { Float(totlen * Drawing::DEPTH) / Float(Drawing::WIDTH - Drawing::MARGIN) }
    let(:horizontal_arc_vertical_arc) { /M[0-9,. ]+H[0-9,. ]+A[0-9,. ]+V[0-9,. ]+A[0-9,. ]+Z/ }
    let(:horizontal_arc_corner_arc) { /M[0-9,. ]+H[0-9,. ]+A[0-9,. ]+H0\s+V[0-9,. ]+A[0-9,. ]+Z/ }
    let(:horizontal_arc_horizontal_arc) { /M[0-9,. ]+H[0-9,. ]+A[0-9,. ]+H[0-9,. ]+A[0-9,. ]+Z/ }
    
    describe "for normal series" do
      let(:svg4ring) do
        rw_0 = (transition/2).round
        rw_1 = (9*transition/16).round
        rw_3 = rw_2 = ((totlen - (rw_0 + rw_1))/2).round
        fourring = RWTestData::SpecifiedData.new(rw_0, rw_1, rw_2, rw_3)
        drawing = Drawing.new([Series.new(fourring.slabel, fourring.rwfile, errlog)])
        doc = String.new
        drawing.draw(doc)
        Nokogiri::XML(doc).at_xpath("//xmlns:svg/xmlns:g[1]/xmlns:g[2]")
      end
    
      it "draws small initial latewood bands on the left edge" do
        svg4ring.at_xpath("xmlns:path").attr("d").must_match horizontal_arc_vertical_arc
      end
    
      it "draws the corner when a latewood band intersects it" do
        svg4ring.at_xpath("xmlns:path[2]").attr("d").must_match horizontal_arc_corner_arc
      end

      it "draws most latewood bands on the lower edge" do
        svg4ring.at_xpath("xmlns:path[3]").attr("d").must_match horizontal_arc_horizontal_arc
      end
    end
    
    describe "for offset series" do
      let(:svgoffring) do
        rw_0 = totlen/3
        t_off = Math::sqrt(rw_0**2 + transition**2) - rw_0
        rw_1 = (t_off/2).round
        rw_2 = (9*t_off/16).round
        rw_4 = rw_3 = ((totlen - (rw_1 + rw_2))/2).round
        fivering = RWTestData::SpecifiedData.new(rw_0, rw_1, rw_2, rw_3, rw_4)
        drawing = Drawing.new([OuterSeries.new(fivering.slabel, fivering.rwfile, errlog, 4)])
        doc = String.new
        drawing.draw(doc)
        Nokogiri::XML(doc).at_xpath("//xmlns:svg/xmlns:g[1]/xmlns:g[2]")
      end
      
      it "draws small initial latewood bands on the left edge" do
        svgoffring.at_xpath("xmlns:path").attr("d").must_match horizontal_arc_vertical_arc
      end
    
      it "draws the corner when a latewood band intersects it" do
        svgoffring.at_xpath("xmlns:path[2]").attr("d").must_match horizontal_arc_corner_arc
      end

      it "draws most latewood bands on the lower edge" do
        svgoffring.at_xpath("xmlns:path[3]").attr("d").must_match horizontal_arc_horizontal_arc
      end
      
    end
  end
end