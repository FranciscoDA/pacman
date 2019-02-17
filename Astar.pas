UNIT Astar;

{$MODE Delphi}

INTERFACE

USES LinkedList, Map, MapObject;

TYPE TPathNode = CLASS
	PUBLIC
		x, y : INTEGER;
		prev : TPathNode;
		CONSTRUCTOR create(_x, _y, destx, desty : INTEGER; _prev : TPathNode); OVERLOAD;
		CONSTRUCTOR create(_x, _y : INTEGER); OVERLOAD;
		FUNCTION getG() : INTEGER;
		FUNCTION getH() : INTEGER;
		FUNCTION getF() : INTEGER;
	PRIVATE
		g : INTEGER;
		f : INTEGER;
END;

FUNCTION heuristic(x1, y1, x2, y2 : INTEGER) : INTEGER;

PROCEDURE pushPathNode(VAR openNodes, closedNodes, forbiddenNodes : TLinkedList; node : TPathNode);

PROCEDURE findPath(startx, starty, destx, desty : INTEGER; map : TMap; o : TMapObject; VAR forbiddenNodes, result : TLinkedList);

IMPLEMENTATION

CONSTRUCTOR TPathNode.create(_x, _y, destx, desty : INTEGER; _prev : TPathNode);
BEGIN
	x := _x;
	y := _y;
	prev := _prev;
	IF prev <> NIL THEN
		g := prev.getG()+1
	ELSE
		g := 0;
	f := g + heuristic(x, y, destx, desty);
END;

CONSTRUCTOR TPathNode.create(_x, _y : INTEGER);
BEGIN
	x := _x;
	y := _y;
END;

FUNCTION TPathNode.getG() : INTEGER;
BEGIN
	getG := g;
END;

FUNCTION TPathNode.getH() : INTEGER;
BEGIN
	getH := f - g;
END;

FUNCTION TPathNode.getF() : INTEGER;
BEGIN
	getF := f;
END;

FUNCTION heuristic(x1, y1, x2, y2 : INTEGER) : INTEGER; //manhattan h
BEGIN
	heuristic := ABS(x1-x2) + ABS(y1-y2);
END;

PROCEDURE pushPathNode(VAR openNodes, closedNodes, forbiddenNodes : TLinkedList; node : TPathNode);
VAR ptr : TLinkedNode;
BEGIN
	ptr := NIL;
	WHILE closedNodes.iterate(ptr) DO
		IF (TPathNode(ptr.getObject()).x = node.x) AND (TPathNode(ptr.getObject()).y = node.y) THEN
			BREAK;
	IF ptr = NIL THEN
		WHILE forbiddenNodes.iterate(ptr) DO
			IF (TPathNode(ptr.getObject()).x = node.x) AND (TPathNode(ptr.getObject()).y = node.y) THEN
				BREAK;

	IF ptr <> NIL THEN
		node.Destroy()
	ELSE
	BEGIN
		WHILE openNodes.iterate(ptr) DO
		BEGIN
			IF (TPathNode(ptr.getObject()).x = node.x) AND (TPathNode(ptr.getObject()).y = node.y) THEN
			BEGIN
				IF TPathNode(ptr.getObject()).getF() > node.getF() THEN
				BEGIN
					openNodes.release(ptr).destroy();
					ptr := NIL;
				END;
				BREAK;
			END;
		END;
		IF ptr = NIL THEN
		BEGIN
			WHILE openNodes.iterate(ptr) DO
				IF TPathNode(ptr.getObject()).getF() > node.getF() THEN
					BREAK;
			IF ptr <> NIL THEN
		        openNodes.insert(ptr.getPrev(), node)
			ELSE
				openNodes.insertBack(node);
		END;
	END;
END;

PROCEDURE findPath(startx, starty, destx, desty : INTEGER; map : TMap; o : TMapObject; VAR forbiddenNodes, result : TLinkedList);
VAR openNodes, closedNodes : TLinkedList;
VAR ptr : TLinkedNode;
VAR currentNode, last : TPathNode;
VAR currentX, currentY : INTEGER;
BEGIN
	openNodes := TLinkedList.create();
	closedNodes := TLinkedList.create();
	ptr := NIL;

	IF NOT o.blocksMovement(map.getTile(destx, desty)) THEN
	BEGIN
		openNodes.insertFront(TPathNode.create(startx, starty, destx, desty, NIL));
		WHILE NOT openNodes.isEmpty() DO
		BEGIN
	    	currentNode := TPathNode(openNodes.release(openNodes.getFirst()));
			currentX := currentNode.x;
			currentY := currentNode.y;
			IF (currentX = destx) AND (currentY = desty) THEN
			BEGIN
				last := currentNode;
				WHILE last <> NIL DO
				BEGIN
					result.insertFront(TPathNode.create(last.x, last.y));
					last := last.prev;
				END;
				BREAK;
			END;
			closedNodes.insertBack(currentNode);

	        IF NOT o.blocksMovement(map.getTile(currentX-1, currentY)) AND (currentX>0) THEN
				pushPathNode(openNodes, closedNodes, forbiddenNodes,
					TPathNode.create(currentX-1, currentY, destx, desty, currentNode));

	        IF NOT o.blocksMovement(map.getTile(currentX+1, currentY)) AND (currentX<map.getWidth()) THEN
				pushPathNode(openNodes, closedNodes, forbiddenNodes,
					TPathNode.create(currentX+1, currentY, destx, desty, currentNode));

	        IF NOT o.blocksMovement(map.getTile(currentX, currentY-1)) AND (currentY>0) THEN
				pushPathNode(openNodes, closedNodes, forbiddenNodes,
					TPathNode.create(currentX, currentY-1, destx, desty, currentNode));

	        IF NOT o.blocksMovement(map.getTile(currentX, currentY+1)) AND (currentY<map.getHeight()) THEN
				pushPathNode(openNodes, closedNodes, forbiddenNodes,
					TPathNode.create(currentX, currentY+1, destx, desty, currentNode));
		END;
	END;
	openNodes.destroy();
	closedNodes.destroy();
END;

END.
