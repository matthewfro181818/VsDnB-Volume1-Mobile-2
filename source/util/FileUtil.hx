package util;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import openfl.utils.Assets;

#if sys
import sys.FileSystem;
#end

#if mobile
import util.SUtil;
#end

/**
 * A utility to help provide functions relating to file exploration
 * and general file manipulation.
 */
class FileUtil
{
	/**
	 * Returns a random background graphic.
	 * 1/5000 chance to return the easter egg "ramzgaming".
	 */
	public static function randomizeBG():FlxGraphic
	{
		if (FlxG.random.bool(1 / 5000))
		{
			return Paths.image("backgrounds/ramzgaming");
		}
		else
		{
			// Directory used by Assets.list()
			var backgroundPath:String = Path.directory(Paths.imagePath("backgrounds"));

			// Remove trailing slash if present
			if (backgroundPath.endsWith("/"))
				backgroundPath = backgroundPath.substr(0, backgroundPath.length - 1);

			var finalPath = backgroundPath;

			// Collect all background names under backgrounds/
			var bgs:Array<String> = Assets.list(Assets.IMAGE)
				.filter(function(p:String)
				{
					// Match backgrounds/[name].png
					return p.startsWith(finalPath + "/");
				})
				.map(function(p:String)
				{
					// strip directory + extension
					return Path.withoutExtension(p.substr(finalPath.length + 1));
				});

			return Paths.image("backgrounds/" + FlxG.random.getObject(bgs));
		}
	}

	/**
	 * Split a text file into lines.
	 */
	public static function splitText(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split("\n");

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}
		return daList;
	}

	/**
	 * Creates a directory at the specified path.
	 * On Android, automatically prepends internal storage directory.
	 */
	public static function createDirectory(path:String):Void
	{
		var fullPath:String;

		#if android
		fullPath = SUtil.getStorageDirectory() + path;
		#else
		fullPath = path;
		#end

		#if sys
		if (!FileSystem.exists(fullPath))
		{
			FileSystem.createDirectory(fullPath);
		}
		#end
	}

	/**
	 * Opens a file using the operating system's default file handler.
	 */
	public static function openFile(path:String):Void
	{
		#if windows
		Sys.command("start " + path);
		#elseif linux
		Sys.command("xdg-open " + path);
		#elseif mac
		Sys.command("open " + path);
		#else
		// fallback
		Sys.command("open " + path);
		#end
	}
}
