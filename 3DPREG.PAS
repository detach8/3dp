program s3dp_reg_maker;

uses crt, dos;

var
	i, ii: integer;
	id   : string;
	c    : char;
	s    : string;
	filet: text;
	outfsrc: searchrec;

begin
	writeln;
	write('User Name: ');
	readln(id);

	findfirst('REG.DAT', Archive, outfsrc);

	if doserror = 0 then
		begin
			write('REG.DAT exists. Overwrite? (Y/N) ');
			while (upcase(c) <> 'N') and (upcase(c) <> 'Y') do begin
				c := readkey;
				if (upcase(c) <> 'N') and (upcase(c) <> 'Y') then begin
					sound(1000);
					delay(100);
					nosound;
				end;
			end;
			writeln;
		end
	else
		c := 'Y';

	if upcase(c) = 'Y' then begin
		for i := 1 to length(id) do
			ii := ii + ord(id[i]);
		writeln('Creating file REG.DAT...');
		writeln('Lines: ', ii);
		assign(filet, 'REG.DAT');
		rewrite(filet);
		writeln(filet, id);
		for i := 1 to ii do begin
			str(random(2), s);
			c := s[1];
			write(filet, c);
		end;
		writeln(filet);
		close(filet);
		writeln('Done!');
	end;


end.