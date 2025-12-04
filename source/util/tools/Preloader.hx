package util.tools;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxAssets.FlxSoundAsset;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.system.System;

import play.notes.NoteStyle;
import play.PlayState;
import play.character.Character;

import ui.menu.ost.OSTMenuState;
import ui.select.charSelect.CharacterSelect;
import ui.select.playerSelect.PlayerSelect;

#if cpp
import cpp.vm.Gc;
#end

#if sys
import sys.FileSystem;
import Paths;
#end

/**
 * Utility for providing and managing asset cache.
 */
class Preloader
{
	// ------------------------------------------------------------
	// STATIC VARIABLES
	// ------------------------------------------------------------

	public static final noClear:Array<String> = [
		"assets/images/backgrounds",
		"assets/images/alphabet.png",
		"shared:assets/shared/images/checkeredBG.png",

		"shared:assets/shared/images/ui/notes",
		"shared:assets/shared/images/ui/combo",
		"shared:assets/shared/images/ui/countdown/normal",

		"shared:assets/shared/images/ui/accuracy.png",
		"shared:assets/shared/images/ui/misses.png",
		"shared:assets/shared/images/ui/score.png",
		"shared:assets/shared/images/ui/timer.png",
		"shared:assets/shared/images/ui/timer-3d.png",

		"assets/music/freakyMenu.ogg"
	];

	public static var previousTrackedGraphics:Map<String, FlxGraphic> = [];
	public static var previousTrackedSounds:Map<String, Sound> = [];

	public static var trackedCharacters:Map<String, Character> = [];
	public static var trackedGraphics:Map<String, FlxGraphic> = [];
	public static var trackedSounds:Map<String, Sound> = [];

	public static var clearOnExit:Array<Class<FlxState>> = [
		CharacterSelect,
		PlayerSelect,
		PlayState,
		OSTMenuState
	];

	// ------------------------------------------------------------
	// INITIALIZATION
	// ------------------------------------------------------------

	public static function initalize():Void
	{
		FlxG.signals.preStateSwitch.add(() -> {
			var currentClass = Type.getClass(FlxG.state);

			if (clearOnExit.contains(currentClass))
			{
				clearTrackedCache();
				runGc();

				previousTrackedGraphics = [];
				previousTrackedSounds = [];

				trackedGraphics = [];
				trackedSounds = [];
			}
			else
			{
				moveCacheToPrevious();
				clearTrackedCache();
				runGc();
			}
		});
	}

	// ------------------------------------------------------------
	// DIRECTORY CHECKING
	// ------------------------------------------------------------

	#if sys
	static function readDirectory(keyToCheck:String, absolutePath:String, library:String):Bool
	{
		var files = FileSystem.readDirectory(absolutePath);

		for (file in files)
		{
			var fullPath = absolutePath + '/' + file;
			var fullLib = library + ":" + fullPath;

			if (FileSystem.isDirectory(fullPath))
			{
				if (!readDirectory(keyToCheck, fullPath, library))
					return false;
			}
			else
			{
				if (fullLib == keyToCheck)
					return false;
			}
		}
		return true;
	}

	static function canKeyBeRemoved(key:String):Bool
	{
		var keyLibrary = Paths.stripLibrary(key);

		var noClearFiltered = noClear.filter(p ->
			p.startsWith(keyLibrary)
		);

		for (assetPath in noClearFiltered)
		{
			var library = Paths.stripLibrary(assetPath);
			var path = Paths.absolutePath(assetPath);

			if (FileSystem.isDirectory(path))
			{
				if (!readDirectory(key, path, library))
					return false;
			}
			else
			{
				if (assetPath == key)
					return false;
			}
		}
		return true;
	}
	#else
	static function canKeyBeRemoved(key:String):Bool return true;
	#end

	// ------------------------------------------------------------
	// CACHE TRANSFER
	// ------------------------------------------------------------

	public static function moveCacheToPrevious():Void
	{
		previousTrackedGraphics = trackedGraphics;
		previousTrackedSounds    = trackedSounds;

		trackedGraphics = [];
		trackedSounds  = [];
	}

	// ------------------------------------------------------------
	// IMAGE CACHING
	// ------------------------------------------------------------

	public static function cacheImage(key:FlxGraphicAsset):FlxGraphic
	{
		var g:FlxGraphic = null;

		if (key is FlxGraphic)
		{
			g = cast key;
			trackedGraphics.set(g.assetsKey, g);
		}
		else
		{
			if (Assets.exists(key, AssetType.IMAGE) && !trackedGraphics.exists(key))
			{
				var bmp = Assets.getBitmapData(key);
				g = FlxGraphic.fromBitmapData(bmp, false, key);
				trackedGraphics.set(key, g);
			}
		}

		if (g != null)
		{
			g.persist = true;
			g.destroyOnNoUse = false;
		}

		return g;
	}

