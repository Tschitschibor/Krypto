# (2.1.28) efficient factoring of n = pq
# RSAFactoring := function( n, e, d, k )
RSAFactoring := function( n, e, d ) # k = 10
local s, t, a, i, p, j;
s := 0;
t := e*d - 1;
while t mod 2 = 0 do
  t := t/2;
  s := s+1;
od;
# s, t such that e*d - 1 = 2^(s)*t and t mod 2 = 1.

# for j in [1..k] do
for j in [1..10] do
  repeat
    a := Random( [1..n-1] );
  until GcdInt( a, n ) = 1;
  for i in [0..s-1] do
	p := GcdInt( a^(2^(i)*t) - 1, n );
    if p <> n and p <> 1 then
	  return p;
    fi;
  od;
od;
end;