#LoadPackage("Krypto");
Read(Concatenation( GAPInfo.RootPaths[1],
  "pkg/Krypto/gap/ShannonFanoElias.gi" ) );
sig := [1,2,3];
p := [1/16, 7/8, 1/16];
n := 6;

g := SFE_encode( sig, p );
g([2,2,3,2,1,2]);
g([2,2,2,2,2,2]);

h := SFE_decode( sig, p, n );
h("100");
h("000111100");