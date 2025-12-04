package graphics;

import haxe.Json;
import haxe.io.Bytes;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxRect;
import openfl.Assets;
import openfl.display.BitmapData;

/**
 * 100% flxanimate-free atlas loader
 * Supports: spritemap1.json, spritemap2.json, etc.
 *
 * Returns regular FlxAtlasFrames (Psych-compatible)
 */
class AtlasFrames {
	/**
	 * Loads all spritemap{i}.json + its PNG into a combined FlxAtlasFrames.
	 */
	public static function textureAtlas(path:String):FlxAtlasFrames {
		var masterFrames:FlxAtlasFrames = null;
		var i:Int = 1;

		while (Assets.exists('$path/spritemap$i.json')) {
			var jsonText = Assets.getText('$path/spritemap$i.json');
			if (jsonText == null)
				
break;

			var parsed:Dynamic = Json.parse(jsonText);
			var imageName:String = parsed.meta.image;

			var bmp:BitmapData = Assets.getBitmapData('$path/$imageName');
			if (bmp == null) {
				FlxG.log.error('Missing PNG: $path/$imageName');
				i++;
				continue;
			}

			var graphic = FlxGraphic.fromBitmapData(bmp);
			var frames = FlxAtlasFrames.findFrame(graphic);

			if (masterFrames == null)
				
masterFrames = frames;
			else
				masterFrames.frames = masterFrames.frames.concat(frames.frames);

			i++;
		}

		if (masterFrames == null) {
			FlxG.log.error('[AtlasFrames] No spritemaps found in: $path');
			return null;
		}

		return masterFrames;
	}

	public static function getFrame(frames:FlxAtlasFrames, name:String):FlxFrame {
		for (f in frames.frames)
			if (f.name == name)
				
return f;
		return null;
	}
}
