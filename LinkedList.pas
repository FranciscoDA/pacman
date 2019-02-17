UNIT LinkedList;

{$MODE Delphi}

INTERFACE

TYPE TLinkedNode = CLASS
	PUBLIC
		CONSTRUCTOR create(o : TObject);
		DESTRUCTOR destroy();
		FUNCTION getObject() : TObject;
		FUNCTION getNext() : TLinkedNode;
		FUNCTION getPrev() : TLinkedNode;
	PROTECTED
		obj : TObject;
		next : TLinkedNode;
		prev : TLinkedNode;
END;

TYPE TLinkedList = CLASS
	PUBLIC
		CONSTRUCTOR create();
		DESTRUCTOR destroy();
		FUNCTION isEmpty() : BOOLEAN;
		FUNCTION getFirst() : TLinkedNode;
		FUNCTION getLast() : TLinkedNode;

		PROCEDURE reverse();
		FUNCTION iterate(VAR n : TLinkedNode) : BOOLEAN;

		FUNCTION release(n : TLinkedNode) : TObject; OVERLOAD;
		FUNCTION release(o : TObject) : TObject; OVERLOAD;
		FUNCTION findObject(o : TObject) : TLinkedNode;

		FUNCTION insert(prev : TLinkedNode; o : TObject) : TLinkedNode; OVERLOAD;
		FUNCTION insert(prev : TLinkedNode; n : TLinkedNode) : TLinkedNode; OVERLOAD;

		FUNCTION insertFront(n : TLinkedNode) : TLinkedNode; OVERLOAD;
		FUNCTION insertFront(o : TObject) : TLinkedNode; OVERLOAD;

		FUNCTION insertBack(n : TLinkedNode) : TLinkedNode; OVERLOAD;
		FUNCTION insertBack(o : TObject) : TLinkedNode; OVERLOAD;
	PRIVATE
		first : TLinkedNode;
		last : TLinkedNode;
END;

IMPLEMENTATION

CONSTRUCTOR TLinkedNode.create(o : TObject);
BEGIN
	obj := o;
	next := NIL;
	prev := NIL;
END;

DESTRUCTOR TLinkedNode.destroy();
BEGIN
	INHERITED destroy();
END;

FUNCTION TLinkedNode.getObject() : TObject;
BEGIN
	getObject := obj;
END;

FUNCTION TLinkedNode.getNext() : TLinkedNode;
BEGIN
	getNext := next;
END;

FUNCTION TLinkedNode.getPrev() : TLinkedNode;
BEGIN
	getPrev := prev;
END;

CONSTRUCTOR TLinkedList.create();
BEGIN
	first := NIL;
	last := NIL;
END;

DESTRUCTOR TLinkedList.destroy();
VAR ptr, n : TLinkedNode;
BEGIN
	ptr := first;
	WHILE ptr <> NIL DO
	BEGIN
		n := ptr.next;
		ptr.obj.Destroy();
		ptr.destroy();
		ptr := n;
	END;
END;

FUNCTION TLinkedList.isEmpty(): BOOLEAN;
BEGIN
	isEmpty := (first = NIL);
END;

FUNCTION TLinkedList.getFirst() : TLinkedNode;
BEGIN
	getFirst := first;
END;

FUNCTION TLinkedList.getLast() : TLinkedNode;
BEGIN
	getLast := last;
END;

PROCEDURE TLinkedList.reverse();
VAR ptr, swap : TLinkedNode;
BEGIN
	ptr := getFirst();
	WHILE ptr <> NIL DO
	BEGIN
		swap := ptr.next;
		ptr.next := ptr.prev;
		ptr.prev := swap;
		ptr := swap;
	END;
END;

FUNCTION TLinkedList.iterate(VAR n : TLinkedNode) : BOOLEAN;
BEGIN
	IF n = NIL THEN
		n := getFirst()
	ELSE
		n := n.getNext();
	iterate := n <> NIL;
END;

FUNCTION TLinkedList.release(n : TLinkedNode) : TObject;
BEGIN
	IF n.getPrev() <> NIL THEN
		n.prev.next := n.next;
	IF n.getNext() <> NIL THEN
		n.next.prev := n.prev;
	IF n = first THEN
		first := n.getNext();
	IF n = last THEN
		last := n.getPrev();
	release := n.getObject();
	n.destroy();
END;

FUNCTION TLinkedList.release(o : TObject) : TObject;
VAR ptr : TLinkedNode;
BEGIN
	ptr := findObject(o);
	IF ptr <> NIL THEN
		release := release(ptr)
	ELSE
		release := NIL;
END;

FUNCTION TLinkedList.findObject(o : TObject) : TLinkedNode;
VAR ptr : TLinkedNode;
BEGIN
	ptr := getFirst();
	WHILE (ptr <> NIL) AND (ptr.getObject() <> o) DO
		ptr := ptr.getNext();
	findObject := ptr;
END;

FUNCTION TLinkedList.insert(prev : TLinkedNode; n : TLinkedNode) : TLinkedNode;
BEGIN
	IF prev = NIL THEN
	BEGIN
		IF first <> NIL THEN
		BEGIN
			first.prev := n;
			n.next := first;
		END;
		first := n;
	END
    ELSE
	BEGIN
		n.next := prev.getNext();
		n.prev := prev;
		IF prev.getNext() <> NIL THEN
			prev.next.prev := n;
		prev.next := n;
	END;
	IF prev = last THEN
		last := n;
	insert := n;
END;

FUNCTION TLinkedList.insert(prev : TLinkedNode; o : TObject) : TLinkedNode;
BEGIN
	insert := insert(prev, TLinkedNode.create(o));
END;

FUNCTION TLinkedList.insertFront(n : TLinkedNode) : TLinkedNode;
BEGIN
	insertFront := insert(NIL, n);
END;

FUNCTION TLinkedList.insertFront(o : TObject) : TLinkedNode;
BEGIN
	insertFront := insertFront(TLinkedNode.create(o));
END;

FUNCTION TLinkedList.insertBack(n : TLinkedNode) : TLinkedNode;
BEGIN
	insertBack := insert(last, n);
END;

FUNCTION TLinkedList.insertBack(o : TObject) : TLinkedNode;
BEGIN
	insertBack := insertBack(TLinkedNode.create(o));
END;

END.
