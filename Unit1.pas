unit Unit1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, LinkedList,
	Pacman, Ghost, Map, Food, MapObject, Astar;

CONST FRAMES_PER_SECOND = 60;

TYPE TForm1 = CLASS(TForm)
	Timer1: TTimer;
    Image1: TImage;
	PROCEDURE onkeydown(Sender: TObject; var Key: Word; Shift: TShiftState);
    PROCEDURE init(Sender: TObject);
    procedure frame(Sender: TObject);
	PUBLIC
		gui : TBitmap;
		map : TMap;
		objects : TLinkedList;
		pac : TPacman;
END;

var
  Form1: TForm1;

IMPLEMENTATION

{$R *.lfm}

PROCEDURE TForm1.onkeydown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
BEGIN
	IF key = 38 THEN
		pac.setDirection(1) //arriba
	ELSE IF key = 39 THEN
		pac.setDirection(2) //derecha
	ELSE IF key = 40 THEN
		pac.setDirection(3) //abajo
	ELSE IF key = 37 THEN
		pac.setDirection(4) //izq
	ELSE IF key = 27 THEN
		application.terminate();
END;


PROCEDURE TForm1.init(Sender: TObject);
VAR f : textFile;
VAR w,h,x,y  : INTEGER;
VAR ch : CHAR;
BEGIN
	TPacman.loadGfx();
    TGhost.loadGfx();
	TMap.loadGfx();
	TFood.loadGfx();
	TPowerUp.loadGfx();
	gui := TBitmap.create();
	gui.loadFromFile('gfx/gui.bmp');
	gui.Transparent := TRUE;

	objects := TLinkedList.create();
	assignFile(f, 'maps/map.txt');
	reset(f);
	READ(f, w);
	READ(f, h);
	map := TMap.create(w, h);
	FOR y :=0  TO h-1 DO
	BEGIN
		READ(f, ch);
		IF ch = #13 THEN READ(f, ch);
		IF ch = #10 THEN READ(f, ch);
		FOR x := 0 TO w-1 DO
		BEGIN
			IF ch = '1' THEN
				map.setTile(x,y, 1)
			ELSE IF ch = '2' THEN
				map.setTile(x, y, 2)
			ELSE
				map.setTile(x,y, 0);
			IF ch = '.' THEN
				objects.insertFront(TFood.create(x*TILE_SIZE+TILE_SIZE DIV 2, y*TILE_SIZE + TILE_SIZE DIV 2))
			ELSE IF ch = '*' THEN
				objects.insertFront(TPowerUp.create(x*TILE_SIZE+TILE_SIZE DIV 2, y*TILE_SIZE + TILE_SIZE DIV 2))
			ELSE IF ch = 'O' THEN
			BEGIN
				pac := TPacman.create(x*TILE_SIZE+TILE_SIZE DIV 2, y*TILE_SIZE+TILE_SIZE DIV 2, 2);
				objects.insertFront(pac);
			END
            ELSE IF ch = 'R' THEN
				objects.insertBack(TGhost.create(x*TILE_SIZE+TILE_SIZE DIV 2, y*TILE_SIZE+TILE_SIZE DIV 2, 2, 0))
			ELSE IF ch = 'B' THEN
            	objects.insertBack(TGhost.create(x*TILE_SIZE+TILE_SIZE DIV 2, y*TILE_SIZE+TILE_SIZE DIV 2, 2, 1))
            ELSE IF ch = 'Y' THEN
            	objects.insertBack(TGhost.create(x*TILE_SIZE+TILE_SIZE DIV 2, y*TILE_SIZE+TILE_SIZE DIV 2, 2, 2))
            ELSE IF ch = 'P' THEN
            	objects.insertBack(TGhost.create(x*TILE_SIZE+TILE_SIZE DIV 2, y*TILE_SIZE+TILE_SIZE DIV 2, 2, 3));

			READ(f, ch);
		END;
	END;

	timer1.Interval := 1000 DIV FRAMES_PER_SECOND;
	image1.width := map.getWidth()*TILE_SIZE + 120;
	image1.height := map.getHeight()*TILE_SIZE;
	autoSize := True;
	top := 0;
END;

procedure TForm1.frame(Sender: TObject);
VAR ptr : TLinkedNode;
VAR rect : TRect;
BEGIN
	ptr := NIL;
	WHILE objects.iterate(ptr) DO
		TMapObject(ptr.getObject()).move(map, objects);

	image1.canvas.Lock();
	map.draw(image1.canvas);
    ptr := NIL;
	WHILE objects.iterate(ptr) DO
		TMapObject(ptr.getObject()).draw(image1.canvas);

	rect.Left := map.getWidth() * TILE_SIZE;
	rect.top := 0;
	rect.Right := rect.left + 120;
	rect.bottom := image1.height;
	image1.Canvas.brush.Color := RGB(0,0,0);
	image1.canvas.fillRect(rect);

	image1.Canvas.font.Color := RGB(255,255,255);
	image1.Canvas.font.Style := [fsBold];
	image1.Canvas.font.Size := 12;
	image1.Canvas.TextOut(rect.left, 60, 'SCORE: ' + inttostr(pac.getScore()));
	image1.canvas.Draw(rect.Left, 90, gui);
	image1.canvas.TextOut(rect.Left + gui.Width + 5, 95, 'x ' + inttostr(pac.getLives()));

	image1.Canvas.Unlock();

	ptr := NIL;
	WHILE objects.iterate(ptr) DO
	BEGIN
		IF TMapObject(ptr.getObject()).getType() = OBJECT_GHOST THEN
		BEGIN
			IF pac.getScore() >= TGhost(ptr.getObject()).getColor()*200 THEN
				TGhost(ptr.getObject()).setAIMode(AI_CHASE);
			IF pac.isDead() THEN
				TGhost(ptr.getObject()).setAIMode(AI_IDLE);
		END;
	END;
	IF pac.isDead() AND pac.getCurrentAnimation().isOver() THEN
    BEGIN
		IF pac.getLives() > 0 THEN
		BEGIN
			pac.spawn();
			ptr := NIL;
			WHILE objects.iterate(ptr) DO
				IF TMapObject(ptr.getObject()).getType() = OBJECT_GHOST THEN
					TGhost(ptr.getObject()).spawn();
		END;
	END;
END;

END.
