package flixel.animation;

import flixel.FlxG;

class FlxAnimation extends FlxBaseAnimation
{
	public var numFrames(get, never):Int;

	public var frameDuration:Float = 0;
	public var loopPoint:Int = 0;
	public var reversed:Bool = false;
	public var timeScale:Float = 1.0;

	var _frameTimer:Float = 0;

	public function new(controller:FlxAnimationController, name:String, frames:Array<Int>, frameRate:Float, looped:Bool, flipX:Bool, flipY:Bool)
	{
		super(controller, name, frames, frameRate, looped, flipX, flipY);
		set_frameRate(frameRate);
	}

	override public function play(Force:Bool=false, Reversed:Bool=false, Frame:Int=0)
	{
		reversed = Reversed;
		paused = false;
		finished = frameDuration == 0;
		_frameTimer = 0;

		var max:Int = numFrames - 1;

		if (Frame < 0)
			curFrame = FlxG.random.int(0, max);
		else
		{
			if (Frame > max) Frame = max;
			if (reversed) Frame = max - Frame;
			curFrame = Frame;
		}

		applyFrame();
	}

	override public function stop()
	{
		paused = true;
		finished = true;
	}

	override public function reset()
	{
		stop();
		curFrame = reversed ? (numFrames - 1) : 0;
	}

	override public function finish()
	{
		stop();
		curFrame = reversed ? 0 : (numFrames - 1);
	}

	override public function pause() paused = true;
	override public function resume() paused = false;

	override public function reverse()
	{
		reversed = !reversed;
	}

	override public function update(elapsed:Float)
	{
		if (finished || paused || frameDuration == 0)
			return;

		_frameTimer += elapsed * timeScale;

		while (_frameTimer >= frameDuration)
		{
			_frameTimer -= frameDuration;
			curFrame += reversed ? -1 : 1;

			if (curFrame >= numFrames)
			{
				if (looped) curFrame = loopPoint;
				else { finished = true; controller.fireFinishCallback(name); }
			}
			else if (curFrame < 0)
			{
				if (looped) curFrame = numFrames - 1;
				else { finished = true; controller.fireFinishCallback(name); }
			}
		}
	}

	public function set_frameRate(v:Float):Float
	{
		frameRate = v;
		frameDuration = (v <= 0 ? 0 : 1 / v);
		return v;
	}

	inline function get_numFrames():Int return frames.length;
}
