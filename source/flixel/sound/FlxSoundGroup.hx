package flixel.sound;

class FlxSoundGroup
{
	public var members:Array<FlxSound> = [];

	public function new() {}

	public function destroy():Void
	{
		members.resize(0);
	}

	public function add(sound:FlxSound):Void
	{
		members.push(sound);
	}

	public function pause():Void
	{
		for (s in members) if (s != null) s.pause();
	}

	public function resume():Void
	{
		for (s in members) if (s != null) s.resume();
	}
}
