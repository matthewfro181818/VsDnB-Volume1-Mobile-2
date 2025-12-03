package flixel.animation;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

// bind controller to your animation backend
import flixel.animation.FlxBaseAnimation;
typedef FlxAnimation = flixel.animation.FlxBaseAnimation;

using StringTools;

class FlxAnimationController implements IFlxDestroyable
{
    public var curAnim(get, set):FlxAnimation;
    public var frameIndex(default, set):Int = -1;
    public var frameName(get, set):String;
    public var name(get, set):String;
    public var paused(get, set):Bool;
    public var finished(get, set):Bool;
    public var numFrames(get, never):Int;

    @:deprecated("Use onFrameChange instead")
    public var callback:(animName:String, frameNumber:Int, frameIndex:Int)->Void;

    @:deprecated("Use onFinish instead")
    public var finishCallback:(animName:String)->Void;

    public final onFrameChange = new FlxTypedSignal<(String, Int, Int)->Void>();
    public final onFinish = new FlxTypedSignal<(String)->Void>();
    public final onLoop = new FlxTypedSignal<(String)->Void>();

    public var timeScale:Float = 1.0;

    var _sprite:FlxSprite;
    var _curAnim:FlxAnimation;
    var _animations:Map<String, FlxAnimation> = [];
    var _prerotated:FlxPrerotatedAnimation;

    public function new(sprite:FlxSprite)
    {
        _sprite = sprite;
    }

    public function update(elapsed:Float):Void
    {
        if (_curAnim != null)
        {
            _curAnim.update(elapsed * (timeScale * FlxG.animationTimeScale));
        }
        else if (_prerotated != null)
        {
            _prerotated.angle = _sprite.angle;
        }
    }

    public function copyFrom(other:FlxAnimationController):FlxAnimationController
    {
        destroyAnimations();

        for (anim in other._animations)
            add(anim.name, anim.frames, anim.frameRate, anim.looped, anim.flipX, anim.flipY);

        if (other._prerotated != null)
            createPrerotated();

        if (other.name != null)
            name = other.name;

        frameIndex = other.frameIndex;
        return this;
    }

    public function createPrerotated(?c:FlxAnimationController):Void
    {
        destroyAnimations();
        c = (c != null) ? c : this;

        _prerotated = new FlxPrerotatedAnimation(c, c._sprite.bakedRotationAngle);
        _prerotated.angle = _sprite.angle;
    }

    public function destroyAnimations():Void
    {
        clearAnimations();
        clearPrerotated();
    }

    @:haxe.warning("-WDeprecated")
    public function destroy():Void
    {
        FlxDestroyUtil.destroy(onFrameChange);
        FlxDestroyUtil.destroy(onFinish);
        FlxDestroyUtil.destroy(onLoop);

        destroyAnimations();
        _animations = null;
        callback = null;
        finishCallback = null;
        _sprite = null;
    }

    function clearPrerotated():Void
    {
        if (_prerotated != null)
            _prerotated.destroy();

        _prerotated = null;
    }

    function clearAnimations():Void
    {
        for (key in _animations.keys())
        {
            var a = _animations.get(key);
            if (a != null)
                a.destroy();
        }

        _animations = new Map<String, FlxAnimation>();
        _curAnim = null;
    }

    public function add(name:String, frames:Array<Int>, frameRate = 30.0, looped = true, flipX = false, flipY = false):Void
    {
        if (numFrames == 0)
        {
            FlxG.log.warn('Could not create animation "$name": sprite has no frames.');
            return;
        }

        var anim = new FlxAnimation(this, name, frames, frameRate, looped, flipX, flipY);
        _animations.set(name, anim);
    }

    public function remove(name:String):Void
    {
        var a = _animations.get(name);
        if (a != null)
        {
            a.destroy();
            _animations.remove(name);
        }
    }

    public function play(name:String, force = false, reversed = false, frame = 0):Void
    {
        if (name == null)
        {
            if (_curAnim != null) _curAnim.stop();
            _curAnim = null;
            return;
        }

        if (!_animations.exists(name))
        {
            FlxG.log.warn('No animation called "$name"');
            return;
        }

        var oldX = false;
        var oldY = false;

        if (_curAnim != null && name != _curAnim.name)
        {
            oldX = _curAnim.flipX;
            oldY = _curAnim.flipY;
            _curAnim.stop();
        }

        _curAnim = _animations.get(name);
        _curAnim.play(force, reversed, frame);

        if (oldX != _curAnim.flipX || oldY != _curAnim.flipY)
            _sprite.dirty = true;
    }

