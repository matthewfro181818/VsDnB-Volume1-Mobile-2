package audio;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

class SoundGroup extends FlxSoundGroup
{
	public function new()
	{
		super();
	}

	override public function add(sound:FlxSound):Void
	{
		members.push(sound);
	}

	override public function pause():Void
	{
		for (s in members)
			if (s != null) s.pause();
	}

	override public function resume():Void
	{
		for (s in members)
			if (s != null) s.resume();
	}
}
