package openfl.media;

#if !flash
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.media.SoundTransform;

#if lime
import lime.media.AudioSource;
#end

@:final @:keep
class SoundChannel extends EventDispatcher
{
	// --------------------------------------------------
	// PUBLIC PROPERTIES
	// --------------------------------------------------

	public var leftPeak(get, never):Float;
	public var rightPeak(get, never):Float;

	public var position(get, set):Float;
	public var soundTransform(get, set):SoundTransform;

	public var loops(get, set):Int;
	public var endTime(get, set):Null<Int>;
	public var pitch(get, set):Float;

	// --------------------------------------------------
	// INTERNALS
	// --------------------------------------------------

	@:noCompletion private var __soundTransform:SoundTransform;
	@:noCompletion private var __valid:Bool = false;

	#if lime
	@:noCompletion private var __source:AudioSource;
	@:noCompletion private var __left:Float = 0;
	@:noCompletion private var __right:Float = 0;
	#end

	// --------------------------------------------------
	// CONSTRUCTOR
	// --------------------------------------------------

	public function new(src:AudioSource, transform:SoundTransform = null)
	{
		super();

		__soundTransform = (transform != null ? transform.clone() : new SoundTransform());

		#if lime
		__source = src;
		__valid = (__source != null);

		if (__valid)
		{
			__source.onComplete.add(onDone);
			__applyTransform();
			__source.play();
		}

		SoundMixer.__registerSoundChannel(this);
		#end
	}

	// --------------------------------------------------
	// STOP + DISPOSE
	// --------------------------------------------------

	public function stop():Void
	{
		#if lime
		if (__valid)
		{
			__source.stop();
		}
		#end

		__dispose();
	}

	private function __dispose():Void
	{
		#if lime
		if (__valid)
		{
			__source.onComplete.remove(onDone);
			__source = null;
		}
		#end

		__valid = false;
		SoundMixer.__unregisterSoundChannel(this);
	}

	// --------------------------------------------------
	// POSITION
	// --------------------------------------------------

	private function get_position():Float
	{
		#if lime
		return (__valid ? __source.currentTime : 0);
		#else
		return 0;
		#end
	}

	private function set_position(v:Float):Float
	{
		#if lime
		if (__valid)
		{
			__source.currentTime = Std.int(v);
		}
		#end
		return v;
	}

	// --------------------------------------------------
	// SOUND TRANSFORM
	// --------------------------------------------------

	private function get_soundTransform():SoundTransform
	{
		return __soundTransform.clone();
	}

	private function set_soundTransform(v:SoundTransform):SoundTransform
	{
		if (v != null)
		{
			__soundTransform.volume = v.volume;
			__soundTransform.pan = v.pan;
			__applyTransform();
		}

		return v;
	}

	private function __applyTransform():Void
	{
		#if lime
		if (__valid)
		{
			var globalVol:Float =
				(SoundMixer.soundTransform != null ? SoundMixer.soundTransform.volume : 1.0);

			__source.gain = globalVol * __soundTransform.volume;
			// AudioSource pan mapping (very simple approximate)
			__source.position.x = __soundTransform.pan;
			__source.position.z = -Math.sqrt(1 - Math.min(1, __soundTransform.pan * __soundTransform.pan));
		}
		#end
	}

	// --------------------------------------------------
	// LOOPS
	// --------------------------------------------------

	private function get_loops():Int
	{
		#if lime
		return (__valid ? __source.loops : 0);
		#else
		return 0;
		#end
	}

	private function set_loops(v:Int):Int
	{
		#if lime
		if (__valid)
		{
			__source.loops = Std.int(v);
		}
		#end
		return v;
	}

	// --------------------------------------------------
	// END TIME
	// --------------------------------------------------

	private function get_endTime():Null<Int>
	{
		#if lime
		return (__valid ? __source.length : null);
		#else
		return null;
		#end
	}

	private function set_endTime(v:Null<Int>):Null<Int>
	{
		#if lime
		if (__valid && v != null)
		{
			__source.length = Std.int(v);
		}
		#end
		return v;
	}

	// --------------------------------------------------
	// PITCH
	// --------------------------------------------------

	private function get_pitch():Float
	{
		#if lime
		return (__valid ? __source.pitch : 1.0);
		#else
		return 1.0;
		#end
	}

	private function set_pitch(v:Float):Float
	{
		#if lime
		if (__valid)
		{
			__source.pitch = v;
		}
		#end
		return v;
	}

	// --------------------------------------------------
	// PEAKS (fallback fake peak system)
	// --------------------------------------------------

	private function get_leftPeak():Float
	{
		#if lime
		return (__valid ? __source.gain * __soundTransform.volume : 0.0);
		#else
		return 0.0;
		#end
	}

	private function get_rightPeak():Float
	{
		#if lime
		return (__valid ? __source.gain * __soundTransform.volume : 0.0);
		#else
		return 0.0;
		#end
	}

	// --------------------------------------------------
	// EVENT: COMPLETE
	// --------------------------------------------------

	private function onDone():Void
	{
		__dispose();
		dispatchEvent(new Event(Event.SOUND_COMPLETE));
	}
}

#else
typedef SoundChannel = flash.media.SoundChannel;
#end
