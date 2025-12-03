package audio;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

/**
 * Psych Engine–compatible SoundGroup for Flixel 5.
 */
class SoundGroup extends FlxSoundGroup
{
    public function new(id:String)
    {
        super(id);
    }

    // ------------------------------------------------------------------
    // Overrides made safe for Flixel 5.3.1
    // Flixel 5 changed return types so we adapt here
    // ------------------------------------------------------------------

    override public function add(S:FlxSound):Void
    {
        super.add(S);
    }

    override public function remove(S:FlxSound):Void
    {
        super.remove(S);
    }

    /** Psych Engine expects pause(), Flixel 5 removed it */
    public function pause():Void
    {
        for (s in members)
            s.pause();
    }

    /** Psych Engine expects resume(), Flixel 5 removed it */
    public function resume():Void
    {
        for (s in members)
            s.resume();
    }

    /** Psych Engine expects stop() */
    public function stop():Void
    {
        for (s in members)
            s.stop();
    }
}
