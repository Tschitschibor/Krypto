LoadPackage( "GaussForHomalg" );

defines_ellipse := function( a4, a6, F )
  return IsField( F ) and
    Characteristic( F ) <> 2 and
    Characteristic( F ) <> 3 and
	One( F )*(4*a4^3 + 27*a6^2) <> One( F )*0;
end;

ellipse_membership := function( xy, a4, a6, F )
  local x, y;
  x := xy[1];
  y := xy[2];
  return One(F)*(y^2) = One(F)*(x^3 + a4*x + a6);
end;


EllipticCurve := function( a4, a6, F )
local a4s, a6s, ellipse_membership, ellipse_points, 
ellipse;
if not( IsField( F ) ) then
  Error("F must be a field\n");
fi;
if 4*a4s^3 + 27*a6s^2 = 0 then
  Error("Inputs don't define an elliptic curve.\n");
fi;




ellipse := function( a4, a6, F )
  if not defines_ellipse( a4, a6, F ) then
    Error("Inputs don't define an elliptic curve.\n");
  fi;
  if not IsFinite( F ) then
    Error("Infinite field can't be converted to list.\n");
  fi;
  return Filtered( Cartesian( AsList( F ), AsList( F ) ), 
    xy -> ellipse_membership( xy, a4, a6, F ) );
end;

line_membership := function( xy, P, Q , F)
  local s;
  if IsFinite( F ) then
    for s in AsList( F ) do
	  if xy = (1-s)*P + s*Q then
	    return true;
	  fi;
	od;
	return false;
  fi;
end;

line := function( P, Q, F )
  return Filtered( Cartesian( AsList( F ), AsList( F ) ),
    xy -> line_membership( xy, P, Q, F ) );
end;

third := function( P, Q, a4, a6, F )
  if P <> Q then
    return Filtered( line( P, Q, F ), xy ->
      ellipse_membership( xy, a4, a6, F ) and 
    	xy <> P and
	    xy <> Q );
  else
    return [ ];
  fi;
end;

print_triples := function( a4, a6, F )
local elli, PQ, R;
elli := ellipse( a4, a6, F );
for PQ in Cartesian( elli, elli ) do
  P := PQ[1];
  Q := PQ[2];
  R := third( P, Q, a4, a6, F );
  if not IsEmpty( R ) then
    R := R[1];
    Print( P, Q, R,"\n" );
  fi;
od;
end;

# For a finite field we can calculate the curve
if IsFinite( F ) then
  Fsquared := Cartesian( AsList( F ), AsList( F ) );
  ellipse_points := Filtered( Fsquared, ellipse_membership );
  ellipse := rec();
  ellipse.a4 := a4s;
  ellipse.a6 := a6s;
  ellipse.field := F;
  ellipse.points := ellipse_points;
  ellipse.zero := "O";
  ellipse.membership := ellipse_membership;
  ellipse.line := 
  ellipse.add := function( P, Q )
    
  end;
  return ellipse;
fi;
end;
