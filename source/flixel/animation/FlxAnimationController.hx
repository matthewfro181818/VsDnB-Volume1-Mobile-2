package flixel.animation;

import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * Cleaned / fixed version for OpenFL 9, Lime 9, HaxeFlixel 5.7+.
 * Removed all FlxAnimate + Prerotated references.
 */
class FlxAnimationController implements IFlxDestroyable
{
	public var frameIndex(default, set):Int = -1;
	public var frameName(get, set):String;
	public var name(get, set):String;

	public var numFrames(get, never):Int;
	@:deprecated("frames is deprecated, use numFrames")
	public var frames(get, never):Int;

	public var callback:(name:String, frameNumber:Int, frameIndex:Int) -> Void;
	public var finishCallback:(name:String) -> Void;
	public var playCallback:(name:String, forced:Bool, reversed:Bool, frame:Int) -> Void;
	public var loopCallback:(animName:String) -> Void;

	public final onFrameChange = new FlxTypedSignal<(animName:String, frameNumber:Int, frameIndex:Int) -> Void>();
	public final onFinish      = new FlxTypedSignal<(animName:String) -> Void>();
	public final onFinishEnd   = new FlxTypedSignal<(animName:String) -> Void>();
	public final onPlay        = new FlxTypedSignal<(animName:String, forced:Bool, reversed:Bool, frame:Int) -> Void>();
	public final onLoop        = new FlxTypedSignal<(animName:String) -> Void>();

	public var timeScale:Float = 1.0;

	var _sprite:FlxSprite;
	@:allow(flixel.animation)
	var _curAnim:FlxAnimation;

	var _animations:Map<String, FlxAnimation> = new Map();

	public function new(sprite:FlxSprite)
	{
		_sprite = sprite;
	}

	public function update(elapsed:Float):Void
	{
		if (_curAnim != null)
			_curAnim.update(elapsed * (timeScale * FlxG.animationTimeScale));
	}

	public function copyFrom(controller:FlxAnimationController):FlxAnimationController
	{
		clearAnimations();

		for (anim in controller._animations)
			add(anim.name, anim.frames.copy(), anim.frameRate, anim.looped, anim.flipX, anim.flipY);

		if (controller.name != null)
			name = controller.name;

		frameIndex = controller.frameIndex;
		return this;
	}

	public function destroy():Void
	{
		FlxDestroyUtil.destroy(onFrameChange);
		FlxDestroyUtil.destroy(onFinish);
		FlxDestroyUtil.destroy(onFinishEnd);
		FlxDestroyUtil.destroy(onLoop);

		clearAnimations();
		_animations = null;
		callback = null;
		finishCallback = null;
		playCallback = null;
		loopCallback = null;
		_sprite = null;
	}

	inline function clearAnimations():Void
	{
		for (k in _animations.keys())
		{
			final anim = _animations[k];
			if (anim != null) anim.destroy();
		}
		_animations = new Map();
		_curAnim = null;
	}

	//------------------------------------------------------
	// Animation Creation
	//------------------------------------------------------

	public function add(name:String, frames:Array<Int>, frameRate = 30.0, looped = true, flipX = false, flipY = false):Void
	{
		if (numFrames == 0)
		{
			FlxG.log.warn('Could not create animation "$name": no frames');
			return;
		}

		var valid = [];
		var invalid = false;

		for (i in frames)
		{
			if (i < numFrames)
				valid.push(i);
			else
				invalid = true;
		}

		if (valid.length == 0)
		{
			FlxG.log.warn('Could not create animation "$name": no valid frames');
			return;
		}

		_animations.set(name, new FlxAnimation(this, name, valid, frameRate, looped, flipX, flipY));

		if (invalid)
			FlxG.log.warn('Frames above ${numFrames - 1} were excluded from "$name"');
	}

	public function addByNames(Name:String, FrameNames:Array<String>, FrameRate = 30.0, Looped = true, FlipX = false, FlipY = false):Void
	{
		if (_sprite.frames == null) return;

		var out = [];
		for (n in FrameNames)
		{
			if (_sprite.frames.framesHash.exists(n))
				out.push(getFrameIndex(_sprite.frames.framesHash[n]));
		}

		if (out.length > 0)
			_animations.set(Name, new FlxAnimation(this, Name, out, FrameRate, Looped, FlipX, FlipY));
	}

