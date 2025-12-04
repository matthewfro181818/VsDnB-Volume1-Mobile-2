package data.animation;

import flixel.FlxSprite;
import graphics.FlxAtlasSprite;

/**
 * Structure describing a single animation.
 */
typedef AnimationData = {
	var name:String;
	var prefix:String;
	@:optional var frameRate:Int;
	@:optional var loop:Bool;
	@:optional var flip:Array<Bool>;
	@:optional var indices:Array<Int>;
	@:optional var offsets:Array<Float>;
}

/**
 * Animation utility class for applying JSON-defined animations to sprites.
 */
class Animation
{
	public static final DEFAULT_FRAMERATE:Int = 24;

	/**
	 * Ensure animation fields have safe fallback values.
	 */
	public static function validateAnimationData(data:AnimationData):AnimationData
	{
		data.frameRate = data.frameRate ?? DEFAULT_FRAMERATE;
		data.loop = data.loop ?? false;
		data.flip = data.flip ?? [false, false];
		data.offsets = data.offsets ?? [0, 0];
		return data;
	}

	/**
	 * Apply one animation to a sprite.
	 */
	public static function addToSprite(target:FlxSprite, animation:AnimationData):Void
	{
		animation = validateAnimationData(animation);

		// Atlas-based animations (Texture Atlas)
		if (Std.isOfType(target, FlxAtlasSprite))
		{
			var sprite:FlxAtlasSprite = cast target;

			if (animation.indices != null)
			{
				sprite.addByIndices(
					animation.name,
					animation.prefix,
					animation.indices,
					animation.frameRate,
					animation.loop
				);
			}
			else
			{
				sprite.addByPrefix(
					animation.name,
					animation.prefix,
					animation.frameRate,
					animation.loop
				);
			}

			return;
		}

		// Regular FNF FlxSprite animation
		if (animation.indices != null)
		{
			target.animation.addByIndices(
				animation.name,
				animation.prefix,
				animation.indices,
				"",
				animation.frameRate,
				animation.loop,
				animation.flip[0],
				animation.flip[1]
			);
		}
		else
		{
			target.animation.addByPrefix(
				animation.name,
				animation.prefix,
				animation.frameRate,
				animation.loop,
				animation.flip[0],
				animation.flip[1]
			);
		}
	}

	/**
	 * Add multiple animations to a sprite.
	 */
	public static function addAnimationsToSprite(target:FlxSprite, animations:Array<AnimationData>):Void
	{
		for (animation in animations)
		{
			if (animation != null)
				addToSprite(target, animation);
		}
	}
}
