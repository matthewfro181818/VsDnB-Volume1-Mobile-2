package data;

import flixel.util.FlxAxes;

/**
 * Custom parsers used by json2object.
 * Functions must be (T) -> T.
 */
class DataParser
{
	/**
	 * Parses an axis value from JSON.
	 * Supports:
	 *   "x", "y", "xy", "both", "none"
	 *   null → FlxAxes.NONE
	 *   numbers → converted to string
	 */
	public static function axisValue(value:Dynamic):FlxAxes
	{
		if (value == null)
			return FlxAxes.NONE;

		var str = Std.string(value).toLowerCase().trim();

		switch (str)
		{
			case "x":
				return FlxAxes.X;
			case "y":
				return FlxAxes.Y;
			case "xy", "yx", "both":
				return FlxAxes.XY;
			case "none", "null", "":
				return FlxAxes.NONE;
			default:
				// Fallback for unknown values
				return FlxAxes.fromString(str);
		}
	}
}
