package ui;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.animation.FlxAnimationController;
import flixel.FlxG;
import openfl.geom.Point;

enum AlphabetShadowMode
{
    NONE;
    SIMPLE;
}

class Alphabet extends FlxSprite
{
    public var text:String = "";
    public var targetY:Float = 0;

    public var isMenuItem:Bool = false;
    public var bold:Bool = false;
    public var isStatic:Bool = false;
    public var shadowMode:AlphabetShadowMode = NONE;

    public var textColor:FlxColor = FlxColor.WHITE;

    public var letterSpacing:Float = 2;
    public var lineSpacing:Float = 0;

    public var dropShadowOffset:Point = new Point(2, 2);
    public var dropShadowColor:FlxColor = FlxColor.BLACK;

    public var letterText:FlxText;
    public var wobble:Bool = false;
    public var wobbleIntensity:Float = 1.0;

    public var scrollSpeed:Float = 120;
    public var scrollOffset:Float = 0;

    public var animationActive:Bool = false;

    public var alphaTarget:Float = 1;
    public var alphaLerpSpeed:Float = 6;

    // ---------------------------------------------------------
    // Constructor
    // ---------------------------------------------------------

    public function new(x:Float, y:Float, text:String)
    {
        super(x, y);
        this.text = text;

        letterText = new FlxText(0, 0, 0, text, 32);
        letterText.setFormat("VCR OSD Mono", 32, textColor, CENTER);
        letterText.scrollFactor.set(0, 0);
        add(letterText);

        rebuild();
    }

    // ---------------------------------------------------------
    // Rebuild letters when text changes
    // ---------------------------------------------------------

    public function rebuild():Void
    {
        if (letterText == null) return;
        letterText.text = text;
    }

    // ---------------------------------------------------------
    // Animation Cleanup (Fixes: destroyAnimations missing)
    // ---------------------------------------------------------

    public function destroyAnimations():Void
    {
        // Compatibility stub—Psych Engine expects this.
        if (letterText.animation != null)
        {
            // Safely stop and clear animations without calling non-existent APIs
            if (letterText.animation.curAnim != null)
                letterText.animation.stop();

            #if (flixel >= "5.0.0")
            // remove all animations safely
            letterText.animation._animations.clear();
            #else
            letterText.animation.animations.clear();
            #end
        }
    }

    // ---------------------------------------------------------
    // Shadow Rendering (Fixes unmatched SHADOW_XY pattern)
    // ---------------------------------------------------------

    inline function drawShadow():Void
    {
        if (shadowMode == NONE) return;

        var ox = letterText.x;
        var oy = letterText.y;

        letterText.setPosition(ox + dropShadowOffset.x, oy + dropShadowOffset.y);
        letterText.color = dropShadowColor;
        letterText.alpha = this.alpha * 0.7;
        letterText.draw();

        letterText.setPosition(ox, oy);
        letterText.color = textColor;
        letterText.alpha = this.alpha;
    }

    // ---------------------------------------------------------
    // Update
    // ---------------------------------------------------------

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // Apply wobble if enabled
        if (wobble)
        {
            scrollOffset += elapsed * scrollSpeed;
            letterText.y = Math.sin(scrollOffset) * wobbleIntensity + this.y;
        }

        // Smooth alpha transition
        if (Math.abs(alpha - alphaTarget) > 0.01)
            alpha += (alphaTarget - alpha) * elapsed * alphaLerpSpeed;

        letterText.alpha = this.alpha;
    }

    // ---------------------------------------------------------
    // Draw
    // ---------------------------------------------------------

    override public function draw()
    {
        if (shadowMode != NONE)
            drawShadow();

        letterText.color = textColor;
        letterText.alpha = this.alpha;

        letterText.draw();
    }

    // ---------------------------------------------------------
    // Cleanup
    // ---------------------------------------------------------

    override public function destroy()
    {
        destroyAnimations();
        letterText.destroy();
        super.destroy();
    }
}
