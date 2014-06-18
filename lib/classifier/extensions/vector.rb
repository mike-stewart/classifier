# Author::    Ernest Ellingson
# Copyright:: Copyright (c) 2005 

# These are extensions to the std-lib 'matrix' to allow an all ruby SVD

require 'matrix'
# require 'mathn'

class Array
  def sum(identity = 0, &block)
    return identity unless size > 0
  
    if block_given?
      map(&block).sum
    else
      reduce(:+)
    end
  end
end

class Vector
  def magnitude
    sumsqs = 0.0
    self.size.times do |i|
      sumsqs += power(self[i], 2.0)
    end
    Math.sqrt(sumsqs)
  end
  def normalize
    nv = []
    mag = self.magnitude
    self.size.times do |i|

      nv << self[i].quo(mag)

    end
    Vector[*nv]
  end

  def power(x,y)
    if x.kind_of?(Float)
      if x < 0 && y.round != y
        Complex(x, 0.0) ** y
      else
        x ** y
      end
    elsif x.kind_of?(Bignum) || x.kind_of?(Fixnum)
      if x < 0 && y.round != y
        Complex(x, 0.0) ** y
      else
        x ** y
      end
    elsif y.kind_of?(Rational)
      other2 = y
      if x < 0
        return Complex(x, 0.0) ** y
      elsif y == 0
        return Rational(1,1)
      elsif x == 0
        return Rational(0,1)
      elsif x == 1
        return Rational(1,1)
      end

      npd = numerator.prime_division
      dpd = denominator.prime_division
      if y < 0
        y = -y
        npd, dpd = dpd, npd
      end

      for elm in npd
        elm[1] = elm[1] * y
        if !elm[1].kind_of?(Integer) and elm[1].denominator != 1
          return power(Float(x), other2)
        end
        elm[1] = elm[1].to_i
      end

      for elm in dpd
        elm[1] = elm[1] * y
        if !elm[1].kind_of?(Integer) and elm[1].denominator != 1
          return power(Float(x), other2)
        end
        elm[1] = elm[1].to_i
      end

      num = Integer.from_prime_division(npd)
      den = Integer.from_prime_division(dpd)

      Rational(num,den)

    elsif y.kind_of?(Integer)
      if y > 0
        num = power(numerator, y)
        den = power(denominator, y)
      elsif y < 0
        num = power(denominator, -y)
        den = power(numerator, -y)
      elsif y == 0
        num = 1
        den = 1
      end
      Rational(num, den)
    elsif y.kind_of?(Float)
      power(Float(x), y)
    else
      x , y = y.coerce(self)
      power(x, y)
    end

  end

end

class Matrix
  def Matrix.diag(s)
     Matrix.diagonal(*s)
  end
  
  alias :trans :transpose

  def SV_decomp(maxSweeps = 20)
    if self.row_size >= self.column_size
      q = self.trans * self
    else
      q = self * self.trans
    end
    
    qrot    = q.dup
    v       = Matrix.identity(q.row_size)
    azrot   = nil
    mzrot   = nil
    cnt     = 0
    s_old   = nil
    mu      = nil

    while true do
      cnt += 1
      for row in (0...qrot.row_size-1) do
        for col in (1..qrot.row_size-1) do
          next if row == col
          a = (2 * qrot[row,col]).quo(qrot[row,row]-qrot[col,col])
          h = Math.atan(a)/2.0
          hcos = Math.cos(h)
          hsin = Math.sin(h)
          mzrot = Matrix.identity(qrot.row_size)
          mzrot[row,row] = hcos
          mzrot[row,col] = -hsin
          mzrot[col,row] = hsin
          mzrot[col,col] = hcos
          qrot = mzrot.trans * qrot * mzrot
          v = v * mzrot
        end 
      end
      s_old = qrot.dup if cnt == 1
      sum_qrot = 0.0 
      if cnt > 1
        qrot.row_size.times do |r|
          sum_qrot += (qrot[r,r]-s_old[r,r]).abs if (qrot[r,r]-s_old[r,r]).abs > 0.001
        end
        s_old = qrot.dup
      end 
      break if (sum_qrot <= 0.001 and cnt > 1) or cnt >= maxSweeps
    end # of do while true
    s = []
    qrot.row_size.times do |r|
      s << Math.sqrt(qrot[r,r])
    end
    #puts "cnt = #{cnt}"
    if self.row_size >= self.column_size
      mu = self *  v * Matrix.diagonal(*s).inverse     
      return [mu, v, s]
    else
      puts v.row_size
      puts v.column_size
      puts self.row_size
      puts self.column_size
      puts s.size

      mu = (self.trans * v *  Matrix.diagonal(*s).inverse)
      return [mu, v, s]
    end
  end
  def []=(i,j,val)
    @rows[i][j] = val
  end
end
