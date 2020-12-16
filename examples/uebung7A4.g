LoadPackage( "GaussForHomalg" );

# k : (Z_2)^4 -> (Z_2)^2:
S := HomalgRingOfIntegers( 2 );
m := 4;
n := 2;
k := function( B_ )
  local B;
  B := List( B_, Int );
  if B in [ [0,0,0,0], [0,1,0,0], [1,1,1,1] ] then
    return [1,0];
  elif B in [ [0,0,0,1], [1,0,0,1], [1,1,0,0],
    [1,1,1,0] ] then
    return [0,0];
  elif B in [ [0,0,1,0], [0,1,0,1], [0,1,1,0], [0,1,1,1],
    [1,0,1,1] ] then
    return [1,1];
  else
    return [0,1];
  fi;
end;
x := [ One( S ), Zero( S ), One( S ) ];
#
#
r := m - n; # r = 2
D := List( [0..(2^r - 1)], i -> AsList(S^i) );
# D[r+1] hat Wörter der Länge r.
# Gesucht h(x) für
# x = 101 in D[4].
l := Length( x );
# Hier ist also x ein Wort der Länge l = r + 1,
# besteht daher aus 1 Wort x1,...,x(s-1) der
# Länge r und einem Wort x_2 = x_s der Länge 1 <= r.
s := 2;
x1 := [ One( S ), Zero( S ) ];
x_2 := [ One( S ) ];
x = Concatenation( x1, x_2 );
#! true
Length( x_2 ) <= r;
#! true
x2 := Concatenation( x_2, Zero( S^(r - Length( x_2 ) ) ) );
# perform binärzerlegung von l
# |x| = l = 3 = 1*2^0 + 1*2^1
x3 := [ One( S ), One( S ) ];
x := [ x1, x2, x3 ];
a := [];
#a[1] = a0
#a[i+1] = ai
#a[i+2] = a(i+1)
a[1] := List( [ Zero( S ), Zero( S ) ], Int );
# {1,...,s+1} = [2..s+2]
# verschiedene Zählweise für die 
# ai und xi:
# x1,x2,x3
# a0,a1,a2,a3
# a(i) = a[i+1]
# x(i) = x[i]
for i in [1..s+1] do # [1,2,3]
  Print( Concatenation( a[i],x[i] ) );
  a[i+1] := k(Concatenation( a[i],x[i] ));
od;
# x = 101
# h(x) = a[s+2]
Print( a[s+2] );








