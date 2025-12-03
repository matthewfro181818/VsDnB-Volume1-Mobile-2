package flixel.graphics.frames;

import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;
import haxe.xml.Fast;

/**
 * Restored Sparrow / Packer atlas loading
 * with Psych Engine compatible behavior.
 */
class FlxAtlasFrames extends FlxFramesCollection
{
	public function new(parent:FlxGraphic)
	{
		super(parent);
	}

	public static function fromSparrow(png:String, xml:String):FlxAtlasFrames
	{
		var gfx = FlxGraphic.fromAssetKey(png);
		var atlas = new FlxAtlasFrames(gfx);

		var xmlData = Xml.parse(openfl.Assets.getText(xml));
		var fast = new Fast(xmlData.firstElement());

		for (sub in fast.nodes.SubTexture)
		{
			var x = Std.parseInt(sub.att.x);
			var y = Std.parseInt(sub.att.y);
			var w = Std.parseInt(sub.att.width);
			var h = Std.parseInt(sub.att.height);

			var rect = new Rectangle(x, y, w, h);

			var f = atlas.addFrame(rect);
			f.name = sub.att.name;
		}

		return atlas;
	}
}
