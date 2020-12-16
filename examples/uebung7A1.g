Read( Concatenation(GAPInfo.RootPaths[1],"pkg/Krypto/gap/EllipticCurve.g"));

a4 := 3;
a6 := 9;
p := 11;
F := HomalgRingOfIntegers( p );
P := [ 2, 1 ];
Q := [ 3, 10 ];
k := 7;

C := [ 10, 7 ];
D := [ 3, 10 ];
mirroredPoint;;
S := mirroredPoint( C, F, p );
M := plus( D, ftimes( k, S, a4, a6, F, p ), a4, a6, F, p );
Print( List( M, Int ) );