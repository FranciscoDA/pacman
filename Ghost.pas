UNIT Ghost;

INTERFACE

USES Windows, Graphics, Classes, Map, MapObject, LinkedList, Animation,
	Astar;

CONST NUM_COLORS = 4;
CONST DEFAULT_SPEED = 2;

TYPE AIMode = (AI_SLEEP, AI_CHASE, AI_IDLE);

VAR gfx : ARRAY [0.. NUM_COLORS * 5 * 4 - 1] OF TBitmap;

TYPE TGhost = CLASS(TMobileObject)
	PUBLIC
		CONSTRUCTOR create(_x, _y, _direction, _color : INTEGER);
        CLASS PROCEDURE loadGfx();
		PROCEDURE spawn();
		PROCEDURE setAIMode(m : AIMode);
		FUNCTION getColor() : INTEGER;

		FUNCTION blocksMovement(tile : TTile) : BOOLEAN; OVERRIDE;

		FUNCTION getType() : TMapObjectType; OVERRIDE;
		PROCEDURE onCollide(other : TMapObject; objects : TLinkedList); OVERRIDE;
		PROCEDURE move(map : TMap; objects : TLinkedList); OVERRIDE;
		PROCEDURE draw(canvas : TCanvas); OVERRIDE;
	PRIVATE
		startx, starty : INTEGER;
		animations : ARRAY [0..4] OF TAnimation;
		currentAnimation : TAnimation;
        color : INTEGER;
		path : TLinkedList;
		mode : AIMode;
END;

IMPLEMENTATION

CONSTRUCTOR TGhost.create(_x, _y, _direction, _color : INTEGER);
VAR i : INTEGER;
BEGIN
	INHERITED create(_x, _y, TILE_SIZE, TILE_SIZE, DEFAULT_SPEED, 0);
	startx := getLeft();
	starty := getTop();
	path := TLinkedList.create();
    color := _color;
	FOR i := 0 TO LENGTH(animations)-1 DO
		animations[i] := TAnimation.create(i*4, 4, 3, TRUE);
	spawn();
END;

PROCEDURE TGhost.spawn();
BEGIN
	x := startx;
	y := starty;
	setAiMode(AI_SLEEP);
	path.destroy();
	path := TlinkedList.create();
	direction := 0;
	currentAnimation := animations[direction].start();
	speed := DEFAULT_SPEED;
END;

PROCEDURE TGhost.setAIMode(m : AIMode);
BEGIN
	mode := m;
END;

FUNCTION TGhost.getColor() : INTEGER;
BEGIN
	getColor := color;
END;

CLASS PROCEDURE TGhost.loadGfx();
VAR sheet : TBitmap;
VAR i : INTEGER;
BEGIN
	sheet := TBitmap.create();
    sheet.loadFromFile('gfx/ghost_spritesheet.bmp');
	loadSpriteSheet(sheet, 0, 0, sheet.width, sheet.height, 4, NUM_COLORS * 5, gfx);
	FOR i := 0 TO LENGTH(gfx)-1 DO
		gfx[i].transparent := TRUE;
	sheet.Destroy();
END;

FUNCTION TGhost.blocksMovement(tile : TTile) : BOOLEAN;
BEGIN
	blocksMovement := tile = 1;
END;

FUNCTION TGhost.getType() : TMapObjectType;
BEGIN
	getType := OBJECT_GHOST;
END;

PROCEDURE TGhost.onCollide (other : TMapObject; objects : TLinkedList);
BEGIN
END;

PROCEDURE TGhost.move (map : TMap; objects : TLinkedList);
VAR ptr : TLinkedNode;
VAR pac : TMapObject;
VAR forbiddenNodes : TLinkedList;
VAR nextTile, firstTile : TPathNode;
VAR i : INTEGER;
BEGIN
	IF currentAnimation <> animations[direction] THEN
		currentAnimation := animations[direction].resume(currentAnimation);
	currentAnimation.advance();

	ptr := NIL;
    pac := NIL;
	WHILE objects.iterate(ptr) DO
		IF TMapObject(ptr.getObject()).getType() = OBJECT_PACMAN THEN
			BREAK;

    IF ptr <> NIL THEN
		pac := TMapObject(ptr.getObject());

    forbiddenNodes := TLinkedList.create();
	ptr := NIL;
	WHILE objects.iterate(ptr) DO
	BEGIN
		IF TMapObject(ptr.getObject()).getType() = OBJECT_GHOST THEN
		BEGIN
			IF TGhost(ptr.getObject()).mode = AI_CHASE THEN
				forbiddenNodes.insertBack(TPathNode.create(
					TMapObject(ptr.getObject()).getLeft() DIV TILE_SIZE,
					TMapObject(ptr.getObject()).getTop() DIV TILE_SIZE)
				);
		END;
	END;
	FOR i := 1 TO speed DO
	BEGIN
		nextTile := NIL;
		IF mode = AI_CHASE THEN
		BEGIN
			IF path.isEmpty() OR ((heuristic(TPathNode(path.getLast().getObject()).x, TPathNode(path.getLast().getObject()).y,
				pac.getCenterX() DIV TILE_SIZE, pac.getCenterY() DIV TILE_SIZE) > 0)) THEN
			BEGIN
				path.destroy();
				path := TLinkedList.create();

				findPath(getLeft() DIV TILE_SIZE, getTop() DIV TILE_SIZE,
					pac.getLeft() DIV TILE_SIZE, pac.getTop() DIV TILE_SIZE,
					map, self, forbiddenNodes, path);

				IF NOT path.isEmpty() THEN
				BEGIN
					firstTile := TPathNode(path.release(path.getFirst()));
					IF NOT path.isEmpty() THEN
					BEGIN
						IF (TPathNode(path.getFirst().getObject()).x*TILE_SIZE <> getLeft()) AND
							(TPathNode(path.getFirst().getObject()).y*TILE_SIZE <> getTop()) THEN
							path.insertFront(firstTile)
						ELSE
							firstTile.Destroy();
					END;
				END;
			END;

			WHILE (nextTile = NIL) AND (NOT path.isEmpty()) DO
			BEGIN
				nextTile := TPathNode(path.getFirst().getObject());
				IF (nextTile.x*TILE_SIZE = getLeft()) AND (nextTile.y*TILE_SIZE = getTop()) THEN
		        BEGIN
					path.release(path.getFirst()).destroy();
					nextTile := NIL;
				END;
			END;
		END;
		IF nextTile <> NIL THEN
		BEGIN
			IF nextTile.x*TILE_SIZE > getLeft() THEN
				setDirection(2);
			IF nextTile.x*TILE_SIZE < getLeft() THEN
				setDirection(4);
			IF nextTile.y*TILE_SIZE > getTop() THEN
				setDirection(3);
			IF nextTile.y*TILE_SIZE < getTop() THEN
				setDirection(1);
		END
		ELSE
			setDirection(0);

		IF currentAnimation <> animations[direction] THEN
			currentAnimation := animations[direction].resume(currentAnimation);

		INHERITED move(map, objects);
	END;
	forbiddenNodes.destroy();
END;

PROCEDURE TGhost.draw(canvas : TCanvas);
VAR spriteid : INTEGER;
BEGIN
	spriteid := color*4*5 + currentAnimation.getSpriteId();
    canvas.draw(getCenterX() - gfx[spriteid].width DIV 2,
		getCenterY() - gfx[spriteid].Height DIV 2, gfx[spriteid]);
END;

END.
