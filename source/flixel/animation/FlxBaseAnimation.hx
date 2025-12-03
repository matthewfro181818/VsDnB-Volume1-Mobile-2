package flixel.animation;

class FlxBaseAnimation
{
	public var name:String;
	public var frames:Array<Int>;
	public var frameRate:Float;
	public var looped:Bool;
	public var flipX:Bool;
	public var flipY:Bool;

	public var finished:Bool = false;
	public var paused:Bool = false;
	public var curFrame:Int = 0;

	public var controller:FlxAnimationController;
	var timer:Float = 0;

	public function new(controller:FlxAnimationController, name:String, frames:Array<Int>, frameRate:Float, looped:Bool, flipX:Bool, flipY:Bool)
	{
		this.controller = controller;
		this.name = name;
		this.frames = frames.copy();
		this.frameRate = frameRate;
		this.looped = looped;
		this.flipX = flipX;
		this.flipY = flipY;
	}

	public function play(force:Bool=false, reversed:Bool=false, startFrame:Int=0)
	{
		finished = false;
		paused = false;

		if (force)
		{
			curFrame = startFrame;
			timer = 0;
		}
		else if (startFrame >= 0)
		{
			curFrame = startFrame;
		}

		applyFrame();
	}

	public function update(dt:Float)
	{
		if (paused || finished || frameRate <= 0 || frames.length <= 1)
			return;

		timer += dt;
		var duration:Float = 1 / frameRate;

		while (timer >= duration)
		{
			timer -= duration;
			advanceFrame();
		}
	}

	function advanceFrame()
	{
		curFrame++;

		if (curFrame >= frames.length)
		{
			if (looped)
			{
				curFrame = 0;
				controller.fireLoopCallback(name);
			}
			else
			{
				curFrame = frames.length - 1;
				finished = true;
				controller.fireFinishCallback(name);
			}
		}

		applyFrame();
	}

	function applyFrame() {}

	public function stop() paused = true;

	public function reset()
	{
		curFrame = 0;
		finished = false;
		paused = false;
		timer = 0;
		applyFrame();
	}

	public function finish()
	{
		curFrame = frames.length - 1;
		finished = true;
		applyFrame();
	}

	public function pause() paused = true;

	public function resume() paused = false;

	public function reverse()
	{
		frames.reverse();
		curFrame = frames.length - 1 - curFrame;
	}
}
