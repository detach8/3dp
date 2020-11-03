procedure printcopyright;
	begin
		print(2, maxy - 8, 7, '3DP ' +  version + '. Copyright(c) 1999, Lee Ting Zien. All Rights Reserved. "F1" for help.');
	end;

procedure drawwindow(x, y, w, h, c: word);
	begin
		{clear}
		bar(x, y, w + 1, h + 1, c);

		{shadow}
		line(x, y + h, x + w, y + h, 8);
		line(x + 1, y + h - 1, x + w - 1, y + h - 1, 7);

		line(x + w, y, x + w, y + h, 8);
		line(x + w - 1, y + 1, x + w - 1, y + h - 1, 7);

		{hilight}
		line(x, y, x + w, y, 15);
		line(x + 1, y + 1, x + w - 1, y + 1, 7);
		line(x, y, x, y + h, 15);
		line(x + 1, y + 1, x + 1, y + h - 1, 7);
	end;

procedure drawtextwindow(x, y, w, h, c: word; titlebar: string);
	begin
		{clear}
		bar(x, y, w + 1, h + 1, 7);

		{shadow}
		line(x, y + h, x + w, y + h, 8);
		line(x + 1, y + h - 1, x + w - 1, y + h - 1, 7);

		line(x + w, y, x + w, y + h, 8);
		line(x + w - 1, y + 1, x + w - 1, y + h - 1, 7);

		{hilight}
		line(x, y, x + w, y, 15);
		line(x + 1, y + 1, x + w - 1, y + 1, 7);
		line(x, y, x, y + h, 15);
		line(x + 1, y + 1, x + 1, y + h - 1, 7);

		bar(x + 3, y + 3, w - 6, 12, 1);
		print(x + 5, y + 5, 15, titlebar);

		{ text area }
		bar(x + 5, y + 19, w - 10, h - 24, c);


		{shadow}
		line(x + 3, y + h - 4, x + w - 4, y + h - 4, 30);
		line(x + 4, y + h - 5, x + w - 5, y + h - 5, 29);
		line(x + w - 4, y + 17, x + w - 4, y + h - 4, 30);
		line(x + w - 5, y + 18, x + w - 5, y + h - 5, 29);

		{hilight}
		line(x + 3, y + 17, x + w - 4, y + 17, 16);
		line(x + 4, y + 18, x + w - 5, y + 18, 24);
		line(x + 3, y + 17, x + 3, y + h - 4, 16);
		line(x + 4, y + 18, x + 4, y + h - 5, 24);


		
	end;

procedure cleartextwindow(x, y, w, h, c: word);
	begin
		bar(x + 5, y + 19, w - 10, h - 24, c);

	end;

procedure clearwindow(x, y, w, h, c: word);
	begin
		bar(x, y, w + 1, h + 1, c);
	end;


function quitprompt: boolean;
	const
		win_width = 200;
		win_height = 40;
		prompt = 'Really quit? (Y/N)';


	var
		lx: word;
		ty: word;
		tw: word;
		_c: char;

	begin
		_c := #0;

		{calcs}
		lx := (maxx - win_width) div 2;
		ty := (maxy - win_height) div 2;

		drawwindow(lx, ty, win_width, win_height, 125);

		{width of prompt text}
		tw := getwidth(prompt);

		{show prompt}
		print(((win_width - tw) div 2) + lx, ((win_height - 8) div 2) + ty, 12, prompt);

		{get key}
		while (upcase(_c) <> 'N') and (upcase(_c) <> 'Y') and (_c <> esc) do
			begin
				_c := readkey;
				if _c = #0 then _c := readkey;
				if (upcase(_c) <> 'N') and (upcase(_c) <> 'Y') and (_c <> esc) then begin
					sound(1000);
					delay(100);
					nosound;
				end;
			end;

		{ clear }
		clearwindow(lx, ty, win_width, win_height, 0);

		if upcase(_c) = 'Y' then quitprompt := true
		else quitprompt := false;

	end;


procedure pauseframe;
	const
		win_width = 250;
		win_height = 30;
		prompt = 'Paused. Hit "P" to unpause.';


	var
		lx: word;
		ty: word;
		tw: word;
		_c: char;

	begin
		_c := #0;

		{calcs}
		lx := maxx - win_width - 2;
		ty := maxy - win_height - 2;

		drawwindow(lx, ty, win_width, win_height, 125);

		{width of prompt text}
		tw := getwidth(prompt);

		{show prompt}
		print(((win_width - tw) div 2) + lx, ((win_height - 8) div 2) + ty, 15, prompt);

		{get key}
		while (upcase(_c) <> 'P') do
			begin
				_c := readkey;
				if _c = #0 then _c := readkey;
				if (upcase(_c) <> 'P') then begin
					sound(1000);
					delay(100);
					nosound;
				end;
			end;

		{ clear }
		clearwindow(lx, ty, win_width, win_height, 0);

		printcopyright;
	end;