    public inline function reset():Void
        if (_curAnim != null) _curAnim.reset();

    public function finish():Void
        if (_curAnim != null) _curAnim.finish();

    public function stop():Void
        if (_curAnim != null) _curAnim.stop();

    public function pause():Void
        if (_curAnim != null) _curAnim.pause();

    public function resume():Void
        if (_curAnim != null) _curAnim.resume();

    public function reverse():Void
        if (_curAnim != null) _curAnim.reverse();

    public inline function getByName(n:String):FlxAnimation
        return _animations.get(n);

    public function randomFrame():Void
    {
        if (_curAnim != null)
        {
            _curAnim.stop();
            _curAnim = null;
        }

        frameIndex = FlxG.random.int(0, numFrames - 1);
    }

    // CALLBACKS -----------------------------------------------------

    @:haxe.warning("-WDeprecated")
    function fireCallback():Void
    {
        var n = (_curAnim != null) ? _curAnim.name : null;
        var f = (_curAnim != null) ? _curAnim.curFrame : frameIndex;

        if (callback != null)
            callback(n, f, frameIndex);

        onFrameChange.dispatch(n, f, frameIndex);
    }

    @:allow(flixel.animation)
    function fireFinishCallback(n:String):Void
    {
        if (finishCallback != null)
            finishCallback(n);

        onFinish.dispatch(n);
    }

    @:allow(flixel.animation)
    function fireLoopCallback(n:String):Void
        onLoop.dispatch(n);

    // FRAME INDEXING -----------------------------------------------

    inline function get_frameName():String
        return _sprite.frame.name;

    function set_frameName(v:String):String
    {
        if (_sprite.frames != null && _sprite.frames.exists(v))
        {
            if (_curAnim != null)
            {
                _curAnim.stop();
                _curAnim = null;
            }

            var f = _sprite.frames.getByName(v);
            if (f != null)
                frameIndex = getFrameIndex(f);
        }
        return v;
    }

    function get_name():String
        return (_curAnim != null) ? _curAnim.name : null;

    function set_name(v:String):String
    {
        play(v);
        return v;
    }

    public function getAnimationList():Array<FlxAnimation>
    {
        var list = [];
        for (a in _animations)
            list.push(a);
        return list;
    }

    public function getNameList():Array<String>
    {
        var list = [];
        for (k in _animations.keys())
            list.push(k);
        return list;
    }

    public function exists(n:String):Bool
        return _animations.exists(n);

    public function rename(old:String, New:String)
    {
        var a = _animations.get(old);
        if (a == null)
        {
            FlxG.log.warn('No animation called "$old"');
            return;
        }

        a.name = New;
        _animations.set(New, a);
        _animations.remove(old);
    }

    inline function get_curAnim():FlxAnimation
        return _curAnim;

    inline function set_curAnim(a:FlxAnimation):FlxAnimation
    {
        if (a != _curAnim)
        {
            if (_curAnim != null) _curAnim.stop();
            if (a != null) a.play();
        }
        _curAnim = a;
        return a;
    }

    inline function get_paused():Bool
        return (_curAnim != null) ? _curAnim.paused : false;

    inline function set_paused(v:Bool):Bool
    {
        if (_curAnim != null)
        {
            if (v) _curAnim.pause();
            else _curAnim.resume();
        }
        return v;
    }

    function get_finished():Bool
        return (_curAnim != null) ? _curAnim.finished : true;

    inline function set_finished(v:Bool):Bool
    {
        if (v && _curAnim != null)
            _curAnim.finish();
        return v;
    }

    inline function get_numFrames():Int
        return _sprite.numFrames;

    public inline function getFrameIndex(f:FlxFrame):Int
        return _sprite.frames.frames.indexOf(f);

    function set_frameIndex(i:Int):Int
    {
        if (_sprite.frames != null && numFrames > 0)
        {
            i = i % numFrames;
            _sprite.frame = _sprite.frames.frames[i];
            frameIndex = i;
            fireCallback();
        }
        return frameIndex;
    }
}
