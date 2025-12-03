package compat;

import flixel.system.frontEnds.SoundFrontEnd;
import flixel.sound.FlxSound;
import flixel.FlxG;

/**
 * Shim layer to emulate legacy SoundFrontEnd API on Flixel 5.3+.
 * Fixes:
 *  - missing constructor
 *  - missing destroy()
 *  - missing update()
 *  - missing members array
 */
class ModernSoundFrontEnd extends SoundFrontEnd
{
    // Fake list so legacy code stops crashing.
    public var members:Array<FlxSound> = [];

    public function new()
    {
        super(); // Flixel 5.3+ doesn't require arguments
    }

    // No longer exists in modern Flixel, but keep for compatibility
    public function destroy():Void {}
    public function update():Void {}

    // Legacy engines expect add(FlxSound) → Bool, modern is Void
    public override function add(sound:FlxSound):Void
    {
        super.add(sound);
        members.push(sound);
    }

    public function pause():Void {}
    public function resume():Void {}
}