	public function addByPrefix(name:String, prefix:String, frameRate = 30.0, looped = true, flipX = false, flipY = false):Void
	{
		if (_sprite.frames == null) return;

		var arr = [];
		for (frame in _sprite.frames.frames)
			if (frame.name != null && StringTools.startsWith(frame.name, prefix))
				arr.push(frame);

		if (arr.length == 0) return;

		FlxFrame.sort(arr, prefix.length, arr[0].name.split(".")[1].length);

		var ids = [for (f in arr) getFrameIndex(f)];
		_animations.set(name, new FlxAnimation(this, name, ids, frameRate, looped, flipX, flipY));
	}

	//------------------------------------------------------
	// Playback
	//------------------------------------------------------

	public function play(anim:String, force=false, reversed=false, frame:Int = 0):Void
	{
		if (anim == null)
		{
			if (_curAnim != null) _curAnim.stop();
			_curAnim = null;
			return;
		}

		var a = _animations.get(anim);
		if (a == null)
		{
			FlxG.log.warn('No animation called "$anim"');
			return;
		}

		if (_curAnim != null && _curAnim != a)
			_curAnim.stop();

		_curAnim = a;
		_curAnim.play(force, reversed, frame);
	}

	public inline function reset():Void
	{
		if (_curAnim != null) _curAnim.reset();
	}

	public inline function finish():Void
	{
		if (_curAnim != null) _curAnim.finish();
	}

	public inline function stop():Void
	{
		if (_curAnim != null) _curAnim.stop();
	}

	public inline function pause():Void
	{
		if (_curAnim != null) _curAnim.pause();
	}

	public inline function resume():Void
	{
		if (_curAnim != null) _curAnim.resume();
	}

	//------------------------------------------------------
	// Utilities
	//------------------------------------------------------

	public inline function getByName(name:String):FlxAnimation
		return _animations.get(name);

	public function randomFrame():Void
	{
		if (_curAnim != null) _curAnim.stop();
		_curAnim = null;
		frameIndex = FlxG.random.int(0, numFrames - 1);
	}

	//------------------------------------------------------
	// Frame Access
	//------------------------------------------------------

	function set_frameIndex(i:Int):Int
	{
		if (_sprite.frames != null && numFrames > 0)
		{
			i %= numFrames;
			_sprite.frame = _sprite.frames.frames[i];
			frameIndex = i;
			fireCallback();
		}
		return frameIndex;
	}

	inline function get_frameName():String
		return _sprite.frame.name;

	function set_frameName(v:String):String
	{
		if (_sprite.frames != null && _sprite.frames.framesHash.exists(v))
		{
			if (_curAnim != null) _curAnim.stop();
			_curAnim = null;

			frameIndex = getFrameIndex(_sprite.frames.framesHash[v]);
		}
		return v;
	}

	function get_name():String
		return _curAnim == null ? null : _curAnim.name;

	function set_name(n:String):String
	{
		play(n);
		return n;
	}

	public function getNameList():Array<String>
		return [for (k in _animations.keys()) k];

	public function exists(n:String):Bool
		return _animations.exists(n);

	//------------------------------------------------------
	// Signals
	//------------------------------------------------------

	@:haxe.warning("-WDeprecated")
	function fireCallback():Void
	{
		final name = (_curAnim != null) ? _curAnim.name : null;
		final number = (_curAnim != null) ? _curAnim.curFrame : frameIndex;

		if (callback != null)
			callback(name, number, frameIndex);

		onFrameChange.dispatch(name, number, frameIndex);
	}

	@:allow(flixel.animation)
	@:haxe.warning("-WDeprecated")
	function fireFinishCallback(?name:String):Void
	{
		if (finishCallback != null)
			finishCallback(name);

		onFinish.dispatch(name);
	}

	@:allow(flixel.animation)
	function fireLoopCallback(?name:String):Void
	{
		onLoop.dispatch(name);
	}

	//------------------------------------------------------
	// Basic Getters
	//------------------------------------------------------

	inline function get_frames():Int
		return _sprite.numFrames;

	inline function get_numFrames():Int
		return _sprite.numFrames;

	public inline function getFrameIndex(frame:FlxFrame):Int
	{
		return _sprite.frames.frames.indexOf(frame);
	}
}

enum FlxFrameCollectionType
{
    IMAGE;
    TILES;
    ATLAS;
    FONT;
    USER(type:String);
    FILTER;
}
