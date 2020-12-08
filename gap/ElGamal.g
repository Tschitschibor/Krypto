
StringToIntegerList := function( s )
local L;
L := [ 1, 2, 3 ];
return L;
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
    n0 := Int( Floor( Float( n0/2) ) );
  od;
  return p0;
end;

MillerRabinTest := function( n, k )
local MR, d, s, a, x, i, j;
MR := false;
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

MRG := function( low, high, k )
  return MillerRabinGenerator( low, high, k );
end;



ElGamal := function( n )
local p, a, k, z, key,
f, q, m;

## Bob chooses prime number
## Bob chooses primitive root

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
