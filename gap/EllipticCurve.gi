LoadPackage( "GaussForHomalg" );

FloorHalfInt := function( n );
  if n mod 2 = 0 then
    return n / 2;
  else
    return (n-1)/2;
  fi;
end;

# Fast Exponentiation (2.1.16)
# (to be used in place of gap's internal a^n mod m routine)
# (relies on gap's internal a*b mod m routine)
fex := function( a, n, m )
  local p0, n0, a0;
  p0 := 1;
  a0 := a;
  n0 := n;
  while n0 > 0 do
    if (n0 mod 2 = 1) then
      p0 := p0*a0 mod m;
    fi;
    a0 := a0*a0 mod m;
    # n0 := Int( Floor( Float( n0/2) ) );
	n0 := FloorHalfInt( n0 );
  od;
  return p0;
end;

### prime number test stuff ###
#
MillerRabinTest := function( n, k )
local MR, d, s, a, x, i, j;
MR := false;
d := n-1;
s := 0;
while d mod 2 = 0 do
  d := d/2;
  s := s+1;
od;
# vector x:
x := [];
# repeated M-R tests for (1/4)^(k) 
# failure probability.
for i in [1..k] do
  # rndsource := RandomSource( IsMersenneTwister, 584 );;
  # a := Random( rndsource, [2..n-2] );
  a := Random( [2..n-2] );
  # x[1] := a^d mod n;
  x[1] := fex( a, d, n );
  for j in [2..s-1] do
    # x[j] := x[j-1]^2 mod n;
	x[j] := fex( x[j-1], 2, n );
  od;
  ## Now the statement Miller-Rabin (MR):
  ## "x[1] = 1 or exists i in [1..s-1] such that
  ##  x[i] = n - 1"
  ## is always true for n prime, but only true with
  ## probability 1/4 for n not prime.
  # P( n prime AND MR true ) = 1
  # P( n prime AND MR false ) = 0 <-- easy exclude
  # P( n not prime AND MR true ) = 1/4 <-- LYER
  # P( n not prime AND MR false ) = 3/4
  ## so M-R is a good test to exclude non-primes.
  # ( using built-in membership function "in" )
  MR := (x[1] = 1) or (n-1 in x);
  if not MR then
    return false; # easy exclude
  fi;
od;
return MR;
end;

MRT := function( n, k )
  return MillerRabinTest( n, k );
end;

## Miller-Rabin prime generator [a,b]
MillerRabinGenerator := function( low, high, k )
local rndsource, MR, n, d, s, a, x, i, j;
## Randomness
#rndsource := RandomSource( IsMersenneTwister, 584 );;
MR := false;
repeat
 repeat
  #n := Random( rndsource, low, high );
  n := Random( low, high );
 until n mod 2 = 1;
## n is odd.
#
## s, d such that:
## n = 2^s*d+1;
## n-1 = 2^s*d;
d := n-1;
s := 0;
repeat
  d := d/2;
  s := s+1;
until d mod 2 = 1;
# vector x:
x := [];
# repeated M-R tests for (1/4)^(k) 
# failure probability.
for i in [1..k] do
  # a := Random( rndsource, [2..n-2] );
  a := Random( [2..n-2] );
  # x[1] := a^d mod n;
  x[1] := fex( a, d, n );
  for j in [2..s-1] do
    # x[j] := x[j-1]^2 mod n;
	x[j] := fex( x[j-1], 2, n );
  od;
  ## Now the statement Miller-Rabin (MR):
  ## "x[1] = 1 or exists i in [1..s-1] such that
  ##  x[i] = n - 1"
  ## is always true for n prime, but only true with
  ## probability 1/4 for n not prime.
  # P( n prime AND MR true ) = 1
  # P( n prime AND MR false ) = 0 <-- easy exclude
  # P( n not prime AND MR true ) = 1/4 <-- LYER
  # P( n not prime AND MR false ) = 3/4
  ## so M-R is a good test to exclude non-primes.
  # ( using built-in membership function "in" )
  MR := (x[1] = 1) or (n-1 in x);
  if not MR then
    break; # easy exclude
  fi;
