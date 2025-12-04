package data;

import flixel.util.FlxAxes;

/**
 * Custom writer for json2object.
 * Converts FlxAxes to JSON-safe strings.
 */
class DataWrite
{
	/**
	 * Converts an FlxAxes value into a string for JSON.
	 */
	public static function axisValue(value:Null<FlxAxes>):String
	{
		if (value == null)
			return "none";

		return switch (value)
		{
			case FlxAxes.X: "x";
			case FlxAxes.Y: "y";
			case FlxAxes.XY: "xy";
			default: "none";
		}
	}
}
