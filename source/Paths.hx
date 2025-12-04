package;

import play.song.Song;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxSoundAsset;
import haxe.io.Path;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import util.tools.Preloader;
import play.save.Preferences;

/**
 * A core class used for accessing asset paths.
 */
class Paths
{
	/** The extension used for sounds. */
	public static inline var SOUND_EXT = "ogg";

	/** Whether the current locale is not English. */
	public static function isLocale():Bool
	{
		return Preferences.language != "en-US";
	}

	/** Path to the language definitions. */
	public static function langaugeFile():String
	{
		return getPath("locale/languages.txt", TEXT, "preload");
	}

	/** Extracts the library name from an OpenFL asset path. */
	public static function stripLibrary(path:String):String
	{
		return (path.indexOf(":") > -1) ? path.split(":")[0] : "";
	}

	/** Extracts the absolute file path from an asset path. */
	public static function absolutePath(path:String):String
	{
		return (path.indexOf(":") > -1) ? path.split(":")[1] : path;
	}

	/** Returns a path given its library, if found. */
	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		var sharedPath = getLibraryPathForce(file, "shared");
		if (OpenFlAssets.exists(sharedPath, type))
			return sharedPath;

		return getPreloadPath(file);
	}

	/** Returns the path for a file inside a given library. */
	public static function getLibraryPath(file:String, library:String = "preload")
	{
		if (library == "preload" || library == "default")
			return getPreloadPath(file);

		return getLibraryPathForce(file, library);
	}

	/** Returns the raw path for a file in a library. */
	static inline function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	/** Returns a preload library path. */
	static inline function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	/** Retrieves and caches a graphic. */
	public static inline function image(key:String, ?library:String):FlxGraphic
	{
		var assetPath = imagePath(key, library);
		var graphic:FlxGraphic = null;

		if (Preloader.trackedGraphics.exists(assetPath))
			graphic = Preloader.trackedGraphics.get(assetPath);
		else if (Preloader.previousTrackedGraphics.exists(assetPath))
			graphic = cast Preloader.fetchFromPreviousCache(assetPath, IMAGE);

		if (graphic == null)
			graphic = Preloader.cacheImage(assetPath);

		return graphic;
	}

	/** Retrieves an image path. */
	public static function imagePath(key:String, ?library:String):String
	{
		var assetPath = getPath('images/$key.png', IMAGE, library);

		if (isLocale())
		{
			var langPath = getPath('locale/${Preferences.language}/images/$key.png', IMAGE, library);
			if (OpenFlAssets.exists(langPath))
				assetPath = langPath;
		}

		return assetPath;
	}

	/** Returns a Sound asset. */
	public static function sound(
		key:String,
		?library:String,
		parentPath:String = "sounds/",
		?type:AssetType = SOUND
	):Sound
	{
		var assetPath = soundPath(key, library, parentPath, type);
		return retrieveSound(assetPath, type);
	}

	public static inline function soundRandom(key:String, min:Int, max:Int, ?library:String):FlxSoundAsset
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	public static inline function music(key:String, ?library:String)
	{
		return sound(key, library, "music/", MUSIC);
	}

	public static inline function inst(song:String, ?variationId:String, suffix:String = ""):Sound
	{
		return retrieveSound(instPath(song, variationId, suffix), MUSIC);
	}

	public static function instPath(song:String, ?variationId:String, suffix:String = ""):String
	{
		var variation = Song.validateVariationPath(variationId);
		return soundPath('${song.toLowerCase()}/Inst$variation$suffix', "songs", "", MUSIC);
	}

	public static inline function voices(song:String, ?variationId:String, suffix:String = ""):Sound
	{
		return retrieveSound(voicesPath(song, variationId, suffix), SOUND);
	}

	public static inline function voicesPath(song:String, ?variationId:String, suffix:String = ""):String
	{
		var variation = Song.validateVariationPath(variationId);
		return soundPath('${song.toLowerCase()}/Voices$variation$suffix', "songs", "", SOUND);
	}

	public static function soundPath(
		key:String,
		?library:String,
		?parentPath:String = "sounds/",
		?type:AssetType = SOUND
	):String
	{
		var assetPath = getPath('${parentPath}$key.$SOUND_EXT', type, library);

		if (isLocale())
		{
			var lang = getPath('locale/${Preferences.language}/$parentPath$key.$SOUND_EXT', type, library);
			if (OpenFlAssets.exists(lang))
				assetPath = lang;
		}

		return assetPath;
	}

	static function retrieveSound(key:String, type:AssetType):Sound
	{
		var sound:Sound = null;

		if (Preloader.trackedSounds.exists(key))
			sound = Preloader.trackedSounds.get(key);
		else if (Preloader.previousTrackedSounds.exists(key))
			sound = cast Preloader.fetchFromPreviousCache(key, type);

		if (sound == null)
			sound = Preloader.cacheSound(key);

		return sound;
	}

	public static inline function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		var path = getPath(file, type, library);

		if (isLocale())
		{
			var lang = getPath('locale/${Preferences.language}/$file', type, library);
			if (OpenFlAssets.exists(lang))
				path = lang;
		}

		return path;
	}

	public static inline function txt(key:String, ?library:String):String
	{
		return file('data/$key.txt', TEXT, library);
	}

	public static inline function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', TEXT, library));
	}

	public static inline function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', TEXT, library));
	}

	public static inline function atlas(key:String, ?library:String):String
	{
		return Path.withoutExtension(imagePath(key, library));
	}

	public static inline function font(key:String):String
	{
		return 'assets/fonts/$key';
	}

	public static inline function video(key:String, ?library:String):String
	{
		return getPath('videos/$key.mp4', BINARY, library);
	}

	public static inline function data(key:String, ?library:String):String
	{
		return getPath('data/$key', TEXT, library);
	}

	public static function offsetFile(character:String):String
	{
		return getPath('data/offsets/$character.txt', TEXT, "preload");
	}

	public static inline function json(key:String, ?library:String):String
	{
		return getPath('data/$key.json', TEXT, library);
	}

	public static inline function chart(key:String, ?library:String):String
	{
		return getPath('data/charts/$key.json', TEXT, library);
	}

	public static inline function script(key:String, ?library:String):String
	{
		return getPath('data/scripts/$key', TEXT, library);
	}

	public static inline function frag(key:String, ?library:String):String
	{
		return getPath('data/shaders/$key.frag', TEXT, library);
	}
}
