package flixel.animation;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxSignal.FlxTypedSignal;

class FlxAnimationController
{
	public var frameIndex(default, set):Int = 0;
	public var curAnim(get, never):FlxAnimation;
	public var name(get, set):String;

	public var onFrameChange = new FlxTypedSignal<(name:String, frame:Int, index:Int)->Void>();
	public var onFinish      = new FlxTypedSignal<(name:String)->Void>();
	public var onLoop        = new FlxTypedSignal<(name:String)->Void>();

	var _animations:Map<String, FlxAnimation> = new Map();
	var _curAnim:FlxAnimation;
	var _sprite:FlxSprite;

	public function new(sprite:FlxSprite)
	{
		_sprite = sprite;
	}

	public function destroyAnimations()
	{
		for (a in _animations) a.destroy();
		_animations.clear();
		_curAnim = null;
	}

	public function add(name:String, frames:Array<Int>, frameRate:Float=24, looped:Bool=true, flipX=false, flipY=false)
	{
		_animations.set(name, new FlxAnimation(this, name, frames, frameRate, looped, flipX, flipY));
	}

	public function addByPrefix(name:String, prefix:String, frameRate=24, looped=true, flipX=false, flipY=false)
	{
		var ids = [];
		for (f in _sprite.frames.frames)
			if (f.name != null && f.name.startsWith(prefix))
				ids.push(_sprite.frames.frames.indexOf(f));

		if (ids.length > 0)
			add(name, ids, frameRate, looped, flipX, flipY);
	}

	// ⭐ Psych-style support
	public function addByIndices(name:String, prefix:String, indices:Array<Int>, postFix:String, frameRate=24, looped=true, flipX=false, flipY=false)
	{
		var output = [];
		for(i in indices)
			output.push(i);

		add(name, output, frameRate, looped, flipX, flipY);
	}

	public function appendByPrefix(name:String, prefix:String, frameRate=24)
	{
		var a = _animations.get(name);
		if (a == null) return;

		for (f in _sprite.frames.frames)
			if (f.name != null && f.name.startsWith(prefix))
				a.frames.push(_sprite.frames.frames.indexOf(f));
	}

	public function play(name:String, force=false, reversed=false, startFrame=0)
	{
		var a = _animations.get(name);
		if (a == null) return;

		if (_curAnim != a)
			_curAnim = a;

		_curAnim.play(force, reversed, startFrame);
	}

	public inline function getAnimationList():Array<String>
		return [for (n in _animations.keys()) n];

	inline function get_curAnim() return _curAnim;

	inline function get_name():String return _curAnim == null ? null : _curAnim.name;

	function set_name(v:String):String
	{
		play(v);
		return v;
	}

	function set_frameIndex(i:Int):Int
	{
		i %= _sprite.numFrames;
		_sprite.frame = _sprite.frames.frames[i];
		return frameIndex = i;
	}

	public function fireFinishCallback(n:String) onFinish.dispatch(n);
	public function fireLoopCallback(n:String)   onLoop.dispatch(n);
}
