EXAMPLE_INPUT="9,3,8,2,7,1"

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
      fill = {
        0 => "url(#normal)",
        1 => "url(#max)",
        2 => "url(#neibour)",
      }[e.bits]
      { p: e.corners.map{ |e| e*rot }, fill: fill }
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