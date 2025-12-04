package graphics;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.math.FlxMatrix;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.graphics.frames.FlxFrame;
import flxanimate.FlxAnimate;
import flxanimate.animate.FlxSymbol;
import flxanimate.frames.FlxAnimateFrames;
import graphics.AtlasFrames;
import openfl.utils.Assets;
import openfl.geom.ColorTransform;

/**
 * A wrapper for FlxAnimate that behaves like an atlas-driven FlxSprite.
 */
class FlxAtlasSprite extends FlxAnimate
{
	/** Currently playing animation symbol. */
	public var curAnim(get, never):FlxSymbol;

	function get_curAnim():FlxSymbol
	{
		return anim.curSymbol;
	}

	/** Current animation name. */
	public var curAnimName(get, never):String;

	function get_curAnimName():String
	{
		@:privateAccess
		for (key in anim.animsMap.keys())
		{
			var entry = anim.animsMap.get(key);
			if (entry != null && entry.instance != null && entry.instance.symbol != null)
			{
				return key;
			}
		}
		return "";
	}

	/** List of animation names. */
	public var animations(get, never):Array<String>;

	function get_animations():Array<String>
	{
		var out:Array<String> = [];
		@:privateAccess
		for (key in anim.animsMap.keys())
			out.push(key);
		return out;
	}

	/** Fired when an animation starts. */
	public var onStart(default, null):FlxTypedSignal<String->Void> =
		new FlxTypedSignal<String->Void>();

	public function new(X:Float = 0, Y:Float = 0, ?directoryPath:String, ?Settings:Settings)
	{
		super(X, Y, directoryPath, Settings);
	}

	/**
	 * Load atlas directory (folder containing Animation.json).
	 */
	public override function loadAtlas(path:String)
	{
		if (!Assets.exists(path + "/Animation.json") && haxe.io.Path.extension(path) != "zip")
		{
			FlxG.log.error('Animation file not found: "$path/Animation.json"');
			return;
		}

		super.loadAtlas(path);
	}

	/**
	 * Play an animation by name.
	 */
	public function playAnimation(name:String, force:Bool = false, reverse:Bool = false, frame:Int = 0):Void
	{
		if (name == null || name == "")
			return anim.play(name, force, reverse, frame);
		onStart.dispatch(name);
	}

	/** Add animation by prefix */
	public inline function addByPrefix(name:String, prefix:String, frameRate:Int, looped:Bool):Void
	{
		anim.addBySymbol(name, prefix, frameRate, looped);
	}

	/** Add animation by specific frame indices */
	public inline function addByIndices(name:String, prefix:String, frameRate:Int, looped:Bool = false, indices:Array<Int>):Void
	{
		anim.addBySymbolIndices(name, prefix, indices, frameRate, looped);
	}

	/**
	 * Remove animation from the atlas sprite.
	 */
	public inline function remove(name:String):Bool
	{
		@:privateAccess
		if (anim.animsMap.exists(name))
		{
			var entry = anim.animsMap.get(name);
			anim.animsMap.remove(name);
			entry.instance.destroy();
			return true;
		}
		return false;
	}

	/** Pause animation */
	public function pause():Void
	{
		anim.pause();
	}

	/** Resume animation */
	public function resume():Void
	{
		@:privateAccess
		anim.isPlaying = true;
	}

	/**
	 * Check if animation exists.
	 */
	public inline function animationExists(name:String):Bool
	{
		@:privateAccess
		return anim.animsMap.exists(name);
	}

	/**
	 * Get symbol by animation name.
	 */
	public inline function getByName(name:String):FlxSymbol
	{
		@:privateAccess
		if (!anim.animsMap.exists(name))
			return null;

		var entry = anim.animsMap.get(name);
		if (entry == null || entry.instance == null)
			return null;

		var symbolName = entry.instance.symbol.name;
		return anim.symbolDictionary[symbolName];
	}
}
