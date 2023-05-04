unit MapObject;

{$MODE Delphi}

INTERFACE

USES LCLIntf, LCLType, LMessages, Graphics, Classes, Map, LinkedList;

TYPE TMapObjectType = (OBJECT_FOOD, OBJECT_POWERUP, OBJECT_PACMAN, OBJECT_GHOST);

TYPE TMapObject = CLASS
	PUBLIC
		CONSTRUCTOR create(_x, _y, _w, _h : INTEGER); OVERLOAD;

		FUNCTION getLeft() : INTEGER;
		FUNCTION getTop() : INTEGER;
		FUNCTION getRight() : INTEGER;
		FUNCTION getBottom() : INTEGER;
		FUNCTION getWidth() : INTEGER;
		FUNCTION getHeight() : INTEGER;
		FUNCTION getCenterX() : INTEGER;
		FUNCTION getCenterY() : INTEGER;
		FUNCTION collides(other : TMapObject) : BOOLEAN;

		FUNCTION getType() : TMapObjectType; VIRTUAL; ABSTRACT;
		PROCEDURE onCollide(other : TMapObject; objects : TLinkedList); VIRTUAL; ABSTRACT;
		PROCEDURE move(map : TMap; objects : TLinkedList); VIRTUAL; ABSTRACT;
		PROCEDURE draw(canvas : TCanvas); VIRTUAL; ABSTRACT;

		FUNCTION blocksMovement(tile : TTile) : BOOLEAN; OVERLOAD; VIRTUAL;
		FUNCTION blocksMovement(other : TMapObject) : BOOLEAN; OVERLOAD; VIRTUAL;
	PROTECTED
		x,y,w,h : INTEGER;
END;

TYPE TMobileObject = CLASS(TMapObject)
	PUBLIC
		CONSTRUCTOR create(_x, _y, _w, _h, _speed, _direction : INTEGER);
		PROCEDURE setDirection(dir : INTEGER);
		FUNCTION getDirectionX(dir : INTEGER) : INTEGER;
		FUNCTION getDirectionY(dir : INTEGER) : INTEGER;
		FUNCTION getDirection() : INTEGER;
		FUNCTION canMove(newx, newy : INTEGER; map : TMap) : BOOLEAN;
		PROCEDURE move(map : TMap; objects : TLinkedList); OVERRIDE;
	PROTECTED
		speed : INTEGER;
		direction : INTEGER;
END;

PROCEDURE loadSpriteSheet(bmp : TBitmap; x1,y1,x2,y2, xt, yt : INTEGER; VAR arr : ARRAY OF TBitmap);

IMPLEMENTATION

CONSTRUCTOR TMapObject.create(_x, _y, _w, _h : INTEGER);
BEGIN
	w := _w;
	h := _h;
	x := _x - w DIV 2;
	y := _y - h DIV 2;
END;

FUNCTION TMapObject.getLeft() : INTEGER;
BEGIN
	getLeft := x;
END;

FUNCTION TMapObject.getTop() : INTEGER;
BEGIN
	getTop := y;
END;

FUNCTION TMapObject.getRight() : INTEGER;
BEGIN
  getRight := x + w;
END;
FUNCTION TMapObject.getBottom() : INTEGER;
BEGIN
  getBottom := y + h;
END;

FUNCTION TMapObject.getWidth() : INTEGER;
BEGIN
	getWidth := w;
END;

FUNCTION TMapObject.getHeight() : INTEGER;
BEGIN
	getHeight := h;
END;

FUNCTION TMapObject.getCenterX() : INTEGER;
BEGIN
	getCenterX := x + w DIV 2;
END;

FUNCTION TMapObject.getCenterY() : INTEGER;
BEGIN
	getCenterY := y + h DIV 2;
END;

FUNCTION TMapObject.blocksMovement(tile : TTile) : BOOLEAN;
BEGIN
	blocksMovement := (tile <> 0);
END;

FUNCTION TMapObject.blocksMovement(other : TMapObject) : BOOLEAN;
BEGIN
	blocksMovement := FALSE;
END;

FUNCTION TMapObject.collides(other : TMapObject) : BOOLEAN;
BEGIN
	collides := NOT (
		(getLeft() > other.getRight()) OR
		(getRight() < other.getLeft()) OR
		(getTop() > other.getBottom()) OR
		(getBottom() < other.getTop())
	);
END;

