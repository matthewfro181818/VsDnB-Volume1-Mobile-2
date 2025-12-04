package util;

import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

class GradientUtil
{
	public static function applyGradientToBitmapData(
		target:BitmapData,
		colors:Array<FlxColor>,
		chunkSize:Int = 1,
		rotation:Int = 90,
		interpolate:Bool = true
	):BitmapData
	{
		if (target == null)
			return null;

		var gradientPixels:BitmapData = FlxGradient.createGradientBitmapData(
			target.width, target.height, colors, chunkSize, rotation, interpolate
		);

		// Clone original to avoid modifying the source sprite's pixels.
		var newPixels:BitmapData = target.clone();

		for (w in 0...target.width)
		{
			for (h in 0...target.height)
			{
				var src:Int = target.getPixel32(w, h);
				var grad:Int = gradientPixels.getPixel32(w, h);

				// Extract ARGB channels manually
				var a = (src >> 24) & 0xFF;
				var r = (src >> 16) & 0xFF;
				var g = (src >> 8)  & 0xFF;
				var b = src & 0xFF;

				var ga = (grad >> 24) & 0xFF;
				var gr = (grad >> 16) & 0xFF;
				var gg = (grad >> 8)  & 0xFF;
				var gb = grad & 0xFF;

				// Multiply-blend per channel (0–255)
				var fr = Std.int((r * gr) / 255);
				var fg = Std.int((g * gg) / 255);
				var fb = Std.int((b * gb) / 255);

				// Keep original alpha
				var finalColor:Int = (a << 24) | (fr << 16) | (fg << 8) | fb;

				newPixels.setPixel32(w, h, finalColor);
			}
		}

		return newPixels;
	}

	public static function applyGradientToSprite(
		target:FlxSprite,
		colors:Array<FlxColor>,
		chunkSize:Int = 1,
		rotation:Int = 90,
		interpolate:Bool = true
	):Void
	{
		if (target == null || target.pixels == null)
			return var gradientBitmapData = applyGradientToBitmapData(
			target.pixels, colors, chunkSize, rotation, interpolate
		);

		target.pixels = gradientBitmapData;
	}
}
