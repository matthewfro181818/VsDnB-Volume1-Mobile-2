package util;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.util.FlxSort;
import data.song.SongData.SongTimeChange;

class SortUtil
{
	/**
	 * Sorts a list of time changes by ASCENDING.
	 */
	public static function sortTimeChanges(a:SongTimeChange, b:SongTimeChange):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
	}

	/**
	 * Sorts FlxBasics by zIndex — currently always equal.
	 */
	public static function byZIndex(a:FlxBasic, b:FlxBasic):Int
	{
		return 0;
	}

	/**
	 * Generic alphabetical sorter but prioritizes a default value.
	 */
	public static function defaultThenAlphabetically(defaultValue:String, a:String, b:String):Int
	{
		if (a == defaultValue && b != defaultValue)
			return -1;

		if (b == defaultValue && a != defaultValue)
			return 1;

		return Reflect.compare(a, b);
	}

	/**
	 * Sort by priority for modules or OST.
	 */
	public static function sortByPriority(a:Dynamic, b:Dynamic):Int
	{
		return Reflect.compare(a.priority, b.priority);
	}

	/**
	 * Replacement for zIndex sorting — sort by y-position.
	 */
	public static function byY(a:FlxSprite, b:FlxSprite):Int
	{
		return Std.int(a.y - b.y);
	}

	/**
	 * Sort predicate for sorting strings alphabetically.
	 */
	public static function alphabetically(a:String, b:String):Int
	{
		a = a.toUpperCase();
		b = b.toUpperCase();

		if (a == b) return 0;
		return a > b ? 1 : -1;
	}

	/**
	 * Sorts strings alphabetically but prioritizes some values first.
	 * Example: array.sort(defaultsThenAlphabetically.bind(["test"]));
	 */
	public static function defaultsThenAlphabetically(defaultValues:Array<String>, a:String, b:String):Int
	{
		if (a == b)
			return 0;

		var aDefault = defaultValues.contains(a);
		var bDefault = defaultValues.contains(b);

		// Both are defaults → sort by their order in defaultValues
		if (aDefault && bDefault)
			return defaultValues.indexOf(a) - defaultValues.indexOf(b);

		// Only A is default → A first
		if (aDefault)
			return -1;

		// Only B is default → B first
		if (bDefault)
			return 1;

		// Otherwise alphabetical
		return alphabetically(a, b);
	}
}