CONSTRUCTOR TMobileObject.create(_x, _y, _w, _h, _speed, _direction : INTEGER);
BEGIN
	INHERiTED create(_x, _y, _w, _h);
	speed := _speed;
	direction := _direction;
END;

PROCEDURE TMobileObject.setDirection(dir : INTEGER);
BEGIN
	direction := dir;
END;

FUNCTION TMobileObject.getDirectionX(dir : INTEGER) : INTEGER;
BEGIN
	IF dir = 2 THEN
		getDirectionX := 1
	ELSE IF dir = 4
		THEN getDirectionX := -1
	ELSE
		getDirectionX := 0;
END;

FUNCTION TMobileObject.getDirectionY(dir : INTEGER) : INTEGER;
BEGIN
	IF dir = 1 THEN
		getDirectionY := -1
	ELSE IF dir = 3 THEN
		getDirectionY := 1
	ELSE
		getDirectionY := 0;
END;

FUNCTION TMobileObject.getDirection() : INTEGER;
BEGIN
	getDirection := direction;
END;

FUNCTION TMobileObject.canMove(newx, newy : INTEGER; map : TMap) : BOOLEAN;
VAR tx, ty : INTEGER;
BEGIN
	canMove := TRUE;
	FOR tx := 0 TO (getWidth()-1) DIV TILE_SIZE DO
		FOR ty := 0 TO (getHeight()-1) DIV TILE_SIZE DO
			IF blocksMovement(map.getPixel(newx + tx*TILE_SIZE, newy + ty*TILE_SIZE)) THEN
				canMove := FALSE;
    FOR tx := 0 TO (getWidth()-1) DIV TILE_SIZE DO
		IF blocksMovement(map.getPixel(newx + tx*TILE_SIZE, newy+h-1)) THEN
			canMove := FALSE;
	FOR ty := 0 TO (getHeight()-1) DIV TILE_SIZE DO
		IF blocksMovement(map.getPixel(newx+w-1, newy+ty*TILE_SIZE)) THEN
			canMove := FALSE;
	IF blocksMovement(map.getPixel(newx + w - 1, newy + h - 1)) THEN
		canMove := FALSE;
END;

PROCEDURE TMobileObject.move(map : TMap; objects : TLinkedList);
VAR newx, newy : INTEGER;
VAR ptr, next : TLinkedNode;
BEGIN
	newx := x + getDirectionX(direction);
	newy := y + getDirectionY(direction);
	IF canMove(newx, newy, map) THEN
	BEGIN
		IF newx >= map.getWidth()*TILE_SIZE THEN newx := -w+1;
		IF newx <= -w THEN newx := map.getWidth()*TILE_SIZE-1;
		IF newy >= map.getHeight()*TILE_SIZE THEN newy := -h+1;
		IF newy <= -h THEN newy := map.getHeight()*TILE_SIZE-1;
		x := newx;
		y := newy;
	END;

	ptr := objects.getFirst();
	WHILE ptr <> NIL DO
	BEGIN
		next := ptr.getNext();
		IF ptr.getObject() <> self THEN
		BEGIN
			IF collides(TMapObject(ptr.getObject())) THEN
			BEGIN
				onCollide(TMapObject(ptr.getObject()), objects);
				TMapObject(ptr.getObject()).onCollide(self, objects);
			END;
		END;
		ptr := next;
    END;
END;


PROCEDURE loadSpriteSheet(bmp : TBitmap; x1,y1,x2,y2, xt, yt : INTEGER; VAR arr : ARRAY OF TBitmap);
VAR x, y, sprw, sprh : INTEGER;
VAR src, dest : TRect;
BEGIN
	sprw := (x2-x1) DIV xt;
	sprh := (y2-y1) DIV yt;
	dest.left := 0;
	dest.top := 0;
	dest.right := sprw;
	dest.bottom := sprh;
	FOR y := 0 TO yt-1 DO
	BEGIN
		src.top := y1+y*sprh;
		src.bottom := src.top + sprh;
		FOR x := 0 TO xt-1 DO
		BEGIN
			src.left := x1+x*sprw;
			src.right := src.left + sprw;
			arr[y*xt+x] := TBitmap.create();
			arr[y*xt+x].width := sprw;
			arr[y*xt+x].height := sprh;
			arr[y*xt+x].canvas.copyRect(dest, bmp.canvas, src);
                        arr[y*xt+x].TransparentColor := clFuchsia;
		END
	END;
END;

END.
