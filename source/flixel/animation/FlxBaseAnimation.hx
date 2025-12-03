package flixel.animation;

import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * Modernized base animation used by FlxAnimation.
 * Compatible with Flixel 5.3.1 and OpenFL 9.
 */
class FlxBaseAnimation implements IFlxDestroyable
{
	public var name:String;
	public var curFrame:Int = 0;
	public var numFrames(get, never):Int;
	public var finished:Bool = false;
	public var paused:Bool = false;
	public var looped:Bool = true;
	public var reversed:Bool = false;

	public var frameRate:Float = 0;
	public var delay:Float = 0;
	public var timer:Float = 0;

	public var parent:FlxAnimationController;

	public function new(parent:FlxAnimationController, name:String)
	{
		this.parent = parent;
		this.name = name;
	}

	public function destroy():Void {}

	// ------------------------------
	// FRAME AND PLAYBACK HELPERS
	// ------------------------------

	public function play(force:Bool, reversed:Bool, frame:Int):Void
	{
		finished = false;
		paused = false;
		this.reversed = reversed;

		if (frame >= 0)
			curFrame = frame;
		else
			curFrame = 0;

		timer = 0;
	}

	public function stop():Void
	{
		paused = true;
	}

	public function reset():Void
	{
		finished = false;
		paused = false;
		curFrame = 0;
		timer = 0;
	}

	public function update(elapsed:Float):Void {}

	public function finish():Void
	{
		finished = true;
		paused = true;
	}

	public function pause():Void
	{
		paused = true;
	}

	public function resume():Void
	{
		paused = false;
	}

	public function reverse():Void
	{
		reversed = !reversed;
	}

	public function clone(parent:FlxAnimationController):FlxBaseAnimation
	{
		var a = new FlxBaseAnimation(parent, name);
		a.curFrame = curFrame;
		a.frameRate = frameRate;
		a.looped = looped;
		a.reversed = reversed;
		return a;
	}

	inline function get_numFrames():Int
		return 0;
}
