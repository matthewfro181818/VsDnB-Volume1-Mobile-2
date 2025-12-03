package flixel.animation;

import flixel.FlxG;
import flixel.util.FlxSignal;
import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import flixel.animation.FlxAnimationCluster;
import flixel.util.FlxDestroyUtil;

/**
 * Controls all animations attached to a FlxSprite.
 */
class FlxAnimationController implements IFlxDestroyable
{
	public var name(get, set):String;
	public var paused(get, set):Bool;
	public var finished(get, set):Bool;
	public var curAnim(default, null):FlxAnimation;
	public var frameIndex(default, set):Int = -1;
	public var numFrames(get, never):Int;

	public final onFrameChange = new FlxTypedSignal<(anim:String, frame:Int, index:Int)->Void>();
	public final onFinish      = new FlxTypedSignal<(anim:String)->Void>();
	public final onLoop        = new FlxTypedSignal<(anim:String)->Void>();

	var _sprite:FlxSprite;
	var _animations:Map<String, FlxAnimation> = [];
	var _clusters:Map<String, FlxAnimationCluster> = [];
	var _prerotated:FlxPrerotatedAnimation;
	public var timeScale:Float = 1.0;

	public function new(sprite:FlxSprite)
	{
		_sprite = sprite;
	}

	public function update(elapsed:Float):Void
	{
		if (curAnim != null)
			curAnim.update(elapsed * (timeScale * FlxG.animationTimeScale));
		else if (_prerotated != null)
			_prerotated.angle = _sprite.angle;
	}

	public function add(name:String, frames:Array<Int>, frameRate:Float = 30,
			looped:Bool = true, flipX:Bool = false, flipY:Bool = false)
	{
		if (numFrames == 0)
		{
			FlxG.log.warn('Could not create animation "$name": sprite has no frames');
			return;
		}

		var clean:Array<Int> = [];
		for (f in frames)
		{
			if (f >= 0 && f < numFrames)
				clean.push(f);
		}

		if (clean.length == 0)
		{
			FlxG.log.warn('Animation "$name" has no valid frames.');
			return;
		}

		var anim = new FlxAnimation(this, name, clean, frameRate, looped, flipX, flipY);
		_animations.set(name, anim);
	}

	public function remove(name:String):Void
	{
		var anim = _animations.get(name);
		if (anim != null)
		{
			anim.destroy();
			_animations.remove(name);
		}
	}

	public function play(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		if (name == null)
		{
			if (curAnim != null)
				curAnim.stop();
			curAnim = null;
			return;
		}

		var anim = _animations.get(name);
		if (anim == null)
		{
			FlxG.log.warn('No animation named "$name"');
			return;
		}

		if (curAnim != null && curAnim != anim)
			curAnim.stop();

		curAnim = anim;
		curAnim.play(force, reversed, frame);
	}

	public function reset():Void
	{
		if (curAnim != null)
			curAnim.reset();
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

	public function reverse():Void
	{
		if (curAnim != null)
			curAnim.reverse();
	}

	public function exists(name:String):Bool
		return _animations.exists(name);

	public function getByName(name:String):FlxAnimation
		return _animations.get(name);

	public function getNameList():Array<String>
	{
		var arr:Array<String> = [];
		for (n in _animations.keys())
			arr.push(n);
		return arr;
	}

	function get_name():String
		return curAnim != null ? curAnim.name : null;

	function set_name(v:String):String
	{
		play(v);
		return v;
	}

	function get_paused():Bool
		return curAnim != null ? curAnim.paused : false;

	function set_paused(v:Bool):Bool
	{
		if (curAnim != null)
		{
			if (v) curAnim.pause(); else curAnim.resume();
		}
		return v;
	}

	function get_finished():Bool
		return curAnim != null ? curAnim.finished : true;

	function set_finished(v:Bool):Bool
	{
		if (v && curAnim != null)
			curAnim.finish();
		return v;
	}

	function get_numFrames():Int
		return _sprite.numFrames;

	function set_frameIndex(i:Int):Int
	{
		if (numFrames > 0)
		{
			i = i % numFrames;
			_sprite.frame = _sprite.frames.frames[i];
			frameIndex = i;

			if (curAnim != null)
				onFrameChange.dispatch(curAnim.name, curAnim.curFrame, i);
			else
				onFrameChange.dispatch(null, -1, i);
		}
		return frameIndex;
	}

	@:allow(flixel.animation)
	public function fireFinishCallback(name:String)
		onFinish.dispatch(name);

	@:allow(flixel.animation)
	public function fireLoopCallback(name:String)
		onLoop.dispatch(name);

	public function destroy():Void
	{
		for (a in _animations)
			a.destroy();
		_animations = null;

		if (_prerotated != null)
			_prerotated.destroy();

		FlxDestroyUtil.destroy(onFrameChange);
		FlxDestroyUtil.destroy(onFinish);
		FlxDestroyUtil.destroy(onLoop);

		_sprite = null;
	}
}
