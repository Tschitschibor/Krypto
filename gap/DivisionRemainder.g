# calculate r0, r1 in [0..b-1] with
# b*r1 + r0 = a mod m.

DivRem := b -> function( a0, a1, m0, m1 )
  # addition
  # subtraction
  # multiplication
  #   mod b
  # [(x * y ) / b ]
  # [x / y ]
  # x,y in [0..b-1]
  # a < b, a<> b, a <= b
  if a1 <= m1 then
    if a0 <= m0 then
	  return [ a0, a1 ];
	else
	  return [ a0-m0, a1 ];
	fi;
  elif a0 >= m0 then
    return DivRem(b)( a0 - m0, a1 - m1, m0, m1 );
  else
    return DivRem(b)( b + a0 - m0, a1 - m1 - 1, m0, m1 );
  fi;
end;

SquareModbsq := b -> function( a0, a1 )
  
end;

MultModbsq := b -> function( a0, a1, m0, m1 )
  # a0*m0 = 1/2 * ( ( a0+m0 )^2 - a0^2 - m0^2 );
  
end;


