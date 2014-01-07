gem "minitest"
require "minitest/autorun"
require "stringio"
require_relative "../lib/rwtocore/series"

module RWTestData
  class RWBase
    attr_reader :slabel, :measurer, :mday, :innerdate, :widths
    
    def rwheader
      [@measurer, @mday, @innerdate.to_s].join("\r\n")
    end
    
    def rwvalues
      ((@widths.map { |w| w.to_s}) << Rwtocore::Series::EOS).join("\r\n ")
    end
    
    def rwfile
      StringIO.new([rwheader, rwvalues].join("\r\n "))
    end
  end
  
  class GoodData < RWBase
    def initialize
      @slabel = "BK-22"
      @measurer = "JSD"
      @mday = "09/05/2013"
      @innerdate = 1193
      @widths =
        [ 39, 60, 83, 113, 167, 83, 64,
          110, 93, 91, 150, 128, 117, 156, 110, 103, 172,
          186, 170, 186, 132, 84, 61, 34, 43, 80, 120,
          155, 84, 141, 143, 139, 119, 148, 30, 144, 90,
          101, 111, 155, 28, 129, 101, 69, 95, 121, 103,
          42, 98, 167, 103, 86, 100, 91, 40, 169, 129,
          81, 43, 77, 128, 23, 110, 130, 169, 27, 185,
          153, 118, 128, 22, 57, 108, 77, 102, 123, 118,
          87, 114]
    end                
  end
  
  class ExtraData < RWBase
    def initialize
      @slabel = "BK-102"
      @measurer = "JSD"
      @mday = "09/05/2013"
      @innerdate = 1196
      @widths =
        [ 236, 303, 111, 129,
          222, 167, 148, 172, 167, 42, 115, 72, 61, 202,
          131, 161, 127, 92, 29, 21, 22, 30, 25, 54,
          49, 31, 54, 76, 64, 32, 68, 8, 48, 54,
          47, 65, 92, 18, 57, 64, 36, 54, 75, 57,
          16, 55, 80, 63, 45, 61, 32, 19, 73, 64,
          42, 9, 36, 51, 7, 58, 54, 71, 17, 71,
          54, 42, 46, 19, 33, 60, 29, 45, 44, 65,
          31, 66, 65, 38, 34, 41, 16]
    end                
  end

  class BadData < RWBase
    def initialize
      @slabel = "BK-22-letters-for-numbers"
      @measurer = "JSD"
      @mday = "09/05/2013"
      @innerdate = 1193
      @widths =
        [ 39, "sixty", 83, 113, 167, 83, 64,
          "one_hundred_and_ten", 93, 91, "one_hundred_and_fifty", 128, 117, 156, "11O", "1O3", 172,
          186, "one_hundred_and_seventy", 186, 132, 84, 61, 34, 43, "eighty", "one_hundred_and_twenty",
          155, 84, 141, 143, 139, 119, 148, "thirty", 144, "ninety",
          "one_hundred_and_one", 111, 155, 28, 129, "1one_hundred_and_one", 69, 95, 121, "one_hundred_and_three",
          42, 98, 167, "one_hundred_and_three", 86, "one_hundred", 91, "forty", 169, 129,
          81, 43, 77, 128, 23, "one_hundred_and_ten", "one_hundred_and_thirty", 169, 27, 185,
          153, 118, 128, 22, 57, "one_hundred_and_eight", 77, "one_hundred_and_two", 123, 118,
          87, 114]
    end                
  end
  
  class BadDayData < RWBase
    def initialize
      @slabel = "BK-22-bad-measurement-date"
      @measurer = "JSD"
      @mday = "Thursday, the fifth of September, 2013"
      @innerdate = 1193
      @widths =
        [ 39, 60, 83, 113, 167, 83, 64,
          110, 93, 91, 150, 128, 117, 156, 110, 103, 172,
          186, 170, 186, 132, 84, 61, 34, 43, 80, 120,
          155, 84, 141, 143, 139, 119, 148, 30, 144, 90,
          101, 111, 155, 28, 129, 101, 69, 95, 121, 103,
          42, 98, 167, 103, 86, 100, 91, 40, 169, 129,
          81, 43, 77, 128, 23, 110, 130, 169, 27, 185,
          153, 118, 128, 22, 57, 108, 77, 102, 123, 118,
          87, 114]
    end                
  end

  class SpecifiedData < RWBase
    def initialize(*ringwidths)
      @slabel = "TestN=#{ringwidths.length}"
      @measurer = "XXX"
      @mday = "01/19/2038"
      @innerdate = 1001
      @widths = ringwidths
    end                
  end

end