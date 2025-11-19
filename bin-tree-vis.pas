program bin_tree_visualisation;
uses crt;
type
	TreeNodePtr = ^TreeNode;
	TreeNode = record
		data: longint;
		left, right: TreeNodePtr;
	end;
	numbers = array of longint;


procedure GetKey(var code: integer);
var
	c: char;
begin
	c := ReadKey;
	if c = #0 then
	begin
		c := ReadKey;
		code := -ord(c)
	end
	else
		code := ord(c)
end;


procedure AddToTree(var p: TreeNodePtr; n: longint; var ok: boolean);
begin
	if p = nil then
	begin
		new(p);
		p^.data := n;
		p^.left := nil;
		p^.right := nil;
		ok := true;
		exit;
	end;
	if n < p^.data then
		AddToTree(p^.left, n, ok);
	if n > p^.data then
		AddToTree(p^.right, n, ok)
	else
		ok := false;
end;


procedure PrintNode(x, y: byte; value: longint);
{
         .---.
result:  | n |
         '---'
}
begin
	GotoXY(x - 2, y - 1); write('.---.');
	GotoXY(x - 2, y);     write('|');
	GotoXY(x + 2, y);     write('|');
	GotoXY(x - 2, y + 1); write('''---''');
	GotoXY(x, y);
	write(value);
	GotoXY(1, 1);
end;


function power(n: longint; p: byte): Int64;
var
	i: longint;
begin
	power := 1;
	for i := 1 to p do
		power := power * n;
end;


procedure DrawLine(x1, y1, x2, y2: byte; direction: shortint);
var
	k: real;
	x: byte;
	dx, dy: byte;
begin
	dx := abs(x2 - x1);
	dy := abs(y2 - y1);
	k := dy / dx;
	for x := 1 to dx do
	begin
		GotoXY(x * direction + x1, y1 + round(x * k));
		write('.');
	end;
end;


procedure PrintTree(p: TreeNodePtr; var x, y: byte; var ok: boolean);
var
	tmp: byte;
	x1, y1: byte;
begin
	if (x + 2 > ScreenWidth) or (y + 1 > ScreenHeight) then
	begin
		ok := false;
		exit;
	end;
	x1 := x;
	y1 := y * 5 + 3;
	if p <> nil then
	begin
		PrintNode(x, y * 5 + 3, p^.data);
		if p^.left <> nil then
		begin
			tmp := x;
			y := y + 1;
			x := round(x - ScreenWidth / 2 / power(2, y));
			DrawLine(x1 - 2, y1 + 1, x + 2, y * 5 + 3 - 1, -1);
			PrintTree(p^.left, x, y, ok);
			if not ok then
				exit;
			y := y - 1;	{ restore y }
			x := tmp;	{ restore x }
		end;
		if p^.right <> nil then
		begin
			y := y + 1;
			tmp := x;
			x := round(x + ScreenWidth / 2 / power(2, y));
			DrawLine(x1 + 2, y1 + 1, x - 2, y * 5 + 3 - 1, 1);
			PrintTree(p^.right, x, y, ok);
			if not ok then
				exit;
			x := tmp;
			y := y - 1;
		end;
	end;
end;


var
	curr_x, curr_y, i: byte;
	code, correct: integer;
	root: TreeNodePtr;
	number: longint;
	ok: boolean;
begin
	root := nil;
	curr_x := ScreenWidth div 2;
	curr_y := 0;

	for i := 1 to ParamCount do
	begin
		val(ParamStr(i), number, correct);
		if correct = 0 then
			AddToTree(root, number, ok);
	end;
	if root = nil then
	begin
		writeln('No numbers given');
		halt(1);
	end;

	clrscr;
	
	ok := true;
	PrintTree(root, curr_x, curr_y, ok);
	if not ok then
	begin
		clrscr;
		writeln('Screen size is to small. Unable to draw tree');
		halt(1);
	end;

	while not KeyPressed do
		delay(50);
	GetKey(code);
end.

