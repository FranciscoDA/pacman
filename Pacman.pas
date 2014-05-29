unit Pacman;

interface

USES Windows, Variants, Classes, SysUtils, Graphics, LinkedList,
	Map, MapObject, Animation;

CONST DEFAULT_SPEED = 3;
CONST BONUS_SPEED = 5;

VAR gfx : ARRAY [0 .. 6 * 10 - 1] OF TBitmap;

TYPE TPacman = CLASS(TMobileObject)
	PUBLIC
		CONSTRUCTOR create(_x, _y, _direction : INTEGER); OVERLOAD;
		CLASS PROCEDURE loadGfx();
		PROCEDURE setDirection(dir : INTEGER);
        PROCEDURE spawn();
    	FUNCTION getScore() : INTEGER;
		FUNCTION getCurrentAnimation() : TAnimation;
		FUNCTION isDead() : BOOLEAN;
		FUNCTION getLives() : INTEGER;
		FUNCTION getType() : TMapObjectType; OVERRIDE;
		PROCEDURE onCollide(other : TMapObject; objects : TLinkedList); OVERRIDE;
		PROCEDURE move(map : TMap; objects : TLinkedList); OVERRIDE;
		PROCEDURE draw(canvas : TCanvas); OVERRIDE;
	PRIVATE
		startx, starty, startdir : INTEGER;
		dead : BOOLEAN;
		lives : INTEGER;
		score : INTEGER;
		nextDirection : INTEGER;
		currentAnimation : TAnimation;
		animations : ARRAY[0..9] OF TAnimation;
        poweruptimer : INTEGER;
END;

IMPLEMENTATION

CONSTRUCTOR TPacman.create(_x, _y, _direction : INTEGER);
VAR i : INTEGER;
BEGIN
	INHERITED create(_x, _y, TILE_SIZE, TILE_SIZE, DEFAULT_SPEED, _direction);
	startdir := direction;
	startx := getLeft();
	starty := getTop();
	FOR i := 0 TO 4 DO
		animations[i] := TAnimation.create(i*6, 6, 3, TRUE);
    FOR i := 5 TO 9 DO
		animations[i] := TAnimation.create(i*6, 6, 4, FALSE);
	lives := 3;
	spawn();
END;

CLASS PROCEDURE TPacman.loadGfx();
VAR sheet : TBitmap;
VAR i : INTEGER;
BEGIN
	sheet := TBitmap.create();
	sheet.LoadFromFile('gfx/pacman_spritesheet.bmp');
	loadSpriteSheet(sheet, 0, 0, sheet.width, sheet.height, 6, 10, gfx);
	FOR i := 0 TO LENGTH(gfx)-1 DO
		gfx[i].Transparent := TRUE;
	sheet.destroy();
END;

PROCEDURE TPacman.setDirection(dir : INTEGER);
BEGIN
	nextDirection := dir;
END;

PROCEDURE TPacman.spawn();
BEGIN
	x := startx;
    y := starty;
	direction := startdir;
    nextDirection := startdir;
	score := 0;
	dead := FALSE;
	speed := DEFAULT_SPEED;
	poweruptimer := 0;
	currentAnimation := animations[direction].start();
END;

FUNCTION TPacman.getScore() : INTEGER;
BEGIN
	getScore := score;
END;

FUNCTION TPacman.getCurrentAnimation() : TAnimation;
BEGIN
	getCurrentAnimation := currentAnimation;
END;

FUNCTION TPacman.isDead() : BOOLEAN;
BEGIN
	isDead := dead;
END;

FUNCTION TPacman.getLives() : INTEGER;
BEGIN
	getLives := lives;
END;

FUNCTION TPacman.getType() : TMapObjectType;
BEGIN
	getType := OBJECT_PACMAN;
END;

PROCEDURE TPacman.onCollide(other : TMapObject; objects : TLinkedList);
BEGIN
	IF other.getType() = OBJECT_FOOD THEN
	BEGIN
		score := score + 10;
	END
	ELSE IF other.getType() = OBJECT_POWERUP THEN
	BEGIN
		speed := BONUS_SPEED;
		powerupTimer := poweruptimer DIV 2 + 350;
	END
    ELSE IF other.getType() = OBJECT_GHOST THEN
	BEGIN
		IF NOT dead THEN
		BEGIN
	    	dead := TRUE;
			lives := lives - 1;
			currentAnimation := animations[direction+5].start();
		END;
	END
END;

PROCEDURE TPacman.move(map : TMap; objects : TLinkedList);
VAR i : INTEGER;
BEGIN
	currentAnimation.advance();
	IF powerupTimer > 0 THEN
	BEGIN
		powerupTimer := powerupTimer - 1;
		IF powerupTimer <= 0 THEN
		BEGIN
			speed := DEFAULT_SPEED;
			powerupTimer := 0;
		END;
	END;
	FOR i := 1 TO speed DO
	BEGIN
    	IF NOT dead THEN
		BEGIN
	    	INHERITED move(map, objects);
			IF canMove(x + getDirectionX(nextDirection), y + getDirectionY(nextDirection), map) THEN
				IF direction <> nextDirection THEN
				BEGIN
					direction := nextDirection;
					currentAnimation := animations[direction].resume(currentAnimation);
				END;
		END
	END;
END;

PROCEDURE TPacman.draw(canvas : TCanvas);
VAR spriteid : INTEGER;
BEGIN
	spriteId := currentAnimation.getSpriteId();
	canvas.Draw(getCenterX() - gfx[spriteid].Width DIV 2,
		getCenterY() - gfx[spriteid].Height DIV 2,
		gfx[spriteid]);
END;

END.
