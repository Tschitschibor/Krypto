Read( Concatenation(GAPInfo.RootPaths[1],"pkg/Krypto/gap/DivisionRemainder.g") );

Z24s := [];

for a0 in [0..b-1] do
  for a1 in [0..b-1] do
    for b0 in [0..b-1] do
      for b1 in [0..b-1] do
        if DivRem( b )( a0*b0 mod b, a1*b1 mod b, 2, 4 ) =
		  [ 1, 0 ] then
          Add( Z24s, [ a0*b0, a1*b1 ];
		fi;
> od; od; od; od;

