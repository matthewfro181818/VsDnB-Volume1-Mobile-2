package util;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
#if FLX_TOUCH
import flixel.input.touch.FlxTouch;
import flixel.math.FlxPoint;
#end

/**
 * Utility class for handling touch input within the FlxG context.
 */
class TouchUtil {
    // ---------------------------------------------------------
    // Static Touch Flags
    // ---------------------------------------------------------

    public static var pressed(get, never):Bool;
    public static var justPressed(get, never):Bool;
    public static var justReleased(get, never):Bool;
    public static var touch(get, never):FlxTouch; // first touch

    // ---------------------------------------------------------
    // SIMPLE OVERLAP
    // ---------------------------------------------------------

    /**
     * Checks if the specified object overlaps with any active touch.
     */
    public static function overlaps(object:FlxBasic, ?camera:FlxCamera):Bool {
        if (object == null) return false;

        #if FLX_TOUCH
        for (touch in FlxG.touches.list) {
            if (touch.overlaps(object, camera != null ? camera : object.camera)) {
                return true;
            }
        }
        #end

        return false;
    }

    // ---------------------------------------------------------
    // COMPLEX OVERLAP (precise point tests)
    // ---------------------------------------------------------

    /**
     * Performs more accurate overlap checks using overlapsPoint().
     */
    public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera):Bool {
        if (object == null) return false;

        #if FLX_TOUCH
        if (camera == null) {
            for (cam in object.cameras) {
                for (touch in FlxG.touches.list) {
                    @:privateAccess
                    if (object.overlapsPoint(touch.getWorldPosition(cam, object._point), true, cam)) {
                        return true;
                    }
                }
            }
        } else {
            for (touch in FlxG.touches.list) {
                @:privateAccess
                if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera)) {
                    return true;
                }
            }
        }
        #end

        return false;
    }

    // ---------------------------------------------------------
    // COMPLEX POINT OVERLAP
    // ---------------------------------------------------------

    /**
     * Checks if an object overlaps a specific point.
     */
    public static function overlapsComplexPoint(object:FlxObject, point:FlxPoint, ?inScreenSpace:Bool = false, ?camera:FlxCamera):Bool {
        if (object == null || point == null) return false;

        #if FLX_TOUCH
        if (camera == null) {
            for (cam in object.cameras) {
                @:privateAccess
                if (object.overlapsPoint(point, inScreenSpace, cam)) {
                    point.putWeak();
                    return true;
                }
            }
        } else {
            @:privateAccess
            if (object.overlapsPoint(point, inScreenSpace, camera)) {
                point.putWeak();
                return true;
            }
        }
        #end

        point.putWeak();
        return false;
    }

    // ---------------------------------------------------------
    // TOUCH STATE GETTERS
    // ---------------------------------------------------------

    @:noCompletion
    private static function get_pressed():Bool {
        #if FLX_TOUCH
        for (touch in FlxG.touches.list) {
            if (touch.pressed) return true;
        }
        #end
        return false;
    }

    @:noCompletion
    private static function get_justPressed():Bool {
        #if FLX_TOUCH
        for (touch in FlxG.touches.list) {
            if (touch.justPressed) return true;
        }
        #end
        return false;
    }

    @:noCompletion
    private static function get_justReleased():Bool {
        #if FLX_TOUCH
        for (touch in FlxG.touches.list) {
            if (touch.justReleased) return true;
        }
        #end
        return false;
    }

    @:noCompletion
    private static function get_touch():FlxTouch {
        #if FLX_TOUCH
        return FlxG.touches.getFirst();
        #else
        return null;
        #end
    }
}
