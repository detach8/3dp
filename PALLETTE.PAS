program palletteeee;

uses svga256, txt, crt;

var
  i, x, y: word;
  s: string;
  font: array[0..2000] of byte;

begin
  setmode(4);
  x := 0;
  y := 0;
  fileread('DEFAULT.FNT',0,96,8,font);
  installfont(2,8,8,32,96,1,font);

  for i := 0 to 255 do begin
    bar(x, y, 25, 25, i);
    str(i, s);
    print(x + 2, y + 2, 15, s);
    x := x + 25;
    if x >= 800 then begin
      x := 0;
      y := y + 25;
    end;
  end;

  readkey;
  
end.