package audio;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

/**
 * Modernized SoundGroup (Flixel 5.3.1)
 * Fixes:
 *   - Wrong return type on add()
 *   - Removed pause() / resume() overrides
 *   - Removed non-existent fields
 */
class SoundGroup extends FlxSoundGroup
{
	public function new()
	{
		super();
	}

	// -------------------------------------------------------------
	// Flixel 5.x: add() MUST return Void, not Bool
	// -------------------------------------------------------------
	override public function add(S:FlxSound):Void
	{
		if (S == null) return;

		// Avoid duplicates
		if (members.indexOf(S) == -1)
			members.push(S);

		// Apply group-wide settings
		S.volume *= volume;
	}

	// -------------------------------------------------------------
	// Flixel 5.x: pause/resume REMOVED — provide safe replacements
	// -------------------------------------------------------------
	public function pauseAll():Void
	{
		for (s in members)
		{
			if (s != null) s.pause();
		}
	}

	public function resumeAll():Void
	{
		for (s in members)
		{
			if (s != null) s.resume();
		}
	}

	// -------------------------------------------------------------
	// Ensures removing sounds works normally
	// -------------------------------------------------------------
	override public function remove(S:FlxSound, Splice:Bool = false):Void
	{
		if (S == null) return;

		if (Splice)
			members.remove(S);
	}
}
