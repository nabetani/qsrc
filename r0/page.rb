EXAMPLE_INPUT="9,3,8,2,7,1"

def solve(s)
  "NOT_IMPL"
end

TITLE = "正方形を谷に詰める 2022.12.x"

rng = Random.new(1)

EXAMPLES = [
  EXAMPLE_INPUT,
  [*1..20].shuffle(random:rng).join(","),
  [*1..20].shuffle(random:rng).join(","),
  [*1..20].shuffle(random:rng).join(","),
  [*1..20].shuffle(random:rng).join(","),
]
SRange = Struct.new( :lo, :size ) do
  def hi; lo+size; end
  def intersect?(o)
    min = [lo, o.lo].max
    max = [hi, o.hi].min
    0<max-min
  end
end

Square = Struct.new( :bottom, :size, :bits ) do
  def corners
    [bottom,right,top,left]
  end
  def top; bottom+size*(1+1i); end
  def right; bottom+size*(1); end
  def left; bottom+size*(1i); end
  def im_range; SRange.new(bottom.imag, size); end
  def re_range; SRange.new(bottom.real, size); end
  def intersect?(o)
    im_range.intersect?(o.im_range) && re_range.intersect?(o.re_range)
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

class Fig
  def initialize(src, w_in_pix)
    @w_in_pix = w_in_pix
    sizes = src.split(",").map(&:to_r)
    @squares = placeSquares(sizes)
    points = @squares.flat_map{ |s| s.corners.map{ |e| e*rot }}
    @yrange = points.map{ |s| s.imag }.minmax
    @ysize = @yrange[1]-@yrange[0]
    @xrange = points.map{ |s| s.real }.minmax
    @xsize = @xrange[1]-@xrange[0]
    @w = [@ysize, @xsize].min
  end
  
  def rot; 0.5+0.5i; end

  def pad; @w/10.0; end

  def squares
    @squares.map{ |e|
      e.corners.map{ |e| e*rot }
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