od;
## after k M-R tests, MR should be true,
## if they all passed.
## if not, this n is bad, try new number.
until MR;
## found an n that has passed all k MR tests.
return n; # n is prime with probability (3/4)^(k)
end;
#
MRG := function( low, high, k )
  return MillerRabinGenerator( low, high, k );
end;
######

ElGamalZp := function( n )
local p, a, k, z, key,
f, q, m;
## Bob chooses prime number
## Bob chooses primitive root
# instead
# Bob chooses pair (m, a) of
# prime number and primitive root:
# Bertrand: find prime p : n <= p <= 2n
# (Miller-Rabin-Test, 10 iterations)
# 2.2.3
# easy-to-factor-number f
f := 2;
# 2
repeat
  # prime q
  q := MRG( n, 2*n, 10 );
  m := f*q + 1;
until MRT( m, 10 );
for a in [2..m-1] do
  # if a^f mod m <> 1 and a^q mod m <> 1 then
  if fex( a, f, m ) <> 1 and fex( a, q, m ) <> 1 then
    break;
  fi;
od;
p := m;
## p is prime and
## a is primitive root.
key := rec();
## Bob chooses secret key
repeat
  k := Random( [0..p-2] );
until k >= n/2;
key.private := k;
## Bob calculates public key
# z := a^k mod p;
z := fex( a, k, p );
key.public := [ p, a, z ];
return key;
end;

### Elliptic curve stuff
defines_ellipse := function( a4, a6, F, p )
  return IsField( F ) and
    Characteristic( F ) <> 2 and
    Characteristic( F ) <> 3 and
	One( F )*(4*a4^3 + 27*a6^2) <> One( F )*0;
end;

ellipse_membership := function( P, a4, a6, F, p )
  local Px, Py;
  if IsZero( P ) then
    return true;
  fi;
  Px := P[1];
  Py := P[2];
  return One(F)*(Py^2) = One(F)*(Px^3 + a4*Px + a6);
end;

Ellipse := function( a4, a6, F, p )
  local El, IsFinite;
  if not defines_ellipse( a4, a6, F, p ) then
    Error("Inputs don't define an elliptic curve.\n");
  else
    if IsFFE( One(F) ) then
	  IsFinite := "finite ";
	else
	  IsFinite := " ";
	fi;
    El := rec();
	El.description := Concatenation(
	  "An elliptic curve over the ",
	  IsFinite,
	  "field ",
	  String(F),
	  " with coefficients a4 = ",
	  String(a4),
	  " and a6 = ",
	  String(a6) );
	El.a4 := a4;
	El.a6 := a6;
	El.field := F;
	return El;
  fi;
end;

EllipsePoint := function( P, a4, a6, F, p )
  local eP;
  if not ellipse_membership( P, a4, a6, F, p ) then
    Error( "Point P = ",P," does not lie on elliptic curve\n");
  else
    eP := rec();
	eP.ellipse := Ellipse( a4, a6, F, p );
	eP.x := One(eP.ellipse.field)*eP.Px;
	eP.y := One(eP.ellipse.field)*eP.Py;
    return eP;
  fi;
end;

EP := function( P, a4, a6, F, p )
  return EllipsePoint( P, a4, a6, F, p );
end;

NeutralElement := function( a4, a6, F, p )
  return 0;
end;

