require_relative "examples"

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

def can_place(placed,can)
  placed.all?{ |s| ! s.intersect?(can) }
end

class Placer
  def initialize
    @placed = []
    update_bottoms([0],[0])
  end

  def update_bottoms(re,im)
    @reals = re
    @imags = im
    c = @reals.flat_map{ |r| @imags.flat_map{ |i| r+i*1i } }
    @bottoms = c.sort_by{ |x| x.real+x.imag }
  end

  attr_reader( :placed )
  def place(size)
    @bottoms.each do |bottom|
      can = Square.new( bottom, size, 0 )
      if can_place(@placed, can)
        @placed << can
        reals = @reals | [can.top.real, can.bottom.real]
        imags = @imags | [can.top.imag, can.bottom.imag]
        if reals != @reals || imags != @imags
          update_bottoms( reals, imags )
        end
        break
      end
    end
  end
end

def placeSquares(sizes)
  placer = Placer.new
  sizes.each do |size|
    placer.place(size)
  end
  placer.placed
end

def solve(src)
  sizes = src.split(",").map(&:to_r)
  squares = placeSquares(sizes)
  m = squares.max_by{ |s| s.size }
  squares.select{ |s| m.neibour?(s) }.map{ |e| e.size.to_i }.sort.join(",")
end

if __FILE__==$0
  EXAMPLES.each do |e|
    p [e, solve(e)]
  end
end

