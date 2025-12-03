package util.tools;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;

import openfl.Assets;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.display.BitmapData;
import openfl.system.System;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * Modern, safe, Flixel-only asset preloader.
 * Works on Flixel 5.3.1 / OpenFL 9 / Haxe 4.3+
 */
class Preloader
{
	/** never purge these directories / files */
	public static final noClear:Array<String> = [
		"assets/images/",
		"assets/music/",
		"assets/shared/images/ui/",
	];

	/** tracked, in-memory graphics */
	public static var trackedGraphics:Map<String, FlxGraphic> = [];
	public static var trackedSounds:Map<String, Sound> = [];

	/** previously cached assets, used between states */
	public static var previousGraphics:Map<String, FlxGraphic> = [];
	public static var previousSounds:Map<String, Sound> = [];

	/** states that force a full purge */
	public static var clearOnExit:Array<Class<FlxState>> = [];

	/**
	 * Must be called once (e.g. MainMenuState.create())
	 */
	public static function init():Void
	{
		FlxG.signals.preStateSwitch.add(onPreStateSwitch);
	}

	// -------------------------------------------------------------------------
	// STATE SWITCH HANDLING
	// -------------------------------------------------------------------------

	private static function onPreStateSwitch():Void
	{
		// if state is in clearOnExit → hard purge
		if (clearOnExit.contains(Type.getClass(FlxG.state)))
		{
			fullPurge();
			return;
		}

		// otherwise, soft move/purge
		moveCacheToPrevious();
		softPurge();
	}

	// -------------------------------------------------------------------------
	// CACHE STORE
	// -------------------------------------------------------------------------

	/** Preload a bitmap or image file */
	public static function cacheImage(path:String):FlxGraphic
	{
		if (trackedGraphics.exists(path))
			return trackedGraphics[path];

		if (!Assets.exists(path, IMAGE))
			return null;

		final bmp:BitmapData = Assets.getBitmapData(path);
		final graphic = FlxGraphic.fromBitmapData(bmp, false, path);

		graphic.persist = true;
		trackedGraphics[path] = graphic;

		return graphic;
	}

	/** Preload a sound or music file */
	public static function cacheSound(path:String):Sound
	{
		if (trackedSounds.exists(path))
			return trackedSounds[path];

		if (!Assets.exists(path, SOUND) && !Assets.exists(path, MUSIC))
			return null;

		final snd = Assets.getSound(path);
		trackedSounds[path] = snd;

		return snd;
	}

	/**
	 * Move current tracked assets → previous
	 */
	public static function moveCacheToPrevious():Void
	{
		previousGraphics = trackedGraphics;
		previousSounds   = trackedSounds;

		trackedGraphics = [];
		trackedSounds   = [];
	}

	// -------------------------------------------------------------------------
	// PURGING LOGIC
	// -------------------------------------------------------------------------

	/** minimal purge — clears tracked lists, but respects previousCache */
	private static function softPurge():Void
	{
		for (key => g in trackedGraphics)
		{
			if (!shouldKeep(key))
			{
				Assets.cache.removeBitmapData(key);
				g.destroy();
			}
		}

		for (key => s in trackedSounds)
		{
			if (!shouldKeep(key))
			{
				Assets.cache.removeSound(key);
			}
		}

		trackedGraphics = [];
		trackedSounds = [];

		runGc();
	}

	/** full purge — clears everything including previous cache */
	public static function fullPurge():Void
	{
		// remove graphics
		for (key => g in trackedGraphics)
		{
			Assets.cache.removeBitmapData(key);
			g.destroy();
		}

		for (key => g in previousGraphics)
		{
			Assets.cache.removeBitmapData(key);
			g.destroy();
		}

		// remove sounds
		for (key => s in trackedSounds)
			Assets.cache.removeSound(key);

		for (key => s in previousSounds)
			Assets.cache.removeSound(key);

		trackedGraphics = [];
		trackedSounds   = [];

		previousGraphics = [];
		previousSounds   = [];

		runGc();
	}

	// -------------------------------------------------------------------------
	// HELPERS
	// -------------------------------------------------------------------------

	/** Determines if key is allowed to be purged */
	private static function shouldKeep(key:String):Bool
	{
		for (path in noClear)
		{
			if (key.startsWith(path))
				return true;
		}
		return false;
	}

	/** Cross-platform GC */
	public static function runGc():Void
	{
		#if cpp
		cpp.vm.Gc.run(true);
		cpp.vm.Gc.compact();
		cpp.vm.Gc.run(false);
		#end

		System.gc();
	}
}
