
# 011001 = 0.011001
bin2dec := function( bitstring )
    local len, k, res;
    len := Length( bitstring );
    res := 0;
    for k in [ 1 .. len ] do
        res := res + Int( bitstring{[ k ]} ) * 2 ^ (- k);
    od;
    return res;
end;

dec2bin := function( x )
  local bitstring, xnew, bit;
  xnew := Float(x);
  if xnew >= 1.0 then
    Error("Only x smaller than 1.");
  fi;
  bitstring := [];
  while xnew > 0.0 do
    xnew := 2*xnew;
    bit := Floor( xnew );
	if bit = 0.0 then
	  Add( bitstring, '0' );
	else
	  Add( bitstring, '1' );
	fi;
	xnew := xnew - bit;
  od;
  return bitstring;
end;

# Alphabet Sigma = {x1,...,xm} wird codiert
# als [1..m], wobei m < 10.
SFE_encode := function( Sigma, p )
  local g, m, q;
  m := Length( p );
  q := List( [1..m], i -> Sum( p{[1..i-1]} ) );
  g := function( i )
    local n, z, w, k, T, nu, y;
	n := Length( i );
	z := [1..n];
	w := [1..n];
	z[n] := q[i[n]];
	w[n] := p[i[n]];
	for k in Reversed([1..n-1]) do
	  z[k] := q[i[k]] + p[i[k]]*z[k+1];
	  w[k] := p[i[k]]*w[k+1];
	od;
	T := z[1] + 1/2*w[1];
	nu := Int( Ceil( 1 - Log2(Float(w[1])) ) );
	y := dec2bin(Float(T));
	if Length( y ) < nu then
      return Concatenation( y,
        List([1..nu-Length( y )], i-> '0') );
	else
      return y{[1..nu]};
	fi;
  end;
  return g;
end;

SFE_decode := function( Sigma, p, n )
  local h, m, q;
  m := Length( p );
  q := Concatenation(
    List( [1..m], i -> Sum( p{[1..i-1]} ) ),
	[1] );
  h := function( bitstring )
    local i, nu, u, k;
	nu := Length( bitstring );
	u := [1..n+1];
	i := [1..n];
	u[1] := bin2dec( bitstring );
	for k in [1..n] do
      i[k] := 1;
	  while not( q[i[k]] <= u[k]
	    and u[k] < q[i[k]+1]) do
	    i[k] := i[k]+1;
	  od;
	  u[k+1] := (u[k]-q[i[k]])/p[i[k]];
	od;
	return i;
  end;
  return h;
end;












