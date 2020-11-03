{----- file processing and co-ordinates handling fns and procedures -----}

procedure parseconfigfile(filename: string; var _configfileok, _configfileerror: boolean);

	var
		outfsrc   : searchrec;
		configfile: text;
		tempstrdat: string;
		tokref    : string;
		i         : word;

	begin

		{ set defaults }
		svga_mode := 4;
		center_x  := 400;
		center_y  := 300;
		z_eye     := 512;
		max_fps   := 75;
		m_pitch   := 20/1000;
		m_yaw     := 30/1000;
		cursorf   := FALSE;
		datafile  := 'LOGO.3DP';
		fontfile  := 'DEFAULT.FNT';

		_debugmode := false;

		textcolor(14);
		write('CHECK : ');
		textcolor(7);
		writeln('Existance of config file ', filename, '.');

		findfirst(filename, Archive, outfsrc);
		if doserror <> 0 then begin
			_configfileok := false;
		end else begin

			textcolor(10);
			write('PASSED: ');
			textcolor(7);
			writeln('Config file found.');

			_configfileok := true;
			i := 1;

			assign(configfile, filename);
			reset(configfile);

			while not eof(configfile) do begin

				readln(configfile, tempstrdat);

				tokref := upper(gettok(tempstrdat, 1));

				if (tokref[1] <> '#') then begin
					if tokref = 'SETVIDEOMODE' then svga_mode := gettoki(tempstrdat, 2)
					else if tokref = 'SETFONT' then fontfile := gettok(tempstrdat, 2)
					else if tokref = 'SETCENTERX' then center_x := gettoki(tempstrdat, 2)
					else if tokref = 'SETCENTERY' then center_y := gettoki(tempstrdat, 2)
					else if tokref = 'SETZEYE' then z_eye := gettoki(tempstrdat, 2)
					else if tokref = 'SETMAXFPS' then max_fps := gettoki(tempstrdat, 2)
					else if tokref = 'SETMOUSEPITCH' then m_pitch := gettoki(tempstrdat, 2)/100
					else if tokref = 'SETMOUSEYAW' then m_yaw := gettoki(tempstrdat, 2)/100
					else if tokref = 'USEDATAFILE' then datafile := gettok(tempstrdat, 2)
					else if tokref = 'ENABLECURSOR' then begin
						if (gettok(tempstrdat, 2) = '1') or
						   (upper(gettok(tempstrdat, 2)) = 'Y') or
						   (upper(gettok(tempstrdat, 2)) = 'YES') or
						   (upper(gettok(tempstrdat, 2)) = 'TRUE') or
						   (upper(gettok(tempstrdat, 2)) = 'ON') then
							cursorf := true
						else cursorf := false;
					end
					else if (tokref = 'DEBUGMODE') then begin
						if (gettoki(tempstrdat, 2) = 1) then
							_debugmode := true;
					end
					else if tempstrdat <> '' then begin
						_configfileerror := true;
						textcolor(4);
						write('ERROR : ');
						textcolor(7);
						writeln('Unknown directive in line ', i, ' - ''', gettok(tempstrdat, 1), '''.');
					end;
				end;

				i := i + 1;
			end;

			close(configfile);

			if _debugmode = true then begin
				svga_mode := 0;
				textcolor(4);
				write('DEBUG : ');
				textcolor(7);
				writeln('Going into debug mode.');
			end;

			if _configfileerror = true then
				begin
					textcolor(4);
					write('ERROR : ');
					textcolor(7);
					writeln('Information in config file has been retrieved but there were errors.');

				end
			else
				begin
					textcolor(10);
					write('DONE  : ');
					textcolor(7);
					writeln('Information in config file has been retrieved successfully.');
				end;

			textcolor(11);
			write('DATA  : ');
			textcolor(7);
			writeln('Total ', i, ' lines.');

		end;

	end;


procedure parsedatafile(filename: string; var array_of_cords: cordsarraytype; var array_of_text: text3darraytype;
		        var _total_cords, _total_text: word; var datafileok: boolean);

	var
		currcordnum: word;
		currtextnum: word;
		_errors    : boolean;
		datafile   : text;
		tempstrdat : string;
		tokref     : string;
		outfsrc    : searchrec;
		i          : integer;

	begin

		textcolor(14);
		write('CHECK : ');
		textcolor(7);
		writeln('Existance of data file ', filename, '.');

		{ check driver file existance }
		findfirst(filename, Archive, outfsrc);
		if doserror <> 0 then begin
			datafileok := false;
		end else begin
			textcolor(10);
			write('PASSED: ');
			textcolor(7);
			writeln('Data file found.');
			assign(datafile, filename);
			reset(datafile);
			currcordnum := 1;
			currtextnum := 1;
			i := 1;
			_errors := false;
			while (not eof(datafile)) and (currcordnum < 65535) do begin
				readln(datafile, tempstrdat);

				tokref := upper(gettok(tempstrdat, 1));

				if (tokref[1] <> '#') and (tempstrdat <> '') then
					begin
						if (upcase(tokref[1]) = 'D') or (upcase(tokref[1]) = 'M') then
							begin
								array_of_cords[currcordnum].a := tokref[1];
								array_of_cords[currcordnum].x := gettoki(tempstrdat, 2);
								array_of_cords[currcordnum].y := gettoki(tempstrdat, 3);
								array_of_cords[currcordnum].z := gettoki(tempstrdat, 4);
								currcordnum := currcordnum + 1;
							end
						else if upcase(tokref[1]) = 'T' then
							begin
								array_of_text[currtextnum].x := gettoki(tempstrdat, 2);
								array_of_text[currtextnum].y := gettoki(tempstrdat, 3);
								array_of_text[currtextnum].z := gettoki(tempstrdat, 4);
								array_of_text[currtextnum].c := gettoki(tempstrdat, 5);
								array_of_text[currtextnum].t := geteol(tempstrdat, 6);
								currtextnum := currtextnum + 1;
							end
						else
							begin
								_errors := true;
								textcolor(4);
								write('ERROR : ');
								textcolor(7);
								writeln('Unknown directive in object file line ', i, ' - ''', gettok(tempstrdat, 1), '''.');
							end;

						i := i + 1;

					end;
			end;
			close(datafile);
			if _errors = true then
				begin
					textcolor(10);
					write('DONE  : ');
					textcolor(7);
					writeln('Information in data file has been retrieved but there were errors.');
				end
			else
				begin
					textcolor(10);
					write('DONE  : ');
					textcolor(7);
					writeln('Information in data file has been retrieved successfully.');
				end;

			textcolor(11);
			write('DATA  : ');
			textcolor(7);
			writeln('Total ', i, ' lines.');

			_total_cords := currcordnum - 1;
			_total_text := currtextnum - 1;
                        datafileok := true;
		end;
	end;


procedure checkreg(var reg: boolean; var user: string);
	var
		_regfile: text;
		_regid: string;
		_regdata: char;
		i, ii, n: integer;

	begin
		findfirst('REG.DAT', Archive, outfsrc);

		if doserror = 0 then begin

			i := 0;
			ii := 0;
			n := 0;

			assign(_regfile, 'REG.DAT');
			reset(_regfile);

			readln(_regfile, _regid);

			user := _regid;

			while not eoln(_regfile) do begin
				read(_regfile, _regdata);
				n := n + 1;
			end;

			close(_regfile);

			if (_regid = '') or (_regdata = '') then 
				begin
					reg := false;
					exit;
				end
			else begin

				for i := 1 to length(_regid) do
					ii := ord(_regid[i]) + ii;

				if ii = n then reg := true
				else reg := false;

				exit;

			end;
			

		end

		else
			reg := false;

	end;

