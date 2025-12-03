package flixel.graphics.frames;

import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;
import openfl.geom.Point;

/**
 * Custom frame that restores Psych-Engine compatible fields:
 *  - curFrame
 *  - frames[]
 *  - update()
 *  - UV helpers
 */
class FlxFrame
{
	public var parent:FlxFramesCollection;
	public var frame:Rectangle;
	public var name:String = "";
	public var trimmed:Bool = false;

	// Psych Engine compatibility fields
	public var index:Int = 0;
	public var frames:Array<Int> = [];
	public var curFrame:Int = 0;

	// UV cache
	public var uvX:Float = 0;
	public var uvY:Float = 0;
	public var uvW:Float = 0;
	public var uvH:Float = 0;

	public function new(parent:FlxFramesCollection, frame:Rectangle, idx:Int)
	{
		this.parent = parent;
		this.frame = frame;
		this.index = idx;
		frames = [idx];

		updateUV();
	}

	/**
	 * OpenFL 9 UV calculation
	 */
	public function updateUV()
	{
		var source = parent.parent;

		uvX = frame.x / source.width;
		uvY = frame.y / source.height;
		uvW = frame.width / source.width;
		uvH = frame.height / source.height;
	}

	/**
	 * Psych Engine expects this function to exist.
	 */
	public function update(dt:Float)
	{
		// Does nothing for static frames but must exist.
	}
}
