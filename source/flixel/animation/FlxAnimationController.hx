package flixel.animation;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;

/**
 * A fully modernized animation controller with complete feature parity
 * to legacy Psych Engine animation API.
 *
 * Works on Flixel 5.3.1, OpenFL 9, Lime 9.
 */
class FlxAnimationController
{
	public var _sprite:FlxSprite;

	/** Current animation */
	public var curAnim(default, null):FlxAnimation;

	/** Stored animations */
	public var animations:Map<String, FlxAnimation> = new Map();

	/** Callbacks */
	public var onFinish:FlxAnimationCallback = new FlxAnimationCallback();
	public var onLoop:FlxAnimationCallback = new FlxAnimationCallback();
	public var onFrame:FlxAnimationCallback = new FlxAnimationCallback();

	/** Playback */
	public var paused:Bool = false;
	public var timeScale:Float = 1.0;

	public function new(sprite:FlxSprite)
	{
		_sprite = sprite;
	}

	// --------------------------------------------------------------
	// Internal callback helpers (called by FlxAnimation)
	// --------------------------------------------------------------

	public function fireCallback()
	{
		if (curAnim != null)
			onFrame.dispatch(curAnim.name);
	}

	public function fireFinishCallback(name:String)
	{
		onFinish.dispatch(name);
	}

	public function fireLoopCallback(name:String)
	{
		onLoop.dispatch(name);
	}

	// --------------------------------------------------------------
	// BASIC ANIMATION CONTROLS
	// --------------------------------------------------------------

	public function add(anim:FlxAnimation):Void
	{
		animations.set(anim.name, anim);
	}

	public function remove(name:String):Void
	{
		if (animations.exists(name))
			animations.remove(name);
	}

	public function getByName(name:String):FlxAnimation
	{
		return animations.get(name);
	}

	public function getAnimationList():Array<String>
	{
		var out:Array<String> = [];
		for (key in animations.keys())
			out.push(key);
		return out;
	}

	public function play(name:String, force:Bool=false, reversed:Bool=false, frame:Int=0)
	{
		var anim = animations.get(name);
		if (anim == null)
			return;

		if (curAnim != anim || force)
		{
			curAnim = anim;
			curAnim.play(force, reversed, frame);
			_sprite.set_frameIndex(curAnim.frames[curAnim.curFrame]);
		}
	}

	public function stop():Void
	{
		if (curAnim != null)
			curAnim.stop();
	}

	public function pause():Void
	{
		if (curAnim != null)
			curAnim.pause();
	}

	public function resume():Void
	{
		if (curAnim != null)
			curAnim.resume();
	}

	// --------------------------------------------------------------
	// UPDATE
	// --------------------------------------------------------------

	public function update(elapsed:Float)
	{
		if (paused || curAnim == null)
			return;

		curAnim.update(elapsed * timeScale * FlxSprite.globalAnimationScale);
	}

	// --------------------------------------------------------------
	// ANIMATION BUILDERS (PSYCH ENGINE COMPATIBLE)
	// --------------------------------------------------------------

	/**
	 * Add animation using prefix matching.
	 * (Equivalent to Psych's addByPrefix)
	 */
	public function addByPrefix(
		name:String,
		prefix:String,
		frameRate:Float = 24,
		loop:Bool = false,
		flipX:Bool = false,
		flipY:Bool = false
	){
		var frames = _sprite.frames.getFrameKeysStartingWith(prefix);

		var ids:Array<Int> = [];
		for (frame in frames)
			ids.push(frame.index);

		var anim = new FlxAnimation(
			this,
			name,
			ids,
			frameRate,
			loop,
			flipX,
			flipY
		);

		animations.set(name, anim);
	}

	/**
	 * Add animation using a frame index array.
	 */
	public function addByIndices(
		name:String,
		prefix:String,
		indices:Array<Int>,
		frameRate:Float = 24,
		loop:Bool = false,
		flipX:Bool = false,
		flipY:Bool = false
	){
		// Pull all frames that match prefix
		var frames = _sprite.frames.getFrameKeysStartingWith(prefix);

		var selected:Array<Int> = [];
		for (idx in indices)
		{
			if (idx >= 0 && idx < frames.length)
				selected.push(frames[idx].index);
		}

		var anim = new FlxAnimation(
			this,
			name,
			selected,
			frameRate,
			loop,
			flipX,
			flipY
		);

		animations.set(name, anim);
	}

	/**
	 * Append additional frames that match a prefix.
	 */
	public function appendByPrefix(name:String, prefix:String)
	{
		var anim = animations.get(name);
		if (anim == null)
			return;

		var frames = _sprite.frames.getFrameKeysStartingWith(prefix);

		for (frame in frames)
			anim.frames.push(frame.index);
	}

	// --------------------------------------------------------------
	// CLEANUP
	// --------------------------------------------------------------

	public function destroyAnimations():Void
	{
		for (anim in animations)
			anim.destroy();
		animations.clear();
		curAnim = null;
	}

	public function destroy():Void
	{
		destroyAnimations();
		_sprite = null;
	}
}

/**
 * Simple callback wrapper to keep Psych Engine compatibility.
 */
class FlxAnimationCallback
{
	public var callbacks:Array<String->Void> = [];

	public function new() {}

	public function add(fn:String->Void)
	{
		callbacks.push(fn);
	}

	public function addOnce(fn:String->Void)
	{
		callbacks.push(function(name:String){
			fn(name);
			callbacks.remove(fn);
		});
	}

	public function remove(fn:String->Void)
	{
		callbacks.remove(fn);
	}

	public function dispatch(name:String)
	{
		for (fn in callbacks)
			fn(name);
	}
}
