# -*- coding: utf-8 -*-

require "builder"

module Rwtocore
  # Stylized images of tree-ring core samples in SVG format, with Builder
  # doing the useful work of generating the XML text output.
  class Drawing
    # Default namespace for the SVG document
    # @see http://www.w3.org/TR/2011/REC-SVG11-20110816/struct.html
    NAMESPACE = "http://www.w3.org/2000/svg"
    
    # SVG language version for the document
    VERSION = "1.1"
    
    # Minimum horizontal coordinate for the top-level viewport
    MIN_X = 0
    
    # Minimum vertical coordinate for the top-level viewport
    MIN_Y = 0
    
    # Maximum horizontal coordinate for the top-level viewport in scaled units
    WIDTH = 3118
    
    # Maximum vertical coordinate for the top-level viewport in scaled units
    HEIGHT = 2362
    
    # Amount of whitespace around the core crawings
    MARGIN = 150
    
    # Vertical extent of a core drawing
    DEPTH = 150
    
    # Verical extent of a core drawing plus vertical whitespace
    PANELDEPTH = 200
    
    # Text size, for font size in points & positioning
    TSIZE = 24
    
    # Units for page dimensions
    PHYSICAL_UNITS = "mm"
    
    # Fixed page width in physical units
    PHYSICAL_WIDTH = 264
    
    # Derive the fixed scale from the two fixed units already defined
    PHYSICAL_SCALE = Float(PHYSICAL_WIDTH)/WIDTH
    
    # Page height in physical units
    PHYSICAL_HEIGHT = HEIGHT * PHYSICAL_SCALE

    # Set up tree-ring width measurements for drawing as simulated cores.
    # @param [Array<Series>] serieslist the list of measurement series to draw
    def initialize(serieslist)
      @slist = serieslist
      @yscale = (@slist.length*PANELDEPTH < HEIGHT) ? 1 : HEIGHT/(Float(@slist.length*PANELDEPTH))
      @spacing = PANELDEPTH*@yscale
    end
    
    # Write a complete SVG document containing all the core drawings.
    # A single filled rectangle represents the earlywood of all the rings in a core;
    # circular arcs drawn on top of this represent the latewood of the rings. The latewood
    # width is currently just a fixed fraction of the total ring width. The radius of each
    # latewood arc comes directly from the value in the representation of the measurement
    # series, and the arcs are centered on a notional pith position aligned with the top
    # edge of the core drawing. In the simplest case the center of all the rings is at the
    # top left corner, but it may be displaced to the left of this. The arcs are explicitly
    # clipped to the boundaries of the underlying (earlywood) rectangle; they always descend
    # from the top edge of the core drawing, and will generally extend to the lower edge, but
    # rings near the center may have radii less than the vertical size of the core, and curve
    # around to intersect the left edge. Note that we have to deal with a literal corner case,
    # when the arcs bounding the latewood band straddle the lower left corner.
    # @param [#<<] stream the destination of the output
    def draw(stream)
      @xml = Builder::XmlMarkup.new(:target=>stream, :indent=>2)
      @xml.instruct!
      @xml.declare! :DOCTYPE, :svg, :PUBLIC, "-//W3C//DTD SVG 1.1//EN", "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"
      @xml.svg(:width=>"#{PHYSICAL_WIDTH}#{PHYSICAL_UNITS}",
              :height=>"#{PHYSICAL_HEIGHT}#{PHYSICAL_UNITS}",
              :viewBox=>"#{MIN_X} #{MIN_Y} #{WIDTH} #{HEIGHT}",
              :xmlns=>NAMESPACE,
              :version=>VERSION) do |page|
        @slist.each_with_index do |series, i|
          page.g(:transform=>"translate(#{MARGIN}, #{i * @spacing})") do |panel|
            panel.g(:transform=>"scale(#{@yscale})") do |caption|
              caption.text(:x=>"-#{TSIZE}",
                           :y=>"#{MARGIN}",
                           :'font-size'=>"#{TSIZE}",
                           :'font-family'=>"Verdana",
                           :'text-anchor'=>"end") do |textlabel|
                textlabel.text! series.name
              end
            end
            widthscale = Float(WIDTH - MARGIN)/series.total
            boxdepth = DEPTH/widthscale
            panel.g(:transform=>"scale(#{widthscale})") do |core|
              core.rect(:x=>"0", :y=>"0", :width=>"#{series.total}", :height=>"#{boxdepth}", :fill=>"goldenrod")
              cx = (-series.offset).to_s
              series.rings.inject(0) do |x, ring|
                ring_width, ring_start = ring
                ew_width = 0.75 * ring_width
                r_e, r_w = ring_start + ew_width, ring_start + ring_width
                p_a_x, p_b_x = x + ew_width, x + ring_width
                data = "M#{p_a_x},0 H#{p_b_x} A#{r_w},#{r_w} 0 0,1 "
                data << case
                when r_w <= boxdepth
                  p_c_y, p_d_y = Math.sqrt(r_w**2 - series.offset**2), Math.sqrt(r_e**2 - series.offset**2)
                  "0,#{p_c_y} V#{p_d_y} A#{r_e},#{r_e} 0 0,0 "
                when r_e > boxdepth && Math.sqrt(r_e**2 - boxdepth**2) > series.offset
                  p_c_x, p_d_x = Math.sqrt(r_w**2 - boxdepth**2) - series.offset, Math.sqrt(r_e**2 - boxdepth**2) - series.offset
                  "#{p_c_x},#{boxdepth} H#{p_d_x} A#{r_e},#{r_e} 0 0,0 "
                when Math.sqrt(r_w**2 - boxdepth**2) <= series.offset
                  p_c_y, p_d_y = Math.sqrt(r_w**2 - series.offset**2), Math.sqrt(r_e**2 - series.offset**2)
                  "0,#{p_c_y} V#{p_d_y} A#{r_e},#{r_e} 0 0,0 "
                else
                  p_c_x, = Math.sqrt(r_w**2 - boxdepth**2) - series.offset
                  p_d_y = Math.sqrt(r_e**2 - series.offset**2)
                  "#{p_c_x},#{boxdepth} H0 V#{p_d_y} A#{r_e},#{r_e} 0 0,0 "
                end
                data << "#{p_a_x},0 Z"
                core.path(:d=>data, :'stroke'=>"none", :fill=>"saddlebrown")
                p_b_x
              end
            end
          end
        end
      end
    end
  end
end