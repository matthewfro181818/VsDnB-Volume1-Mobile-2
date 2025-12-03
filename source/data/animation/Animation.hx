package data.animation;

import flixel.FlxSprite;
import graphics.FlxAtlasSprite;

typedef AnimationData =
{
    var name:String;
    var prefix:String;
    var ?frameRate:Int;
    var ?loop:Bool;
    var ?flip:Array<Bool>;
    var ?indices:Array<Int>;
    var ?offsets:Array<Float>;
}

class Animation
{
    public static final DEFAULT_FRAMERATE:Int = 24;

    public static function validateAnimationData(data:AnimationData):AnimationData
    {
        data.frameRate = data.frameRate ?? DEFAULT_FRAMERATE;
        data.loop = data.loop ?? false;
        data.flip = data.flip ?? [false, false];
        data.offsets = data.offsets ?? [0, 0];
        data.indices = data.indices ?? []; // important fix
        return data;
    }

    public static function addToSprite(target:FlxSprite, animation:AnimationData):Void
    {
        animation = validateAnimationData(animation);

        if (target is FlxAtlasSprite)
        {
            var sprite:FlxAtlasSprite = cast(target, FlxAtlasSprite);

            if (animation.indices.length > 0)
            {
                // Correct argument order:
                // name, prefix, indices, frameRate, loop
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
        }
        else
        {
            if (animation.indices.length > 0)
            {
                // FlxAnimationController.addByIndices(name, prefix, indices, frameRate, loop, flipX, flipY)
                target.animation.addByIndices(
                    animation.name,
                    animation.prefix,
                    animation.indices,
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
    }

    public static function addAnimationsToSprite(target:FlxSprite, animations:Array<AnimationData>):Void
    {
        for (animation in animations)
        {
            if (animation != null)
                addToSprite(target, animation);
        }
    }
}
