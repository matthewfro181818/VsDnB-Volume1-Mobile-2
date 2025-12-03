package flixel.animation;

import flixel.FlxG;
import flixel.graphics.frames.FlxFrame;

/**
 * Modernized FlxAnimation compatible with Flixel 5.3.1.
 * No prerotated / FlxAnimate references.
 */
class FlxAnimation extends FlxBaseAnimation
{
	public var frames:Array<Int> = [];
	public var flipX:Bool = false;
	public var flipY:Bool = false;

	// current frame's FlxFrame
	public var frame(default, null):FlxFrame;

	public function new(
		parent:FlxAnimationController,
		name:String,
		frames:Array<Int>,
		frameRate:Float,
		looped:Bool,
		flipX:Bool,
		flipY:Bool
	){
		super(parent, name);
		this.frames = frames.copy();
		this.frameRate = frameRate;
		this.looped = looped;
		this.flipX = flipX;
		this.flipY = flipY;

		if (frameRate > 0)
			delay = 1.0 / frameRate;
		else
			delay = 0;

		if (frames.length > 0 && parent._sprite != null && parent._sprite.frames != null)
		{
			frame = parent._sprite.frames.frames[frames[0]];
		}
	}

	override public function destroy():Void
	{
		frames = null;
		frame = null;
		super.destroy();
	}

	// ------------------------------
	// UPDATE
	// ------------------------------

	override public function update(elapsed:Float):Void
	{
		if (paused || finished || frame == null || frames == null || frames.length == 0)
			return;

		timer += elapsed;

		while (timer >= delay && delay > 0)
		{
			timer -= delay;

			if (!reversed)
				curFrame++;
			else
				curFrame--;

			if (curFrame >= frames.length)
			{
				if (looped)
					curFrame = 0;
				else {
					curFrame = frames.length - 1;
					finish();
					parent.fireFinishCallback(name);
					return;
				}
				parent.fireLoopCallback(name);
			}
			else if (curFrame < 0)
			{
				if (looped)
					curFrame = frames.length - 1;
				else {
					curFrame = 0;
					finish();
					parent.fireFinishCallback(name);
					return;
				}
				parent.fireLoopCallback(name);
			}
		}

		if (parent._sprite != null && parent._sprite.frames != null)
		{
			frame = parent._sprite.frames.frames[frames[curFrame]];
			parent._sprite.set_frameIndex(frames[curFrame]);
			parent.fireCallback();
		}
	}

	// ------------------------------
	// CONTROLS
	// ------------------------------

	override public function reset():Void
	{
		super.reset();
		frame = parent._sprite.frames.frames[frames[0]];
	}

	override public function finish():Void
	{
		super.finish();
	}

	override public function pause():Void
	{
		super.pause();
	}

	override public function resume():Void
	{
		super.resume();
	}

	override public function reverse():Void
	{
		super.reverse();
	}

	override public function clone(parent:FlxAnimationController):FlxAnimation
	{
		return new FlxAnimation(
			parent,
			name,
			frames,
			frameRate,
			looped,
			flipX,
			flipY
		);
	}

	override function get_numFrames():Int
		return frames != null ? frames.length : 0;
}
