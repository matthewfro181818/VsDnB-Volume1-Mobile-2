package graphics;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.animation.FlxAnimationController;

class FlxAtlasSprite extends FlxSprite
{
	public function new(x:Float=0, y:Float=0, atlas:FlxAtlasFrames)
	{
		super(x, y);
		this.frames = atlas;
	}

	// Psych function that HF 5.3.1 does NOT include
	public function appendByPrefix(name:String, prefix:String, frameRate:Float=24, looped:Bool=true):Void
	{
		var arr = this.frames.frames.filter(f -> f.name != null && f.name.startsWith(prefix));
		if (arr.length == 0) return;

		var ids = [for (f in arr) this.frames.frames.indexOf(f)];
		this.animation.add(name, ids, frameRate, looped);
	}

	// Psych function that HF 5.3.1 does NOT include
	public function addByIndices(name:String, prefix:String, indices:Array<Int>, frameRate:Float=24, looped:Bool=true):Void
	{
		var result:Array<Int> = [];

		for (idx in indices)
		{
			for (f in this.frames.frames)
			{
				if (f.name.startsWith(prefix))
				{
					var num = Std.parseInt(f.name.replace(prefix, ""));
					if (num == idx)
					{
						result.push(this.frames.frames.indexOf(f));
						break;
					}
				}
			}
		}

		if (result.length > 0)
			this.animation.add(name, result, frameRate, looped);
	}

	// Psych compatibility
	public function getAnimationList():Array<String>
	{
		return this.animation.getNameList();
	}
}
