require_relative "solve"
require_relative "examples"

TITLE = "正方形を谷に詰める 2023.04.16"

def cpp_text
  EXAMPLES.each.with_index.inject("") do |acc,(ex,ix)|
    acc+"/*#{ix}*/ test( #{ex.inspect}, #{solve(ex).inspect} );\n"
  end
end

class Fig
  def initialize(src, w_in_pix)
    @w_in_pix = w_in_pix
    sizes = src.split(",").map(&:to_i)
    @squares = placeSquares(sizes)
    m = @squares.max_by{ |s| s.size }
    m.bits = 1
    @squares.each do |s|
      s.bits |= 2 if m.neibour?(s)
    end
    points = @squares.flat_map{ |s| s.corners.map{ |e| rot(e) }}
    @yrange = points.map{ |s| s.imag }.minmax
    @ysize = @yrange[1]-@yrange[0]
    @xrange = points.map{ |s| s.real }.minmax
    @xsize = @xrange[1]-@xrange[0]
    @w = [@ysize, @xsize].min
  end
  
  def rot(e); (e*(0.5+0.5i)).conjugate; end

  def pad; @w/10.0; end

  def squares
    @squares.map{ |e|
      fill = {
        0 => "url(#normal)",
        1 => "url(#max)",
        2 => "url(#neibour)",
      }[e.bits]
      fontsize = e.size*0.75 / [e.size.to_i.to_s.size,3].max
      c = rot(e.center) + fontsize  * 0.5i
      { 
        p: e.corners.map{ |e| rot(e) }, 
        fill: fill,
        fontsize: fontsize,
        tx:c.real, 
        ty:c.imag,
        size:e.size.to_i,
      }
    }
  end

  def vbox
    [-pad+@xrange[0], -pad+@yrange[0], pad*2+@xsize, pad*2+@ysize].map(&:to_f).join(" ")
  end
  
  def pix_w
    "#{@w_in_pix.to_f}px"
  end

  def pix_h
    mw = @xsize + pad*2
    mh = @ysize + pad*2
    ph = @w_in_pix * mh / mw
    "#{ph.to_f}px"
  end

  def pix(x)
    mw = @w + pad*2
    x*1.0*mw/@w_in_pix
  end

end