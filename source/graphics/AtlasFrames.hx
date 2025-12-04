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
 * 100% flxanimate-free atlas loader.
 * Reads spritemap{i}.json and their PNG files,
 * building a combined FlxAtlasFrames usable by Psych Engine.
 */
class AtlasFrames
{
	/**
	 * Loads spritemap1.json, spritemap2.json, ... until missing.
	 * Merges all frames into one FlxAtlasFrames.
	 */
	public static function textureAtlas(path:String):FlxAtlasFrames
	{
		var masterFrames:FlxAtlasFrames = null;
		var i:Int = 1;

		while (Assets.exists(path + "/spritemap" + i + ".json"))
		{
			var jsonText:String = Assets.getText(path + "/spritemap" + i + ".json");
			if (jsonText == null)
				break;

			var parsed:Dynamic = Json.parse(jsonText);
			if (parsed == null || parsed.meta == null || parsed.meta.image == null)
			{
				FlxG.log.error('[AtlasFrames] Invalid json in spritemap$i.json');
				i++;
				continue;
			}

			var imageName:String = parsed.meta.image;
			var bmp:BitmapData = Assets.getBitmapData(path + "/" + imageName);

			if (bmp == null)
			{
				FlxG.log.error('Missing PNG: $path/$imageName');
				i++;
				continue;
			}

			// Convert JSON atlas into FlxAtlasFrames
			var graphic = FlxGraphic.fromBitmapData(bmp);
			var frames = atlasFromJson(graphic, parsed);

			if (frames == null)
			{
				FlxG.log.error('[AtlasFrames] Failed to build frames from spritemap$i.json');
				i++;
				continue;
			}

			if (masterFrames == null)
			{
				masterFrames = frames;
			}
			else
			{
				for (f in frames.frames)
					masterFrames.frames.push(f);
			}

			i++;
		}

		if (masterFrames == null)
		{
			FlxG.log.error('[AtlasFrames] No spritemaps found in: $path');
			return null;
		}

		return masterFrames;
	}

	/**
	 * Convert standard TexturePacker JSON to FlxAtlasFrames.
	 */
	private static function atlasFromJson(graphic:FlxGraphic, json:Dynamic):FlxAtlasFrames
	{
		var out = new FlxAtlasFrames(graphic);

		if (json.frames == null)
			return null;

		for (frameName in Reflect.fields(json.frames))
		{
			var f = Reflect.field(json.frames, frameName);
			if (f == null || f.frame == null)
				continue;

			var rect = new FlxRect(
				f.frame.x,
				f.frame.y,
				f.frame.w,
				f.frame.h
			);

			var flxFrame = out.addAtlasFrame(rect, frameName);

			if (f.spriteSourceSize != null)
			{
				flxFrame.offset.x = -f.spriteSourceSize.x;
				flxFrame.offset.y = -f.spriteSourceSize.y;
			}

			if (f.sourceSize != null)
			{
				flxFrame.sourceSize.x = f.sourceSize.w;
				flxFrame.sourceSize.y = f.sourceSize.h;
			}
		}

		return out;
	}

	/**
	 * Retrieve a frame by name.
	 */
	public static function getFrame(frames:FlxAtlasFrames, name:String):FlxFrame
	{
		for (f in frames.frames)
		{
			if (f.name == name)
				return f;
		}
		return null;
	}
}