	// ------------------------------------------------------------
	// SOUND CACHING
	// ------------------------------------------------------------

	public static function cacheSound(key:FlxSoundAsset):Sound
	{
		if (!trackedSounds.exists(key) &&
			(Assets.exists(key, AssetType.SOUND) || Assets.exists(key, AssetType.MUSIC)))
		{
			var s = Assets.getSound(key);
			trackedSounds.set(key, s);
			return s;
		}
		return trackedSounds.get(key);
	}

	// ------------------------------------------------------------
	// CHARACTER CACHING
	// ------------------------------------------------------------

	public static function cacheCharacter(charKey:String, type:CharacterType)
	{
		if (trackedCharacters.exists(charKey))
			return;

		var c = Character.create(0, 0, charKey, type);
		trackedCharacters.set(charKey, c);
	}

	// ------------------------------------------------------------
	// SHADER CACHE INIT
	// ------------------------------------------------------------

	public static function cacheShader(shader:FlxShader)
	{
		@:privateAccess shader.__initGL();
	}

	// ------------------------------------------------------------
	// NOTE STYLE CACHE
	// ------------------------------------------------------------

	public static function cacheNoteStyle(style:NoteStyle)
	{
		cacheImage(style.path);
		cacheImage(style.strumlinePath);
		cacheImage(style.sustainPath);
	}

	// ------------------------------------------------------------
	// PREVIOUS CACHE RETRIEVAL
	// ------------------------------------------------------------

	public static function fetchFromPreviousCache(key:String, type:AssetType):Any
	{
		switch (type)
		{
			case AssetType.IMAGE:
				var g = previousTrackedGraphics.get(key);
				if (g != null)
				{
					previousTrackedGraphics.remove(key);
					trackedGraphics.set(key, g);
					return g;
				}

			case AssetType.SOUND, AssetType.MUSIC:
				var s = previousTrackedSounds.get(key);
				if (s != null)
				{
					previousTrackedSounds.remove(key);
					trackedSounds.set(key, s);
					return s;
				}

			default:
		}
		return null;
	}

	// ------------------------------------------------------------
	// REMOVE GRAPHIC
	// ------------------------------------------------------------

	public static function removeCachedGraphic(key:String):Void
	{
		var g = trackedGraphics.get(key);

		if (g != null && canKeyBeRemoved(key))
		{
			Assets.cache.removeBitmapData(key);
			FlxG.bitmap.remove(g);

			g.persist = false;
			g.destroyOnNoUse = true;

			trackedGraphics.remove(key);
		}
	}

	// ------------------------------------------------------------
	// REMOVE SOUND
	// ------------------------------------------------------------

	public static function removeCachedSound(key:String):Void
	{
		if (trackedSounds.exists(key) && canKeyBeRemoved(key))
		{
			var s = trackedSounds.get(key);
			if (s != null)
			{
				s.close();

				Assets.cache.removeSound(key);
				Assets.cache.clear(key);
			}

			trackedSounds.remove(key);
		}
	}

	// ------------------------------------------------------------
	// REMOVE CHARACTER
	// ------------------------------------------------------------

	public static function removeCachedCharacter(charKey:String):Void
	{
		var c = trackedCharacters.get(charKey);

		if (c != null)
		{
			c.destroy();
			trackedCharacters.remove(charKey);
		}
	}

	// ------------------------------------------------------------
	// CLEAR ALL CACHE
	// ------------------------------------------------------------

	public static function clearTrackedCache():Void
	{
		// GRAPHICS
		for (k in trackedGraphics.keys())
			removeCachedGraphic(k);

		FlxG.bitmap.clearCache();
		FlxG.bitmap.clearUnused();

		trackedGraphics = [];

		// SOUNDS
		var soundsPlaying:Array<Sound> = [];

		@:privateAccess
		for (snd in FlxG.sound.list.members.concat([SoundController.music]))
		{
			if (snd != null && snd.persist && snd.playing)
				soundsPlaying.push(snd._sound);
		}

		for (k in trackedSounds.keys())
		{
			var s = trackedSounds.get(k);
			if (!soundsPlaying.contains(s))
				removeCachedSound(k);
		}

		trackedSounds = [];

		// CHARACTERS
		for (k in trackedCharacters.keys())
			removeCachedCharacter(k);

		runGc();
	}

	// ------------------------------------------------------------
	// GC
	// ------------------------------------------------------------

	public static function runGc():Void
	{
		#if cpp
		Gc.run(true);
		Gc.compact();
		Gc.run(false);
		#end

		System.gc();
	}
}
