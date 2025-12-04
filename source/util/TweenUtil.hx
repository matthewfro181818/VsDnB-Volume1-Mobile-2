package util;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.math.FlxMath;

/**
 * Extra tween helpers not included in base Flixel.
 */
class TweenUtil
{
    /**
     * Returns an ease function that snaps the eased value into N steps.
     *
     * @param steps How many steps to divide the tween into.
     * @param ease  Which easing curve to apply (default = linear).
     */
    public static inline function easeSteps(steps:Int, ?ease:EaseFunction):Float->Float
    {
        if (ease == null) ease = FlxEase.linear;

        return function(t:Float):Float {
            var value = Math.floor(t * steps) / steps;
            return ease(value);
        };
    }

    /**
     * Pause all tweens in a manager.
     */
    public static inline function pauseTweens(?manager:FlxTweenManager):Void
    {
        if (manager == null) manager = FlxTween.globalManager;

        manager.forEach(function(t:FlxTween) {
            t.active = false;
        });
    }

    /**
     * Resume all tweens in a manager.
     */
    public static inline function resumeTweens(?manager:FlxTweenManager):Void
    {
        if (manager == null) manager = FlxTween.globalManager;

        manager.forEach(function(t:FlxTween) {
            t.active = true;
        });
    }

    /**
     * Completes all tweens running on `object`.
     *
     * Unlike FlxTween.completeTweensOf(), this allows forcing tweens active.
     */
    public static function completeTweensOf(
        object:Dynamic,
        ?fieldPaths:Array<String>,
        force:Bool = true,
        ?manager:FlxTweenManager
    ):Void
    {
        if (manager == null) manager = FlxTween.globalManager;

        // If not forcing, use Flixel's native implementation.
        if (!force) {
            manager.completeTweensOf(object, fieldPaths);
            return;
        }

        // Force active then complete.
        @:privateAccess
        manager.forEachTweensOf(object, fieldPaths, function(t:FlxTween) {
            t.active = true;

            // Skip tween delay.
            @:privateAccess
            t._secondsSinceStart = FlxMath.MAX_VALUE_FLOAT;
        });

        manager.completeTweensOf(object, fieldPaths);

        // Cancel afterward so property does not keep updating.
        manager.cancelTweensOf(object, fieldPaths);
    }
}
