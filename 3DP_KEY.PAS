{----- key input functions and procedures -----}
function getkey: char;
	var
		key1, key2: char;

	begin
		key1 := readkey;
		if key1 = #0 then
			begin
				key2 := readkey;
				getkey := key2;
			end
		else getkey := key1;
	end;

procedure waitkey(keytowait: char);
	var
		keyhit: char;
		x, y  : word;
	begin
		repeat
			keyhit := getkey;
			if keyhit <> keytowait then beep;
		until keyhit = keytowait;
	end;