procedure showhelpgui;
	const
		helpfilename = 'HELP.DAT';
	var
		win_width : word;
		win_height: word;

		lx: word;
		ty: word;
		tw: word;
		_c: char;

		linex: integer;
		liney: integer;
		currline: word;
		alignstatus: string[1];
		currcolor: byte;
		i: word;

		helpfile: text;
		dataline: string;
		tempstr: string;
		firstchar: char;
		
		outfsrc   : searchrec;

	begin

		win_width  := maxx - (maxx div 10);
		win_height := maxy - (maxy div 10);

		_c := #0;

		{calcs}
		lx := (maxx - win_width) div 2;
		ty := (maxy - win_height) div 2;

		liney := 0;
		linex := 0;
		alignstatus := 'L';

		drawtextwindow(lx, ty, win_width, win_height, 15, '3DP Text Window - "F1" Help');

		findfirst(helpfilename, Archive, outfsrc);

		if doserror = 0 then
			begin
				assign(helpfile, helpfilename);
				reset(helpfile);

				while not eof(helpfile) do
					begin
						readln(helpfile, dataline);

						firstchar := dataline[1];

						if firstchar = '!' then begin
							if gettok(dataline, 1) = '!align' then
								alignstatus := gettok(dataline, 2)
							else if gettok(dataline, 1) = '!color' then
								currcolor := gettoki(dataline, 2)
							else if gettok(dataline, 1) = '!line' then
								currline := gettoki(dataline, 2)
						end
						else if firstchar <> '#' then begin

							{ variables replacements}
							if dataline = '$version' then dataline := version;

							{ co-ordinates calculation - x }
							if alignstatus = 'L' then linex := 8
							else if alignstatus = 'R' then linex := (win_width - getwidth(dataline)) - 8
							else if alignstatus = 'C' then linex := (win_width - getwidth(dataline)) div 2
							else linex := 8;

							{ co-ordinates calculation - y }
							liney := ((currline - 1) * 10) + 22;
							currline := currline + 1;

							{ display data }
							print(lx + linex, ty + liney, currcolor, dataline);
						end;
					end;

				close(helpfile);
			end
		else
			print(lx + 8, ty + 22, 0, 'ERROR: The help file ' + helpfilename + ' could not be found.');

		print(lx + 8, ty + win_height - 15, 8, 'Hit "ESC" to close this window.');

		while (_c <> esc) do
			begin
				_c := readkey;
				if _c = #0 then _c := readkey;
				if (upcase(_c) <> esc) then begin
					sound(1000);
					delay(100);
					nosound;
				end;
			end;

		clearwindow(lx, ty, win_width, win_height, 0);

		printcopyright;
		
	end;


procedure textbrowser(textfile: string);
	const
		x_offset = 8;
		y_offset = 22;
		fontheight = 10;
		exit_prompt = '"ESC" to Exit';

	var
		win_width : word;
		win_height: word;
		lx: word;
		ty: word;
		filep: text;
		outfsrc   : searchrec;
		_c: char;
		x, y: word;
		line: word;
                oldline: word;
		lines: word;
		currentline: word;
		textdata: string;

	begin

		win_width  := maxx - (maxx div 10);
		win_height := maxy - (maxy div 10);
		lx := (maxx - win_width) div 2;
		ty := (maxy - win_height) div 2;
		_c := #0;
		line := 1;
                oldline := 2;
		lines := 0;
		currentline := 1;
		x := x_offset;
		y := y_offset;

		drawtextwindow(lx, ty, win_width, win_height, 15, '3DP Text Browser - ' + textfile);
		print(lx + (win_width - getwidth(exit_prompt) - 5), ty + 5, 7, exit_prompt);



		findfirst(textfile, Archive, outfsrc);

		if doserror = 0 then
			begin
				assign(filep, textfile);

				while (_c <> esc) do
					begin
						if oldline <> line then begin
							cleartextwindow(lx, ty, win_width, win_height, 15);
							reset(filep);
							currentline := 1;
							lines := 0;

							while not eof(filep) do begin
								readln(filep, textdata);

								if (currentline >= line) then begin
									if (win_height - 40 > lines * fontheight) then begin
										y := (fontheight * lines) + y_offset;
										print(lx + x_offset, ty + y, 0, restrict(textdata, win_width - 20));
										currentline := currentline + 1;
										lines := currentline - line;
									end
								end
								else currentline := currentline + 1;
							end;
						end;
				                oldline := line;
						_c := readkey;
						if _c = #0 then _c := readkey;
						if _c = up_arrow then
							begin
								if line > 1 then line := line - 1;
							end
						else if _c = dn_arrow then line := line + 1
						else if _c = pgup then
							begin
								if line > ((win_height - 40) div fontheight) then
									line := line - ((win_height - 40) div fontheight)
								else if line <> 1 then
									line := 1;
							end
						else if _c = pgdn then line := line + ((win_height - 40) div fontheight);
					end;

					close(filep);

			end
		else
			begin
				print(lx + 8, ty + 22, 0, 'ERROR: The text file ' + textfile + ' could not be found.');

				while (_c <> esc) do
					begin
						_c := readkey;
						if _c = #0 then _c := readkey;
					end;
			end;


		clearwindow(lx, ty, win_width, win_height, 0);

		printcopyright;


	end;