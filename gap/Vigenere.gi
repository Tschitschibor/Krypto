AlphstringCONST := "ABCDEFGHIJKLMNOPQRSTUVWXYZ";


normalizeString := function( str )
  local s;
  s := str;
  RemoveCharacters( s, " \n\t\r");
  return UppercaseString( s );
end;

printVigenereTable := function( keyword )
  local d, halves, Alphstring, c, charstr;
  for d in Concatenation( ['A'], normalizeString( keyword ) )
   do
    halves := SplitString( AlphstringCONST, d );
    if not IsBound( halves[2] ) then
	  halves[2] := [];
	fi;
    Alphstring := Concatenation( [ d ], halves[2], halves[1] );
    for c in Alphstring do
      charstr := String( c );
      RemoveCharacters( charstr, "'" );
      Print( charstr, " " );
    od;
	Print( "\n" );
  od;
end;

matrixVigenereTable := function( keyword )
  local d, halves, Alphstring, c, charstr, i, j, mat;
  mat := [];
  i := 1;
  for d in Concatenation( ['A'], normalizeString( keyword ) )
   do
    halves := SplitString( AlphstringCONST, d );
    if not IsBound( halves[2] ) then
	  halves[2] := [];
	fi;
    Alphstring := Concatenation(
	  [ d ],
	  halves[2],
	  halves[1] );
	mat[i] := Alphstring;
	i := i+1;
  od;
  return mat;
end;

encryptVigenere := function( keyword, cleartext )
  local mat, m, crypttext, i, k, j;
  mat := matrixVigenereTable( keyword );
  m := Length( keyword );
  crypttext := [];
  i := 1;
  k := 1;
  for j in List( normalizeString( cleartext ),
	  s -> IntChar( s ) mod 64 ) do
    # k-th character is i-th alphabet for number j
	crypttext[k] := mat[i+1][j];
	i := (i mod m) + 1;
	k := k+1;
  od;
  return crypttext;
end;

decryptVigenere := function( keyword, crypttext )
  local mat, m, cleartext, i, k, c, pos;
  mat := matrixVigenereTable( keyword );
  m := Length( keyword );
  cleartext := [];
  i := 1;
  k := 1;
  for c in normalizeString( crypttext ) do
    # find char c in alphabet mat[i]
	pos := Position( mat[i+1], c );
    cleartext[k] := mat[1][pos];
	i := (i mod m) + 1;
	k := k + 1;
  od;
  return cleartext;
end;

MaxChar := function( s )
  local maxchar, occurrence, c, occuc;
  maxchar := '-';
  occurrence := 0;
  for c in AlphstringCONST do
    occuc := Length( Positions( normalizeString( s ), c ) );
    if occuc > occurrence then
      maxchar := c;
      occurrence := occuc;
    fi;
  od;
  return [ maxchar, occurrence ];
end;

attackVigenere := function( chiffretext )
  local n, mat, len, maxkeylength, qr, m, tail,
    i, k, maxima, mc;
  len := Length( chiffretext );
  maxkeylength := Minimum( [ len, 10 ] );
  ## guess key length n
  n := 1;
  maxima := [];
  while n < maxkeylength do 
    maxima[n] := []; 
    mat := [];
	qr := QuotientRemainder( len, n );
    m := qr[1];
	tail := qr[2];
    for i in [1..n] do
	## mat[i] contains the i-th line of text as a string.
	# for n > 1 we may have m*n < len
      mat[i] := normalizeString( List( [0..m], 
	  function( k )
	    if IsBound( chiffretext[(k-1)*n+i] ) then
		  return chiffretext[(k-1)*n+i];
		else
		  return ' ';
		fi;
	  end) );
	  if i = 1 then
        Error("check mat[i]");
	  fi;
      maxima[n][i] := rec();
	  # maximal occurance of char c in row i at keylength n
	  mc := MaxChar( mat[i] );
	  maxima[n][i].maxchar := mc[1];
	  maxima[n][i].occurrence := mc[2];
    od;
	maxima[n][i].sum := Sum( List( [1..n],
	  j -> maxima[n][j].occurrence ) );
    n := n+1;
  od;
  return maxima;
end;

