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
  squares.select{ |s| m.neibour?(s) }.map{ |e| e.size.to_i }.sort.join(",")
end

if __FILE__==$0
  EXAMPLES.each do |e|
    p [e, solve(e)]
  end
end

