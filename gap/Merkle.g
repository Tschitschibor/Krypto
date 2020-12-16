# (2.4.5) Merkles Metaverfahren
LoadPackage( "GaussForHomalg" );
LoadPackage( "FinSets" );

BinaryOfLength := function( n_, S )
  local n, i, L;
  L := [];
  n := n_;
  for i in [0..LogInt( n, 2 )] do
    L[i+1] := One(S)*(n mod 2);
    n := Int(n/2);
  od;
  return L;
end;

Merkle := function( S, k, m, n, x )
  local r, D, lx, ly, s, rem,
    xis, x_s, xs, xs1, a, i;
  r := m - n;
  if not 2^r - 1 >= n then
    Error( "m and n not suitable for Merkle Metaverfahren" );
  fi;
  D := Union( List( [0..(2^r - 1)], i -> AsList(S^i) ) );
  lx := Length( x );
  s := EuclideanQuotient( lx, r );
  # rem is length of last word in x of length 0 < rem <= r.
  rem := EuclideanRemainder( lx, r );
  # so if remainder 0 was calculated, correct both variables.
  if rem = 0 then
    rem := rem + 1;
    s := s - 1;
  fi;
  # xis = [x1,x2,...,x(s-1)]
  # jedes xi der Länge r
  # x1 = [ x[1], x[2], ..., x[0*r + (r-1)], x[r] ]
  # x2 = [ x[(2-1)*r + 1], ..., x[(2-1)*r + (r-1)] x[2*r] ]
  # ...
  # xi = [ x[(i-1)*r + 1], ..., x[(i-1)*r + j ]
  # ...
  # x(s-1) = [ x[(s-1)*r + 1], ...,
  #   x[(s-1)*r + (r-1)], x[s*r] ]
  # x = [ []
  xis := List( [1..s-1], i -> 
    List( [1..r], j -> x[(i-1)*r + j] ) );
  x_s := x{[(s-1)*r+1..(s-1)*r+rem]};
  # Concatenation( xis[1..s-1], x_s) = x
  # #! true
  xs := Concatenation( x_s, Zero( S^(r - rem ) ) );
  Add( xis, xs );
  xs1 := BinaryOfLength( lx, S );
  Add( xis, xs1 );
  a := [];
  a[1] := Zero( S^n );
  for i in [1..s+1] do # [1,2,3]
    a[i+1] := k(Concatenation( a[i],xis[i] ));
  od;
  return a[s+1];
  # h := MapOfFinSets( D, x -> h(x), S^n );
end;