PointOnEllipticCurve := function( a4, a6, F, p )
  local Px, Pysq, Py, P;
  # statt
  # One(F)*(Py^2) = One(F)*(Px^3 + a4*Px + a6);
  # mit quadratischer reziprozitaet:
  # Random Px in F
  # Berechne Pysq := Px^3 + a4*Px + a6
  # Check ob Pysq quadratischer Rest mod p sein kann
  # Dies liefert die Legendre-Funktion
  # Falls nein, neues Px
  # Falls ja (und p mod 4 = 3), ist
  # Py = Pysq^(1/2)
  # = +/- Pysq^( (p+1)/4 ) mod p;
  #
  repeat
    Px := Int( Random( F ) );
    Pysq := Int( One(F)*(fex( Px, 3, p ) + a4*Px + a6) );
  until Legendre( Pysq, p ) = 1;
  # Pysq is a square mod p
  Py := fex( Pysq, Int((p+1)/4), p );
  # Py := RootMod( Pysq, p );
  P := [ One(F)*Px, One(F)*Py ];
  if not ellipse_membership( P, a4, a6, F, p ) then
    Error("Point does not lie on curve.\n");
  fi;
  return P;
end;

ellipticCurve := function( a4, a6, F, p )
  if not defines_ellipse( a4, a6, F, p ) then
    Error("Inputs don't define an elliptic curve.\n");
  fi;
  if not IsFinite( F ) then
    Error("Infinite field can't be converted to list.\n");
  fi;
##  lol, waaay too slow:
##  return Filtered( Union( 
##    Cartesian( AsList( F ), AsList( F ) ),
##    [ 0 ] ),	
##    xy -> ellipse_membership( xy, a4, a6, F, p ) );
# most times we don't even want to calculate the whole
# elliptic curve. A point on the curve with a 
# high-enough order is enough.
end;

ast := function( P, Q, a4, a6, F, p )
  local Px, Qx, Py, Qy, a, Rx, Ry, R;
  if not defines_ellipse( a4, a6, F, p ) then
    Error("Inputs don't define an elliptic curve.\n");
  fi;
  if not ellipse_membership( P, a4, a6, F, p ) then
    Error("Point P = ",P," does not lie on elliptic curve\n");
  fi;
  if not ellipse_membership( Q, a4, a6, F, p ) then
    Error("Point Q = ",Q," does not lie on elliptic curve\n");
  fi;
  if 0 in [ P, Q ] then
    if P = Q then
	  return 0;
	else
      return Difference( [ P, Q ], [ 0 ] );
	fi;
  fi;
  Px := One(F)*P[1];
  Py := One(F)*P[2];
  Qx := One(F)*Q[1];
  Qy := One(F)*Q[2];
  if Px = Qx and Py = Qy then
    if Py = 0*One(F) then
	  return 0;
	fi;
    a := One(F) * (3*Px^2 + a4) * (2*Py)^(-1);
  elif Px <> Qx then
    a := (Qy - Py)*(Qx - Px)^(-1);
  else
    return 0;
  fi;
  Rx := a^2 - Px - Qx;
  Ry := a*(Rx - Px) + Py;
  R := [ Rx, Ry ];
  return R;
end;

mirroredPoint := function( P, F, p )
  if IsZero( P ) then
    return P;
  fi;
  return [ One(F)*P[1], -One(F)*P[2] ];
end;

plus := function( P, Q, a4, a6, F, p )
  if P = 0 then
    return Q;
  elif Q = 0 then
    return P;
  else
    return mirroredPoint( ast( P, Q, a4, a6, F, p ), F, p );
  fi;
end;

double := function( P, a4, a6, F, p )
  return plus( P, P, a4, a6, F, p );
end;

ftimes := function( n, P, a4, a6, F, p )
  local p0, n0, a0;
  p0 := 0;
  a0 := P;
  n0 := n;
  while n0 > 0 do
    if (n0 mod 2 = 1) then
      p0 := plus(p0, a0, a4, a6, F, p );
    fi;
    a0 := double( a0, a4, a6, F, p);
    n0 := Int( Floor( Float( n0/2 ) ) );
  od;
  return p0;
end;

orderWithGivenGroupOrder := function( P, a4, a6, F, p, q )
  local n, Q;
  if P = 0 then
    return 1;
  fi;
  if IsPrime( q ) then
    return q;
  else
    for n in Factors( q ) do
      Q := ftimes( n, P, a4, a6, F, p );
      if Q = 0 then
        return n;
      fi;
    od;
  fi;
