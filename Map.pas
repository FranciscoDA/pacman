unit Map;

INTERFACE

USES windows, sysutils, graphics;

CONST TILE_SIZE = 24;

VAR gfx : TBitmap;

TYPE TTile = BYTE;

TYPE TMap = CLASS
	PUBLIC
		CONSTRUCTOR create(_w, _h : INTEGER); OVERLOAD;
		CLASS PROCEDURE loadGfx();
		FUNCTION getTile(x, y : INTEGER) : TTILE;
		FUNCTION getPixel(x, y : INTEGER) : TTILE;
		PROCEDURE setTile(x, y : INTEGER; t : TTILE);
		FUNCTION getWidth() : INTEGER;
		FUNCTION getHeight() : INTEGER;
		PROCEDURE draw(canvas : TCanvas);
	PRIVATE
		data : ARRAY OF TTILE;
		w, h : INTEGER;
END;

IMPLEMENTATION

CONSTRUCTOR TMap.create(_w, _h : INTEGER);
BEGIN
	w := _w;
	h := _h;
	SETLENGTH(data, w*h);
END;

CLASS PROCEDURE TMap.loadGfx();
VAR i : INTEGER;
BEGIN
	gfx := TBitmap.Create();
	gfx.loadFromFile('gfx/tileset.bmp');
END;

FUNCTION TMap.getTile(x, y : INTEGER) : TTILE;
BEGIN
	IF (y < 0) OR (y > h-1) OR (x < 0) OR (x > w-1) THEN
		getTile := 0
	ELSE
		getTile := data[y*w+x];
END;

FUNCTION TMap.getPixel(x, y : INTEGER) : TTILE;
BEGIN
	getPixel := getTile(x DIV TILE_SIZE, y DIV TILE_SIZE);
END;

PROCEDURE TMap.setTile(x, y : INTEGER; t : TTILE);
BEGIN
	data[y*w+x] := t;
END;

FUNCTION TMap.getWidth() : INTEGER;
BEGIN
	getWidth := w;
END;

FUNCTION TMap.getHeight() : INTEGER;
BEGIN
	getHeight := h;
END;

PROCEDURE TMap.draw(canvas : TCanvas);
VAR x, y, tile : INTEGER;
VAR dest, src : TRECT;
BEGIN
	FOR x := 0 TO getWidth()-1 DO
	BEGIN
		FOR y := 0 TO getHeight()-1 DO
		BEGIN
			tile := 6;
			IF getTile(x,y) > 0 THEN
			BEGIN
				IF (getTile(x-1, y)<>0) AND (getTile(x+1, y)=0) THEN tile := 7;
				IF (getTile(x+1, y)<>0) AND (getTile(x-1, y)=0) THEN tile := 8;
				IF (getTile(x, y+1)<>0) AND (getTile(x, y-1)=0)THEN tile := 10;
				IF (getTile(x, y-1)<>0) AND (getTile(x, y+1)=0)THEN tile := 9;
				IF (getTile(x, y+1)<>0) AND (getTile(x, y-1)<>0) AND ((getTile(x+1,y)=0) OR (getTile(x-1,y)=0)) THEN tile := 1;
				IF (getTile(x+1, y)<>0) AND (getTile(x-1, y)<>0) AND ((getTile(x,y+1)=0) OR (getTile(x,y-1)=0)) THEN tile := 0;
				IF (getTile(x+1, y)<>0) AND (getTile(x, y+1)<>0) AND ((getTile(x+1, y+1)=0) OR (getTile(x-1, y)=0) AND (getTile(x, y-1)=0)) THEN tile := 5;
				IF (getTile(x+1, y)<>0) AND (getTile(x, y-1)<>0) AND ((getTile(x+1, y-1)=0) OR (getTile(x-1, y)=0) AND (getTile(x, y+1)=0)) THEN tile := 4;
				IF (getTile(x-1, y)<>0) AND (getTile(x, y+1)<>0) AND ((getTile(x-1, y+1)=0) OR (getTile(x+1, y)=0) AND (getTile(x, y-1)=0)) THEN tile := 2;
				IF (getTile(x-1, y)<>0) AND (getTile(x, y-1)<>0) AND ((getTile(x-1, y-1)=0) OR (getTile(x+1, y)=0) AND (getTile(x, y+1)=0)) THEN tile := 3;
				tile := tile + (getTile(x,y)-1)*12;
			END
			ELSE
				tile := 11;

			dest.left := x*TILE_SIZE;
			dest.top := y * TILE_SIZE;
			dest.right := dest.left + TILE_SIZE;
			dest.bottom := dest.top + TILE_SIZE;

			src.left := (tile MOD (gfx.width DIV TILE_SIZE)) * TILE_SIZE;
			src.top := (tile DIV (gfx.width DIV TILE_SIZE)) * TILE_SIZE;
			src.right := src.left + TILE_SIZE;
			src.bottom := src.top + TILE_SIZE;

			canvas.copyRect(dest, gfx.canvas, src);
		END;
	END;
END;

END.
