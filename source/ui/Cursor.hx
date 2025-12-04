package ui;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.display.BitmapData;

typedef CursorParams = {
    graphic:FlxGraphicAsset,
    ?scale:Float,
    ?offset:FlxPoint
};

class Cursor {
    /**
     * Whether this mouse is currently visible or not.
     */
    public static var visible(default, set):Bool = false;

    static function set_visible(value:Bool):Bool {
        if (visible == value)
            return visible;

        setVisible(value);
        visible = value;
        return visible;
    }

    /**
     * The graphic asset of the game's default cursor.
     */
    public static var DEFAULT_CURSOR:FlxGraphicAsset = "cursor";

    /**
     * The parameters for the game's default cursor.
     */
    public static final DEFAULT_CURSOR_PARAMS:CursorParams = {
        graphic: DEFAULT_CURSOR,
        scale: 1,
        offset: FlxPoint.get()
    };

    /**
     * Initializes the cursor graphic.
     */
    public static function initialize():Void {
        reset();
        FlxG.signals.preUpdate.add(update);
        FlxG.console.registerClass(Cursor);
    }

    static function update():Void {
        if (visible != FlxG.mouse.visible)
            setVisible(visible);
    }

    /**
     * Loads a new cursor graphic given parameters.
     */
    public static function load(params:CursorParams):Void {
        params.scale = params.scale == null ? 1 : params.scale;
        params.offset = params.offset == null ? FlxPoint.get() : params.offset;

        if (params.graphic == null) {
            reset();
            return;
        }

        applyCursorParams(params);
    }

    /**
     * Resets the cursor to the default cursor graphic.
     */
    public static function reset():Void {
        FlxG.mouse.unload();
        load(DEFAULT_CURSOR_PARAMS);

        // Ensure visibility stays consistent
        if (visible)
            show();
        else
            hide();
    }

    /** Enables the cursor. */
    public static function show():Void {
        setVisible(true);
    }

    /** Disables the cursor. */
    public static function hide():Void {
        setVisible(false);
    }

    static function setVisible(val:Bool):Void {
        FlxG.mouse.visible = val;
        visible = val;
    }

    /**
     * Toggles cursor visibility.
     */
    public static function toggle():Void {
        if (visible)
            hide();
        else
            show();
    }

    /**
     * Applies the cursor settings to FlxG.mouse.
     */
    static function applyCursorParams(params:CursorParams):Void {
        var bitmap:BitmapData = null;

        if (params.graphic is FlxGraphic) {
            var g:FlxGraphic = cast params.graphic;
            bitmap = g.bitmap;
        } else {
            // Load from image path
            var spr:FlxGraphic = Paths.image(cast params.graphic);
            bitmap = spr.bitmap;
        }

        FlxG.mouse.load(bitmap, params.scale, Std.int(params.offset.x), Std.int(params.offset.y));
    }
    /** Loads a new cursor graphic given parameters.
    */    public static function load(params:CursorParams):Void {               
        params.scale = params.scale == null ? 1 : params.scale;
        params.offset = params.offset == null ? FlxPoint.get() : params.offset;

        if (params.graphic == null) {
            reset();
            return;
        }

        applyCursorParams(params);
    }
}