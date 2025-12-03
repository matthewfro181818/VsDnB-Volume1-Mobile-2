package flixel.animation;

import flixel.FlxG;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;

/**
 * Handles frame-based animations.
 */
class FlxAnimation extends FlxBaseAnimation
{
    public var delay:Float;

    public function new(
        name:String,
        parent:FlxAnimationController,
        frames:Array<Int>,
        frameRate:Int = 0,
        looped:Bool = true)
    {
        super(parent, frameRate, looped);
        this.name = name;
        this.frames = frames;
        this.delay = (frameRate > 0 ? 1 / frameRate : 0);
    }

    override public function destroy():Void
    {
        frames = null;
        name = null;
        super.destroy();
    }

    override public function update(elapsed:Float):Void
    {
        if (delay > 0 && !paused && (!finished || looped))
        {
            _frameTimer += elapsed;
            while (_frameTimer > delay)
            {
                _frameTimer -= delay;

                if (looped && curFrame == frames.length - 1)
                    set_curFrame(0);
                else
                    set_curFrame(curFrame + 1);
            }
        }
    }

    override public function clone(parent:FlxAnimationController):FlxAnimation
    {
        return new FlxAnimation(name, parent, frames.copy(), frameRate, looped);
    }

    var _frameTimer:Float = 0;

    function set_curFrame(frame:Int):Int
    {
        if (frame >= frames.length)
        {
            if (looped)
                frame %= frames.length;
            else
                frame = frames.length - 1;
        }
        curFrame = frame;
        return frame;
    }
}
