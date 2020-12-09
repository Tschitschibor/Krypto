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

ellipticCurve := function( a4, a6, F )
  if not defines_ellipse( a4, a6, F ) then
    Error("Inputs don't define an elliptic curve.\n");
  fi;
  if not IsFinite( F ) then
    Error("Infinite field can't be converted to list.\n");
  fi;
  return Filtered( Cartesian( AsList( F ), AsList( F ) ), 
    xy -> ellipse_membership( xy, a4, a6, F ) );
end;

