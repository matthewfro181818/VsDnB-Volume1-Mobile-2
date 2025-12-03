package flixel.graphics.frames;

class FlxFrameCompat
{
	// Psych expects "curFrame" on FlxFrame (wrong type)
	public static function get_curFrame(f:FlxFrame):Int
	{
		return 0;
	}

	// Psych expects "frames" array on FlxFrame (old API)
	public static function get_frames(f:FlxFrame):Array<FlxFrame>
	{
		return [f];
	}

	// Sustain notes expect frame.update()
	public static function update(f:FlxFrame):Void
	{
		f.updateUV();
	}
}
