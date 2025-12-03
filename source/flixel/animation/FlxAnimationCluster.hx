package flixel.animation;

import flixel.util.FlxDestroyUtil;

/**
 * Groups multiple animations that affect different frame layers.
 * Used by tilemaps or spine-like multi-part frame sets.
 */
class FlxAnimationCluster implements IFlxDestroyable
{
	public var name:String;
	public var animations:Array<FlxAnimation>;

	public function new(name:String)
	{
		this.name = name;
		animations = [];
	}

	public function add(anim:FlxAnimation):Void
	{
		animations.push(anim);
	}

	public function play(force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		for (a in animations)
			a.play(force, reversed, frame);
	}

	public function stop():Void
	{
		for (a in animations)
			a.stop();
	}

	public function pause():Void
	{
		for (a in animations)
			a.pause();
	}

	public function resume():Void
	{
		for (a in animations)
			a.resume();
	}

	public function destroy():Void
	{
		for (a in animations)
			a.destroy();
		animations = null;
	}
}
