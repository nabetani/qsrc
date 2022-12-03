EXAMPLE_INPUT="11/9,8,7,6,5,10,4,3,2,1"

def solve(s)
  "NOT_IMPL"
end

TITLE = "直角三角形を並べる 2022.12.x"

EXAMPLES = [
  EXAMPLE_INPUT,
]

Triangle = Struct.new( :pos, :h, :dir ) do
  def p0
    pos + h*(dir+dir*1i)
  end
  def p1
    pos + h*(dir-dir*1i)
  end
  def points
    [pos, p0, p1]
  end
end

class Fig
  def initialize(src, w_in_pix)
    @w=11
    @h=20
    @w_in_pix = w_in_pix
  end
  
  def pad; @w/10.0; end

  def triangles
    Array.new(5){ |ix|
      w = [*1..10][ix]
      x = (ix%3) + @w/2
      y = ix % 5
      dir = [1,-1,1i, -1i][ix%4]
      Triangle.new( x + y*1i, w, dir )
    }
  end

  def vbox
    "#{-pad} #{-pad} #{pad+@w} #{pad+@h}"
  end
  
  def pix_w
    "#{@w_in_pix}px"
  end

  def pix_h
    mw = @w + pad*2
    mh = @h + pad*2
    ph = @w_in_pix * mh / mw
    "#{ph}px"
  end

  def pix(x)
    mw = @w + pad*2
    x*1.0*mw/@w_in_pix

  end

  def rel_h( dw )
    dw / (@w+pad*2.0) * (@h+pad*2.0)
  end

end