require_relative "solve"
require_relative "examples"

TITLE = "正方形を谷に詰める 2022.12.x"

SRange = Struct.new( :lo, :size ) do
  def hi; lo+size; end
  def intersect?(o)
    min = [lo, o.lo].max
    max = [hi, o.hi].min
    min<max
  end
  def touching?(o)
    lo==o.hi || hi==o.lo
  end
end

Square = Struct.new( :bottom, :size, :bits ) do
  def corners
    [bottom,right,top,left]
  end
  def top; bottom+size*(1+1i); end
  def right; bottom+size*(1); end
  def left; bottom+size*(1i); end
  def center; (bottom+top)/2; end
  def im_range; SRange.new(bottom.imag, size); end
  def re_range; SRange.new(bottom.real, size); end
  def intersect?(o)
    im_range.intersect?(o.im_range) && re_range.intersect?(o.re_range)
  end
  def neibour?(o)
    (im_range.intersect?(o.im_range) && re_range.touching?(o.re_range)) || 
    (re_range.intersect?(o.re_range) && im_range.touching?(o.im_range))
  end
end

def canPlace(placed,can)
  placed.all?{ |s| ! s.intersect?(can) }
end

def place( placed, size )
  (0...).each do |reim|
    (0..reim).each do |re|
      im = reim-re
      candidate = Square.new( re+im*1i, size, 0 )
      return candidate if canPlace(placed,candidate)
    end
  end
end

def placeSquares(sizes)
  sizes.each.with_object([]) do |size,o|
    o << place(o,size)
  end
end

def solve(src)
  sizes = src.split(",").map(&:to_r)
  squares = placeSquares(sizes)
  m = squares.max_by{ |s| s.size }
  r = squares.select{ |s| m.neibour?(s) }.map{ |e| e.size.to_i }.sort.join(",")
  $stderr.puts( {src:src, sizes:sizes, m:m, r:r}.inspect )
  r
end

def cpp_text
  EXAMPLES.each.with_index.inject("") do |acc,(ex,ix)|
    acc+"/*#{ix}*/ test( #{ex.inspect}, #{solve(ex).inspect} );\n"
  end
end

class Fig
  def initialize(src, w_in_pix)
    @w_in_pix = w_in_pix
    sizes = src.split(",").map(&:to_r)
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