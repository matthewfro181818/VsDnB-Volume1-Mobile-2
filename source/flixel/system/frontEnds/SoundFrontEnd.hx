package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

class SoundFrontEnd
{
	public var list(default, null):Array<FlxSound> = [];
	public var muteKeys:Array<Int> = [];
	public var volumeDownKeys:Array<Int> = [];
	public var volumeUpKeys:Array<Int> = [];

	public var soundGroup(default, null):FlxSoundGroup;

	public function new()
	{
		soundGroup = new FlxSoundGroup();
	}

	public function destroy():Void
	{
		for (s in list)
			s.destroy();

		list.resize(0);
		soundGroup.destroy();
	}

	public function update():Void
	{
		for (s in list)
		{
			if (s != null && !s.destroyed)
				s.update();
		}
	}

	public function play(sound:FlxSound):FlxSound
	{
		list.push(sound);
		return sound;
	}

	public function remove(sound:FlxSound):Void
	{
		list.remove(sound);
	}

	public function pause():Void
	{
		for (s in list) if (s != null) s.pause();
	}

	public function resume():Void
	{
		for (s in list) if (s != null) s.resume();
	}
}
