UNIT Animation;

{$MODE Delphi}

INTERFACE

TYPE TAnimation = CLASS
	PUBLIC
		CONSTRUCTOR create(_offset, _frames, _duration : INTEGER; _loops : BOOLEAN);

		PROCEDURE advance();

		FUNCTION start() : TAnimation;
		FUNCTION resume(other : TAnimation) : TAnimation;

		FUNCTION isOver() : BOOLEAN;
		FUNCTION getSpriteId() : INTEGER;

	PRIVATE
		loops : BOOLEAN;
		current_frame : INTEGER;
		sprite_offset : INTEGER;
		total_frames : INTEGER;
		total_duration : INTEGER;
END;

IMPLEMENTATION

CONSTRUCTOR TAnimation.create(_offset, _frames, _duration : INTEGER; _loops : BOOLEAN);
BEGIN
	sprite_offset := _offset;
	total_frames := _frames;
	total_duration := _duration;
	current_frame := 0;
	loops := _loops;
END;

PROCEDURE TAnimation.advance();
BEGIN
	IF loops THEN
		current_frame := (current_frame+1) MOD (total_frames*total_duration)
	ELSE
		IF current_frame < total_frames*total_duration-1 THEN
			current_frame := current_frame + 1;
END;

FUNCTION TAnimation.start() : TAnimation;
BEGIN
	current_frame := 0;
	start := self;
END;

FUNCTION TAnimation.resume(other : TAnimation) : TAnimation;
BEGIN
	current_frame := (other.current_frame) MOD (total_frames*total_duration);
	resume := self;
END;

FUNCTION TAnimation.isOver() : BOOLEAN;
BEGIN
	isOver := (NOT loops) AND (current_frame = total_frames*total_duration-1);
END;

FUNCTION TAnimation.getSpriteId() : INTEGER;
BEGIN
	getSpriteId := sprite_offset + current_frame DIV total_duration;
END;

END.
