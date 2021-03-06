s := Concatenation(
"101 001 000 110 111 011 010 100 ",
"001 101 100 000 110 111 011 010 ",
"110 111 001 100 101 010 000 011 ",
"010 000 111 011 001 100 101 110" );

L := SplitString( s, " " );

# k is 2-bit =^ 0,1,2,3
# m is 3-bit =^ 0,...,7
enc := function( k, m )
  return (L{[(k*8+1)..(k*8+8)]})[m+1];
end;

m := [ 5, 2, 5, 2 ];
k := 3;
c0 := 0;
c1 := enc( 3, 0 + m[1] );

dec := function( k, c )
  return Position( (L{[(k*8+1)..(k*8+8)]}), c ) - 1;
end;

## b)

m := [ 5, 2, 5, 2 ];
#! [ 5, 2, 5, 2 ]
c1 := enc( 1, m[1] );
#! "111"
c2 := enc( 1, (m[1] + m[2]) mod 8 );
#! "010"
c3 := enc( 1, (m[1] + m[2] + m[3]) mod 8 );
#! "110"
c4 := enc( 1, (m[1] + m[2] + m[3] + m[4]) mod 8 );
#! "011"
c := [ c1, c2, c3, c4 ];
#! [ "111", "010", "110", "011" ]

# c_i' = e_k ( m1 + ... + mi )
# d_k( c_i' ) = d_k( e_k( m1 + ... + mi ) )
# d_k( c_i' ) = m1 + ... + mi
# mi = d_k( c_i' ) - m1 - ... - m(i-1)
# mi = d_k( c_i' ) - ( m1 + ... + m(i-1) )
# mi = d_k( c_i' ) - d_k( c_(i-1)' )

m1 := dec( 1, c[1] );
#! 5
m2 := dec( 1, c[2] ) - dec( 1, c[1] );
#! 2
m3 := (dec( 1, c[3] ) - dec( 1, c[2] )) mod 8;
#! 5
m4 := ( dec( 1, c[4] ) - dec( 1, c[3] ) ) mod 8;
#! 2
m = [ m1, m2, m3, m4 ];
#! true