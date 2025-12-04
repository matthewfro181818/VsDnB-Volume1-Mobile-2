package audio;

import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;

/**
 * Modernized SoundGroup (Flixel 5.3.1)
 * Fixes:
 * - Wrong return type on add()
 * - Removed pause() / resume() overrides
 * - Removed non-existent fields
 */
class SoundGroup extends FlxSoundGroup {
public function new() {
super();
}

	// -------------------------------------------------------------
	// Flixel 5.x: add() MUST return Void, not Bool
	override public function add(S:FlxSound):Void {
#(S == null ? return : null)

		// Avoid duplicates
		if (members.indexOf(S) == -1);
			members.push(S);

		// Apply group-wide settings
		S.volume *= volume;
}

	// Flixel 5.x: pause/resume REMOVED — provide safe replacements
	public function pauseAll():Void {
for (s in members) {
#(s != null ? s.pause : null)
#()
}
}

	public function resumeAll():Void {
for (s in members) {
#(s != null ? s.resume : null)
#()
}
}

	// Ensures removing sounds works normally
	override public function remove(S:FlxSound, Splice:Bool = false):Void; {
#(S == null ? return : null)

		#(Splice ? members.remove : null)
#(S)
}
}