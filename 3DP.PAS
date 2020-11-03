program s3dp_rand_v001b;

uses crt, dos, mouse, txt, svga256;


{----- constant declarations -----}
const
	config_file = '3DP.INI';
	max_cords   = 2048;
	max_text    = 64;
	version     = 'v2.12';
	_unregtxt   = '*** U N R E G I S T E R E D   V E R S I O N ***';

	{----- special keys constants -----}
	up_arrow = #72;
	dn_arrow = #80;
	lf_arrow = #75;
	ri_arrow = #77;
	esc      = #27;
	tab      = #9;
	pgup     = #73;
	pgdn     = #81;
	f1       = #59;
	f2       = #60;
	f3       = #61;
	f4       = #63;
	f5       = #64;
	f6       = #65;
	f7       = #66;
	f8       = #67;
	f9       = #68;
	f10      = #69;
	f11      = #70;
	f12      = #71;


{----- type declarations -----}
type
	cordstype = record
		x: real;
		y: real;
		z: real;
		a: char;
	end;

	text3dtype = record
		x: real;
		y: real;
		z: real;
		c: word;
		t: string;
	end;

	fcordstype = record
		x: word;
		y: word;
	end;

	rotatetype = record
		x: real;
		y: real;
		z: real;
	end;

	mousetype = record
		x: integer;
		y: integer;
	end;

	cordsarraytype = array[1..max_cords] of cordstype;
	text3darraytype = array[1..max_text] of text3dtype;


{----- variables declarations -----}
var
	current_cords: cordstype;
	arrayof_cords: cordsarraytype;
	current_text : text3dtype;
	arrayof_text : text3darraytype;
	rotate_factor: rotatetype;
	current_color: word;

	zoom_factor  : real;

	curr_flat_cords: array[0..1] of fcordstype;

	mouse_cords : mousetype;
	mouse_change: mousetype;

	curr_cord_num: word;
	total_cords  : word;
	total_text   : word;

	configfileok   : boolean;
	configfileerror: boolean;
	datafileok     : boolean;

	escapekey: char;

	center_x : word;
	center_y : word;
	z_eye    : word;
	max_fps  : word;
	m_pitch  : real;
	m_yaw    : real;
	svga_mode: byte;
	cursorf  : boolean;
	datafile : string[12];
	fontfile : string[12];

	font: array[0..2000] of byte;

	_debugmode : boolean;
	_registered: boolean;
	_reguser   : string;
	_regcolor  : byte;
	_regcolort : boolean;
	_unreglen  : word;
	_loopc     : word;
	_loopt     : boolean;
	_quit      : boolean;
	_fdelay    : word;
	outfsrc    : searchrec;

	_logofile: text;
	_logodata: string;

	_c: char;


{ Includes for Functions and Procedures }

{ General library of Functions and Procedures }
{$I 3DP_LIB.PAS}

{ Key control Functions and Procedures }
{$I 3DP_KEY.PAS}

{ Graphical User Interface Functions and Procedures }
{$I 3DP_GUI.PAS}

{ File processing Functions and Procedures }
{$I 3DP_FILE.PAS}

{ 3D Calculation/rendering Functions and Procedures }
{$I 3DP_3D.PAS}


