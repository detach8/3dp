{----- general functions and procedures -----}
procedure beep;
	begin
		sound(1000);
		delay(20);
		nosound;
	end;

procedure cursor(x, y, c: word);
	var i: byte;
	begin
		for i := 2 to 4 do putdot(x + i, y, c);
		for i := 2 to 4 do putdot(x - i, y, c);
		for i := 2 to 4 do putdot(x, y + i, c);
		for i := 2 to 4 do putdot(x, y - i, c);
	end;

function gettok(str: string; toknum: word): string;
	var
		i, n : word;
		ts: string;

	begin
		i := 1;
		ts := '';
		for n := 1 to length(str) do begin
			if str[n] = #32 then
				if i = toknum then break
				else begin
					i := i + 1;
					ts := '';
				end
			else ts := ts + str[n];
		end;
		gettok := ts;
	end;


function gettoki(str: string; toknum: word): integer;
	var
		tempi: integer;
		err  : integer;
		ts   : string;
	begin
		ts := gettok(str, toknum);
		val(ts, tempi, err);
		gettoki := tempi;
	end;


function geteol(str: string; toknum: word): string;
	var
		i, n : word;
		ts: string;

	begin
		i := 1;
		ts := '';
		for n := 1 to length(str) do begin
			if (str[n] = #32) and (i < toknum) then
				begin
					i := i + 1;
					ts := '';
				end
			else ts := ts + str[n];
		end;
		geteol := ts;
	end;

function upper(ins: string): string;
	var
		i: byte;
		s: string;
	begin
		s := ins;
		for i := 1 to length(ins) do
			s[i] := upcase(s[i]);
		upper := s;
	end;


function num2str(num: real; dp: word): string;
	var
		tempnum: real;
		tempstr: string;
		tempint: integer;
		temprea: real;
		i      : word;
                ok     : boolean;
	begin

		if num >= 10000 then
			begin
				num2str := 'Error - number too large';
				exit;
			end;

                tempstr := '';

		if num < 0 then
			begin
				tempstr := '-';
				tempnum := -1 * num;
			end
		else tempnum := num;

		ok := false;
		tempint := 1;

                while ok = false do
			begin
				if tempnum/tempint < 1 then ok := true
				else tempint := tempint * 10;
			end;

		temprea := 0;

		if tempnum = 0 then tempstr := tempstr + '0'
		else while tempint > 1 do
			begin
				temprea := trunc((tempnum/tempint));
				tempstr := tempstr + chr(trunc((tempnum/tempint) * 10) - trunc(temprea) * 10 + 48);
				tempint := tempint div 10;
			end;

		if (dp > 0) and (dp <= 4) then
			begin
				tempstr := tempstr + '.';
				tempint := 1;
				for i := 1 to dp do tempint := tempint * 10;
				tempnum := tempnum * tempint;

				for i := 1 to dp do
					begin
						temprea := trunc((tempnum/tempint));
						tempstr := tempstr + chr(trunc((tempnum/tempint) * 10) - trunc(temprea) * 10 + 48);
						tempint := tempint div 10;
					end;
			end
		else if dp > 4 then
			begin
				num2str := 'Error - number of decimal places to convert must be between 0 and 4';
				exit;
			end;


		num2str := tempstr;

	end;

function remove(instr, remstr: string): string;
	var
		i, n: integer;
		s1, s2: string;
	begin
		s1 := '';
		s2 := '';
		i := 1;
		n := 0;

		while i <= length(instr) do
			begin
				s1 := '';
				for n := 0 to length(remstr) - 1 do
					s1 := s1 + instr[i + n];

				if s1 = remstr then i := i + length(remstr)
				else i := i + 1;

				s2 := s2 + instr[i];
			end;

		remove := s2;

	end;

function restrict(instr: string; pix: word): string;
	var
		i: integer;
		tempstr, tempstr2: string;
	begin
		tempstr := '';
		tempstr2 := '';

		for i := 1 to length(instr) do
			begin
				tempstr2 := tempstr2 + instr[i];
				if (getwidth(tempstr2) >= pix) then break
				else tempstr := tempstr2;
			end;

		restrict := tempstr;

	end;
