unit Food;

{$MODE Delphi}

INTERFACE

USES LCLIntf, LCLType, LMessages, Graphics, Classes, MapObject, Map, LinkedList;

VAR gfx : ARRAY [1..2] OF TBitmap;

VAR foodCount : INTEGER = 0;

TYPE TFood = CLASS(TMapObject)
	PUBLIC
		CONSTRUCTOR create(_x,_y : INTEGER); OVERLOAD;
		CLASS PROCEDURE loadGfx();
		CLASS FUNCTION getCount() : INTEGER;
		FUNCTION getType() : TMapObjectType; OVERRIDE;
		PROCEDURE onCollide(other : TMapObject; objects : TLinkedList); OVERRIDE;
		PROCEDURE move(map : TMap; objects : TLinkedList); OVERRIDE;
		PROCEDURE draw(canvas : TCanvas); OVERRIDE;
END;

TYPE TPowerUp = CLASS(TMapObject)
	PUBLIC
		CONSTRUCTOR create(_x, _y : INTEGER); OVERLOAD;
		CLASS PROCEDURE loadGfx();
		FUNCTION getType() : TMapObjectType; OVERRIDE;
		PROCEDURE onCollide(other : TMapObject; objects : TLinkedList); OVERRIDE;
		PROCEDURE move(map : TMap; objects : TLinkedList); OVERRIDE;
		PROCEDURE draw(canvas : TCanvas); OVERRIDE;
END;

IMPLEMENTATION

CONSTRUCTOR TFood.create(_x,_y : INTEGER);
BEGIN
	INHERITED create(_x, _y, 0, 0);
	foodCount := foodCount + 1;
END;

CLASS PROCEDURE TFood.loadGfx();
BEGIN
	gfx[1] := TBitmap.create();
	gfx[1].loadFromFile('gfx/food.bmp');
END;

CLASS FUNCTION TFood.getCount() : INTEGER;
BEGIN
	getCount := foodCount;
END;

FUNCTION TFood.getType() : TMapObjectType;
BEGIN
	getType := OBJECT_FOOD;
END;

PROCEDURE TFood.onCollide(other : TMapObject; objects : TLinkedList);
BEGIN
	IF other.getType() = OBJECT_PACMAN THEN
	BEGIN
		objects.release(self).destroy();
        foodCount := foodCount -  1;
	END;
END;

PROCEDURE TFood.move(map : TMap; objects : TLinkedList);
BEGIN
END;

PROCEDURE TFood.draw(canvas : TCanvas);
BEGIN
  canvas.Draw(getLeft() + getWidth() DIV 2 - gfx[1].width DIV 2,
    getTop() + getHeight() DIV 2 - gfx[1].Height DIV 2,
    gfx[1]);
END;

CONSTRUCTOR TPowerUp.create(_x, _y : INTEGER);
BEGIN
	INHERITED create(_x, _y, 0, 0);
END;

CLASS PROCEDURE TPowerUp.loadGfx();
BEGIN
	gfx[2] := TBitmap.create();
	gfx[2].loadFromFile('gfx/powerup.bmp');
END;

FUNCTION TPowerUp.getType() : TMapObjectType;
BEGIN
	getType := OBJECT_POWERUP;
END;

PROCEDURE TPowerUp.onCollide(other : TMapObject; objects : TLinkedList);
BEGIN
	IF other.getType() = OBJECT_PACMAN THEN
	BEGIN
		objects.release(self).destroy();
	END;
END;

PROCEDURE TPowerUp.move(map : TMap; objects : TLinkedList);
BEGIN
END;

PROCEDURE TPowerUp.draw(canvas : TCanvas);
BEGIN
	canvas.draw(getLeft() + getWidth() DIV 2 - gfx[2].width DIV 2,
		getTop() + getHeight() DIV 2 - gfx[2].height DIV 2,
		gfx[2]);
END;

END.
