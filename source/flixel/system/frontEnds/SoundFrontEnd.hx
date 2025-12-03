package flixel.system.frontEnds;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import flixel.util.FlxSignal;

/**
 * Modernized SoundFrontEnd for Flixel 5.3.1 compatibility
 * + Psych Engine compatibility layer.
 */
class SoundFrontEnd
{
    // Flixel-managed groups
    public var list(default, null):Array<FlxSound> = [];
    public var defaultGroup:FlxSoundGroup;

    // Psych compatibility events
    public var onSoundCreated:FlxTypedSignal<FlxSound->Void>;

    public function new()
    {
        defaultGroup = new FlxSoundGroup("default");
        onSoundCreated = new FlxTypedSignal<FlxSound->Void>();
    }

    /** COMPAT: Psych Engine expects destroy(), but Flixel 5 removed it */
    public function destroy():Void
    {
        for (s in list)
            s.kill();
        list.resize(0);
    }

    /** COMPAT: Psych Engine expects update(), but Flixel 5 removed it */
    public function update():Void
    {
        // No-op for compatibility
        // Flixel 5 handles sounds differently now
    }

    // ----------------------------------------------------------------------
    // Modern Flixel 5 wrappers
    // ----------------------------------------------------------------------

    public function play(path:String, volume:Float = 1, looped:Bool = false):FlxSound
    {
        var s = new FlxSound();
        s.loadEmbedded(path, looped, false);
        s.volume = volume;
        s.play();

        list.push(s);
        defaultGroup.add(s);

        onSoundCreated.dispatch(s);

        return s;
    }

    public function pause():Void
        for (s in list) s.pause();

    public function resume():Void
        for (s in list) s.resume();

    public function stop():Void
        for (s in list) s.stop();

    public function reset():Void
        for (s in list) s.stop();
}
