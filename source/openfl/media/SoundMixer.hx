package openfl.media;

import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

/**
 * OpenFL-compatible SoundMixer replacement for projects using
 * Lime AudioSource backend.
 */
@:access(openfl.media.SoundChannel)
final class SoundMixer
{
	/** Maximum simultaneous sounds */
	public static inline var MAX_ACTIVE_CHANNELS:Int = 32;

	/** Buffering time (not used in Lime backend but kept for compatibility) */
	public static var bufferTime:Int = 0;

	/** Global sound transform */
	public static var soundTransform(get, set):SoundTransform;

	/** Internal list of active sound channels */
	private static var __soundChannels:Array<SoundChannel> = [];

	/** Global mixer transform */
	private static var __soundTransform:SoundTransform =
		#if mute_sound
			new SoundTransform(0)
		#else
			new SoundTransform()
		#end;

	// ----------------------------------------------------------------------
	// Public API
	// ----------------------------------------------------------------------

	/** Always false; kept for Flash compatibility */
	public static function areSoundsInaccessible():Bool
	{
		return false;
	}

	/** Stop ALL currently playing SoundChannels */
	public static function stopAll():Void
	{
		for (channel in __soundChannels)
		{
			channel.stop();
		}
	}

	/** Register a new sound channel */
	public static function __registerSoundChannel(channel:SoundChannel):Void
	{
		if (channel != null)
			__soundChannels.push(channel);
	}

	/** Unregister a sound channel */
	public static function __unregisterSoundChannel(channel:SoundChannel):Void
	{
		if (channel != null)
			__soundChannels.remove(channel);
	}

	// ----------------------------------------------------------------------
	// Get / Set
	// ----------------------------------------------------------------------

	private static function get_soundTransform():SoundTransform
	{
		return __soundTransform;
	}

	private static function set_soundTransform(value:SoundTransform):SoundTransform
	{
		if (value != null)
			__soundTransform = value.clone();
		else
			__soundTransform = new SoundTransform();

		// Apply new transform to all active channels
		for (channel in __soundChannels)
		{
			channel.__updateTransform();
		}

		return value;
	}
}