{----- main program body -----}
begin

	{ init any other vars }
	zoom_factor := 1;
	total_cords := 0;
	rotate_factor.x := 0;
	rotate_factor.y := 0;


	{ check registration }
	checkreg(_registered, _reguser);


	{ init text mode }
	textmode(CO80 + Font8x8);
	clrscr;

	{ hide cursor }
	asm
		mov ah, 01h
		mov ch, 28h
		mov cl, 08h
		int 10h
	end;

	findfirst('LOGO.DAT', Archive, outfsrc);
	if doserror <> 0 then begin
		textcolor(4);
		write('ERROR : ');
		textcolor(7);
		writeln('Logo file LOGO.DAT does not exist. Aborting.');
		writeln;
		writeln('Hit ESC to return to DOS...');
		waitkey(esc);
		exit;
	end;

	{ logo }
	textcolor(11);
	writeln('旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
	assign(_logofile, 'LOGO.DAT');
	reset(_logofile);
	while not eof(_logofile) do begin
		readln(_logofile, _logodata);
		textcolor(11);
		write  ('�');
		textcolor(15);
		write  (_logodata);
		textcolor(11);
		gotoxy(79, wherey);
		writeln('�');
	end;
	close(_logofile);
	write  ('읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
	textcolor(7);
	write  (' by Lee Ting Zien ');
	textcolor(11);
	writeln('켸');
	writeln;

	{ load values from config file/set defaults }	
	parseconfigfile('3DP.INI', configfileok, configfileerror);

	{ check the status of the config file }
	if configfileok = false then begin
		textcolor(4);
		write('ERROR : ');
		textcolor(7);
		writeln('Config file does not exist. Using defaults.');
		writeln;
		writeln('Hit ENTER to continue...');
		writeln;
		waitkey(#13);
	end else if configfileerror = true then begin
		textcolor(7);
		writeln;
		writeln('Hit ENTER to continue...');
		writeln;
		waitkey(#13);
	end;

	{ load values from the data file }
        parsedatafile(datafile, arrayof_cords, arrayof_text, total_cords, total_text, datafileok);

	{ check if datafile is ok }
	if datafileok = false then begin
		textcolor(4);
		write('ERROR : ');
		textcolor(7);
		writeln('Data file ', datafile, ' does not exist. Aborting.');
		writeln;
		writeln('Hit ESC to return to DOS...');
		waitkey(esc);
		exit;
	end;


	{ load font file and install font }
	textcolor(14);
	write('CHECK : ');
	textcolor(7);
	writeln('Existance of font file ', fontfile, '.');

	findfirst(fontfile, Archive, outfsrc);
	if doserror <> 0 then begin
		textcolor(4);
		write('ERROR : ');
		textcolor(7);
		writeln('Font file ', fontfile, ' does not exist. Aborting.');
		writeln;
		writeln('Hit ESC to return to DOS...');
		waitkey(esc);
		exit;
	end else begin
		textcolor(10);
		write('PASSED: ');
		textcolor(7);
		writeln('Font file exists. Loading.');
		fileread(fontfile,0,96,8,font);
		installfont(2,8,8,32,96,1,font);
	end;

	textcolor(15);
	writeln;
	writeln('Listing configurations...');
	writeln;

	textcolor(7);
	writeln('  VERSION    : ', version);
	write  ('  SVGA MODE  : ');
	if svga_mode = 1 then writeln('320x240, 256 colours.')
	else if svga_mode = 2 then writeln('720x400, 256 colours.')
	else if svga_mode = 3 then writeln('640x480, 256 colours.')
	else if svga_mode = 4 then writeln('800x600, 256 colours.')
	else if svga_mode = 5 then writeln('1024x768, 256 colours.')
	else writeln('INVALID!');
	writeln('  SCR CENTER : (', center_x, ', ', center_y, ')');
	writeln('  Z EYE      : ', z_eye);
	if max_fps <= 0 then max_fps := 1200;
	_fdelay := 1000 div max_fps;
	writeln('  FPS/DELAY  : ', max_fps, 'fps/', _fdelay, 'ms');
	writeln('  SHOW CURSOR: ', cursorf);
	writeln('  PITCH, YAW : ', m_pitch:0:2, ', ', m_yaw:0:2);
	writeln('  DATA FILE  : ', datafile);
	writeln('  FONT FILE  : ', fontfile);
	if _registered = false then writeln('  REGISTERED : ', _registered)
	else writeln('  REGISTERED : Registered to ', _reguser);
	writeln;
	writeln('Hit ENTER to continue...');
	writeln;
	waitkey(#13);

	{ graphics mode init }
	if (svga_mode > 0) and (svga_mode <= 5) then setmode(svga_mode);

	textcolor(14);
	write('INIT  : ');
	textcolor(7);
	writeln('Graphics mode.');

	{ mouse init }
	mouseinit(0, 0, maxx, maxy, 8, 8);
	mousepos(maxx div 2, maxy div 2);
	mouse_cords.x := maxx div 2;
	mouse_cords.y := maxy div 2;

	textcolor(14);
	write('INIT  : ');
	textcolor(7);
	writeln('Mouse.');

	if _debugmode = true then begin
		textcolor(7);
		writeln;
		writeln('Hit ENTER to continue...');
		writeln;
		waitkey(#13);
	end;

	{ more vars to calc/init }
	_unreglen := (maxx - getwidth(_unregtxt)) div 2;
	current_color := 78;
	_quit := false;

	printcopyright;

	while (_quit = false) do begin

		if _loopt = true then begin
			if _loopc < 10 then _loopc := _loopc + 1
			else begin
				_loopt := false;
				_loopc := 0;
				bar(2, 2, maxx - 2, 12, 0);
			end;
		end;

		{ do keyboard }

		if keypressed = true then
			begin
				escapekey := readkey;
				if escapekey = #0 then escapekey := readkey;
			end
		else escapekey := #0;

		if (escapekey = '=') or (escapekey = '+') then
			begin
				_loopt := true;
				bar(2, 2, maxx - 2, 12, 0);
				zoom_factor := zoom_factor + 0.01;
				print(2, 2, 7, 'Zoom factor: ' + num2str(zoom_factor, 2) + 'X');
				printcopyright;
			end
		else if escapekey = '-' then
			begin
				_loopt := true;
				bar(2, 2, maxx - 2, 12, 0);
				zoom_factor := zoom_factor - 0.01;
				print(2, 2, 7, 'Zoom factor: ' + num2str(zoom_factor, 2) + 'X');
				printcopyright;
			end
		else if upcase(escapekey) = 'C' then 
			begin
				_loopt := true;
				bar(2, 2, maxx - 2, 12, 0);
				current_color := random(256);
				print(2, 2, 7, 'Current color: ' + num2str(current_color, 0));
				printcopyright;
			end
		else if escapekey = pgup then
			begin
				_loopt := true;
				bar(2, 2, maxx - 2, 12, 0);
				if max_fps >= 1190 then
					begin
						max_fps := 1200;
						_fdelay := 0;
					end
				else
					begin
						max_fps := max_fps + 10;
						_fdelay := 1000 div max_fps;
					end;
				print(2, 2, 7, 'FPS/Delay: ' + num2str(max_fps, 0) + '/' + num2str(_fdelay, 0));
				printcopyright;
			end
		else if escapekey = pgdn then
			begin
				_loopt := true;
				bar(2, 2, maxx - 2, 12, 0);
				if max_fps <= 20 then
					begin
						max_fps := 10;
						_fdelay := 100;
					end
				else
					begin
						max_fps := max_fps - 10;
						_fdelay := 1000 div max_fps;
					end;
				print(2, 2, 7, 'FPS/Delay: ' + num2str(max_fps, 0) + '/' + num2str(_fdelay, 0));
				printcopyright;
			end;

		{ do mouse }

		mouse_change.x := (mouse_cords.x - mousex);
		mouse_change.y := (mouse_cords.y - mousey);

		if (mouse_change.x <> 0) or (mouse_change.y <> 0) then
			begin
				if (escapekey = #32) then
					rotate_factor.z := rotate_factor.z - rad(mouse_change.x * m_pitch)
				else begin
					rotate_factor.y := rotate_factor.y - rad(mouse_change.x * m_yaw);
					rotate_factor.x := rotate_factor.x - rad(mouse_change.y * m_pitch);
				end;
				mouse_cords.x := mousex;
				mouse_cords.y := mousey;
				printcopyright;
			end;



		{ do graphics }

		if (svga_mode > 0) and (svga_mode <= 5) then begin

			{ polygons }

			if (total_cords > 1) then for curr_cord_num := 1 to total_cords - 1 do
				if arrayof_cords[curr_cord_num + 1].a = 'D' then begin
					current_cords := arrayof_cords[curr_cord_num];

					rotate(current_cords, rotate_factor);
				        point2dxy(current_cords, curr_flat_cords[0]);
					current_cords := arrayof_cords[curr_cord_num + 1];

					rotate(current_cords, rotate_factor);
        				point2dxy(current_cords, curr_flat_cords[1]);
					line(curr_flat_cords[0].x, curr_flat_cords[0].y,
					     curr_flat_cords[1].x, curr_flat_cords[1].y, current_color);
				end;

			if (total_text > 0) then for curr_cord_num := 1 to total_text do begin
				current_cords.x := arrayof_text[curr_cord_num].x;
				current_cords.y := arrayof_text[curr_cord_num].y;
				current_cords.z := arrayof_text[curr_cord_num].z;
				rotate(current_cords, rotate_factor);
			        point2dxy(current_cords, curr_flat_cords[0]);


				print(curr_flat_cords[0].x, curr_flat_cords[0].y, arrayof_text[curr_cord_num].c,
				      arrayof_text[curr_cord_num].t);
			end;

			{ cursor }
			if cursorf = true then cursor(mouse_cords.x, mouse_cords.y, 15);

			if (_registered = false) then begin

				if _regcolort = true then begin
					print(_unreglen, (maxy div 2) - 12, 12, _unregtxt);
					print(_unreglen, maxy div 2, 12, _unregtxt);
					print(_unreglen, (maxy div 2) + 12, 12, _unregtxt);
					if _regcolor mod 10 = 0 then begin
						_regcolor := 1;
						_regcolort := false;
					end
					else _regcolor := _regcolor + 1;
				end
				else begin
					print(_unreglen, (maxy div 2) - 12, 15, _unregtxt);
					print(_unreglen, maxy div 2, 15, _unregtxt);
					print(_unreglen, (maxy div 2) + 12, 15, _unregtxt);
					if _regcolor mod 10 = 0 then begin
						_regcolor := 1;
						_regcolort := true;
					end
					else _regcolor := _regcolor + 1;
				end;
			end;


			{-- keyboard input scan #2 --}

			{ pause }
			if (upcase(escapekey) = 'P') then pauseframe

			{ quit check }
			else if escapekey = esc then _quit := quitprompt

			{ F1 help }
			else if escapekey = f1 then showhelpgui

			{ README.TXT }
			else if upcase(escapekey) = 'R' then textbrowser('README.TXT');


			{-- end --}



			{ frame delay }
			if (max_fps > 0) then delay(_fdelay);

			{ cursor }
			if cursorf = true then cursor(mouse_cords.x, mouse_cords.y, 0);

			{ polygons }

			if (total_cords > 1) then for curr_cord_num := 1 to total_cords - 1 do
				if arrayof_cords[curr_cord_num + 1].a = 'D' then begin

					current_cords := arrayof_cords[curr_cord_num];
					rotate(current_cords, rotate_factor);

				        point2dxy(current_cords, curr_flat_cords[0]);
					current_cords := arrayof_cords[curr_cord_num + 1];

					rotate(current_cords, rotate_factor);
        				point2dxy(current_cords, curr_flat_cords[1]);

					line(curr_flat_cords[0].x, curr_flat_cords[0].y,
					     curr_flat_cords[1].x, curr_flat_cords[1].y, 0);
				end;


			if (total_text > 0) then for curr_cord_num := 1 to total_text do begin
				current_cords.x := arrayof_text[curr_cord_num].x;
				current_cords.y := arrayof_text[curr_cord_num].y;
				current_cords.z := arrayof_text[curr_cord_num].z;
				rotate(current_cords, rotate_factor);
			        point2dxy(current_cords, curr_flat_cords[0]);


				print(curr_flat_cords[0].x, curr_flat_cords[0].y, 0,
				      arrayof_text[curr_cord_num].t);
			end;


		end;


	end;
  
	{ms-dos text mode}
	if (svga_mode > 0) and (svga_mode <= 5) then setmode(0)
	else textmode(CO80);

end.
