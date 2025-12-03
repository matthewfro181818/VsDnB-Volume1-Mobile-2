package flixel.graphics.frames;

import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;

/**
 * Restores Psych Engine–required APIs:
 *  - addAtlas()
 *  - getFrameKeysStartingWith()
 */
class FlxFramesCollection
{
	public var parent:FlxGraphic;
	public var frames:Array<FlxFrame> = [];

	public function new(parent:FlxGraphic)
	{
		this.parent = parent;
	}

	public function addFrame(rect:Rectangle):FlxFrame
	{
		var f = new FlxFrame(this, rect, frames.length);
		frames.push(f);
		return f;
	}

	/**
	 * Psych-compatible stub (used by Character.addCharAtlas)
	 */
	public function addAtlas(other:FlxFramesCollection)
	{
		for (f in other.frames)
		{
			var rect = new Rectangle(f.frame.x, f.frame.y, f.frame.width, f.frame.height);
			this.addFrame(rect);
		}
	}

	public function getFrameKeysStartingWith(prefix:String):Array<FlxFrame>
	{
		var out:Array<FlxFrame> = [];

		for (f in frames)
		{
			if (f.name != null && f.name.startsWith(prefix))
				out.push(f);
		}

		return out;
	}
}