end;

order := function( P, a4, a6, F, p )
  local n, Q;
  if P = 0 then
    return 1;
  fi;
  n := 1;
  repeat
    n := n+1;
    Q := ftimes( n, P, a4, a6, F, p );
  until Q = 0;
  return n;
end;

ChoosePrimes := function( F )
  local p, q, S, N, n, i;
  p := Characteristic( F );
  if p = 0 then
    Error( "Schoof Algorithm not suitable for fields of characteristic 0" );
  fi;
  q := Length( AsList( F ) );
  S := [];
  N := 1;
  n := 5;
  i := 1;
  repeat
    repeat
	  n := n+1;
	until MRT( n, 10 ) and n <> p;
	S[i] := n;
	N := N*S[i];
	i := i+1;
  until N > 4*RootInt( q );
  return S;
end;

Schoof := function( a4, a6, F, p )
  local q, S, l, t;
  if not IsFinite( F ) then
    return infinity;
  fi;
  # F = Fq, q = p^b for prime p, b >= 1.
  q := Length( AsList( F ) );
  # N > 4*RootInt( q )
  # with S = { l[1], ..., l[r] } set of small distinct
  # primes with Product( S ) = N.
  # How many primes will we need at most?
  # N = l1*l2*...*lr > 4*Sqrt(q)
  # How big is r?
  # p >= 5 since Char F <> 2 or 3.
  # 4*RootInt( 5 ) = 8
  # 2*5 = 10 > 8, 3*5 = 15 > 8, 2*3 = 6 < 8
  # 2*3*5 = 30 > 8
  # r >= 3 minimal works.
  S := ChoosePrimes( F );
  for l in S do
  # compute tl;
  od;
  # division polynomial
  # t = Size( F ) + 1 - len;
end;
###

ElGamalECWithGivenEllipticCurve := function( a4, a6, p, q )
  local F, k, P, n, Q, key;
  F := HomalgRingOfIntegers( p );
  ## assume that q = group order
  ## find point P with order n | q.
  # Assume q = order of the elliptic curve
  if IsPrime( q ) then
    n := q;
  else
    Error( "Can't calculate order of point P\n" );
  fi;
  P := PointOnEllipticCurve( a4, a6, F, p );
  k := Random( 2, q-2 );
  Q := ftimes( k, P, a4, a6, F, p );
  key := rec();
  key.public := [ Int(a4), Int(a6), p,
    List( P, Int ), n, List( Q, Int ) ];
  key.private := k;
  return key;
end;

ElGamalEC := function( N )
  local key, p, F,
  F2, xy, a4, a6,
  P, n, Q, k, Elli;
  # choose a random prime n <= p <= 2*n
  p := MRG( N, 2*N, 10 );
  F := HomalgRingOfIntegers( p );
  F2 := Cartesian( AsList( F ), AsList( F ) );
  repeat
    xy := Random( F2 );
	a4 := xy[1];
	a6 := xy[2];
  until defines_ellipse( a4, a6, F, p );
  Elli := Union( ellipticCurve( a4, a6, F, p ), [ 0 ] );
  repeat
    P := Random( Elli );
    n := order( P, a4, a6, F, p );
  until n > 1;
  k := Random( [2..n-2] );
  Q := ftimes( k, P, a4, a6, F, p );
  key := rec();
  key.public := [ Int(a4), Int(a6), F, P, n, Q ];
  key.private := k;
  return key;
end;

ElGamal := function( n )
  if true in List( [ "ellipticCurve", "ec" ],
    ValueOption ) then return ElGamalEC( n );
  else
    if not true in List( [ "residueClass", "rc", "Zp" ],
      ValueOption ) then
      Print( "Default to `Zp`. For elliptic curve\
 cryptography specify option `ellipticCurve` or `ec`\n");
    fi;
	return ElGamalZp( n );
  fi;
end;













