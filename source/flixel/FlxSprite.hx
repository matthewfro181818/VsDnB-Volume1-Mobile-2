package flixel;

import flixel.util.FlxColor;
import flixel.animation.FlxAnimationController;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import openfl.geom.Rectangle;
import openfl.geom.Point;

/**
 * Modernized FlxSprite for Flixel 5.3.1 but with full Psych Engine API restored.
 */
class FlxSprite extends FlxBasic
{
    public var x:Float = 0;
    public var y:Float = 0;

    public var width:Float = 0;
    public var height:Float = 0;

    public var offset:Point = new Point();
    public var origin:Point = new Point();
    public var scale:Point = new Point(1, 1);

    public var flipX:Bool = false;
    public var flipY:Bool = false;

    public var frames:FlxFramesCollection;
    public var frame:FlxFrame;

    public var animation:FlxAnimationController;

    public var frameWidth(default, null):Int = 0;
    public var frameHeight(default, null):Int = 0;

    public var antialiasing:Bool = true;
    public var graphic:FlxGraphic;

    // ----------------------------------------------------------
    // CONSTRUCTOR
    // ----------------------------------------------------------

    public function new(?x:Float = 0, ?y:Float = 0)
    {
        super();
        this.x = x;
        this.y = y;
        animation = new FlxAnimationController(this, "");
    }

    // ----------------------------------------------------------
    // GRAPHIC LOADING
    // ----------------------------------------------------------

    public function loadGraphic(asset:FlxGraphic, animated:Bool=false, frameWidth:Int=0, frameHeight:Int=0)
    {
        graphic = asset;

        if (!animated)
        {
            this.frameWidth = asset.width;
            this.frameHeight = asset.height;

            var rect = new Rectangle(0, 0, asset.width, asset.height);

            frames = new FlxFramesCollection(asset);
            frame = frames.addFrame(rect);
        }
        else
        {
            this.frameWidth = frameWidth;
            this.frameHeight = frameHeight;

            frames = asset.imageFrame;
            frame = frames.frames[0];
        }

        updateHitbox();
        return this;
    }

    /**
     * Psych Engine compatibility function.
     */
    public inline function loadGraphicFromSprite(other:FlxSprite)
    {
        graphic = other.graphic;
        frames = other.frames;
        frame = other.frame;

        frameWidth = other.frameWidth;
        frameHeight = other.frameHeight;

        updateHitbox();
        return this;
    }

    // ----------------------------------------------------------
    // FRAME SETTER
    // ----------------------------------------------------------

    public function set_frame(f:FlxFrame):FlxFrame
    {
        frame = f;
        frameWidth = Std.int(f.frame.width);
        frameHeight = Std.int(f.frame.height);
        updateHitbox();
        return f;
    }

    // ----------------------------------------------------------
    // UPDATE LOOP
    // ----------------------------------------------------------

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        if (animation != null)
            animation.update(elapsed);
    }

    // ----------------------------------------------------------
    // HITBOX & VISUAL FIXES
    // ----------------------------------------------------------

    public function updateHitbox()
    {
        width = frameWidth * scale.x;
        height = frameHeight * scale.y;

        origin.set(width * 0.5, height * 0.5);
    }

    public function centerOffsets()
    {
        offset.x = (frameWidth * scale.x - frameWidth) / 2;
        offset.y = (frameHeight * scale.y - frameHeight) / 2;
    }

    public function centerOrigin()
    {
        origin.set(width * 0.5, height * 0.5);
    }

    // ----------------------------------------------------------
    // COLOR UTILITIES (Psych Compatibility)
    // ----------------------------------------------------------

    public function replaceColor(from:FlxColor, to:FlxColor)
    {
        if (graphic == null)
            return;

        graphic.bitmap.lock();
        graphic.bitmap.threshold(graphic.bitmap, graphic.bitmap.rect, new Point(), "==", from, to, 0xFFFFFFFF, true);
        graphic.bitmap.unlock();
    }

    // ----------------------------------------------------------
    // prerotated STUB for backward compatibility
    // ----------------------------------------------------------

    public function createPrerotated()
    {
        // Psych Engine expects this to exist but we do nothing.
        return this;
    }

    // ----------------------------------------------------------
    // DRAWING
    // ----------------------------------------------------------

    override public function draw()
    {
        if (graphic == null || frame == null)
            return;

        super.draw();
    }
}
