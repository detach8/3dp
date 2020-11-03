{----- backend basic 3d functions and procedures -----}

function point2d(point3dfront, point3ddepth: real; center, depth_eye: word; _zoom: real): word;
	var
		tpoint2d: word;
	begin
		if depth_eye - point3ddepth = 0 then tpoint2d := 0
		else tpoint2d := round(((point3dfront * depth_eye)/(depth_eye - point3ddepth)) * _zoom);
		point2d := center + tpoint2d;		
	end;

procedure point2dxy(cordsin: cordstype; var cordsout: fcordstype);
	begin
		cordsout.x := point2d(cordsin.x, cordsin.z, center_x, z_eye, zoom_factor);
		cordsout.y := point2d(cordsin.y, cordsin.z, center_y, z_eye, zoom_factor);
	end;

procedure rotate(var cords: cordstype; rotrad: rotatetype);
  var
	xtemp, ytemp, ztemp: real;
	cosx, cosy, cosz   : real;
	sinx, siny, sinz   : real;

  begin
	cosx := cos(rotrad.x); cosy := cos(rotrad.y); cosz:=cos(rotrad.z);
	sinx := sin(rotrad.x); siny := sin(rotrad.y); sinz:=sin(rotrad.z);
	xtemp := cords.x * cosz + cords.y * sinz;
	ytemp := cords.y * cosz - cords.x * sinz;
	ztemp := cords.z * cosx - ytemp * sinx;
	cords.x := xtemp * cosy + ztemp * siny;
	cords.y := ytemp * cosx + cords.z * sinx;
	cords.z := ztemp * cosy - xtemp * siny;
  end;


{----- mathematical functions and procedures -----}

function rad(deg: real): real;
	begin
		rad := (deg * pi)/180;
	end;
