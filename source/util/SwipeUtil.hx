package util;

#if FLX_POINTER_INPUT
import flixel.FlxG;
#end

/**
 * Utility class for handling swipe gestures in HaxeFlixel and dispatching signals.
 *
 * Example:
 * if (SwipeUtil.swipeLeft)  trace("Left!");
 * if (SwipeUtil.swipeRight) trace("Right!");
 * if (SwipeUtil.swipeUp)    trace("Up!");
 * if (SwipeUtil.swipeDown)  trace("Down!");
 * if (SwipeUtil.swipeAny)   trace("Any direction!");
 */
class SwipeUtil {

    // ------------------------------------------
    // PUBLIC READ-ONLY PROPERTIES
    // ------------------------------------------

    public static var swipeDown (get, never):Bool;
    public static var swipeLeft (get, never):Bool;
    public static var swipeRight(get, never):Bool;
    public static var swipeUp   (get, never):Bool;
    public static var swipeAny  (get, never):Bool;

    // ------------------------------------------
    // INTERNAL SWIPE CHECKERS
    // ------------------------------------------

    @:noCompletion
    static function get_swipeDown():Bool {
        #if FLX_POINTER_INPUT
        for (swipe in FlxG.swipes) {
            if (swipe.degrees > -135 && swipe.degrees < -45 && swipe.distance > 20)
                return true;
        }
        #end
        return false;
    }

    @:noCompletion
    static function get_swipeLeft():Bool {
        #if FLX_POINTER_INPUT
        for (swipe in FlxG.swipes) {
            if ((swipe.degrees > 135 || swipe.degrees < -135) && swipe.distance > 20)
                return true;
        }
        #end
        return false;
    }

    @:noCompletion
    static function get_swipeRight():Bool {
        #if FLX_POINTER_INPUT
        for (swipe in FlxG.swipes) {
            if (swipe.degrees > -45 && swipe.degrees < 45 && swipe.distance > 20)
                return true;
        }
        #end
        return false;
    }

    @:noCompletion
    static function get_swipeUp():Bool {
        #if FLX_POINTER_INPUT
        for (swipe in FlxG.swipes) {
            if (swipe.degrees > 45 && swipe.degrees < 135 && swipe.distance > 20)
                return true;
        }
        #end
        return false;
    }

    @:noCompletion
    static function get_swipeAny():Bool {
        return swipeDown || swipeUp || swipeLeft || swipeRight;
    }
}
