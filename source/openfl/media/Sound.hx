package openfl.media;

#if !flash
import haxe.Int64;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import openfl.utils.Future;
import openfl.media.SoundLoaderContext;
import openfl.media.SoundTransform;
import openfl.media.ID3Info;
#end

#if lime
import lime.media.AudioBuffer;
import lime.media.AudioSource;
import openfl.utils._internal.UInt8Array;

class Sound extends EventDispatcher {

	public var bytesLoaded(default, null):Int;
	public var bytesTotal(default, null):Int;
	public var isBuffering(default, null):Bool;
	public var url(default, null):String;
	public var id3(get, never):ID3Info;
	public var length(get, never):Float;

	private var __buffer:AudioBuffer;

	// ------------------------------------------------------------
	// CONSTRUCTOR
	// ------------------------------------------------------------
	public function new(stream:URLRequest = null, context:SoundLoaderContext = null) {
		super();
		bytesLoaded = 0;
		bytesTotal = 0;
		isBuffering = false;
		url = null;

		if (stream != null) {
			load(stream, context);
		}
	}

	// ------------------------------------------------------------
	// CLOSE
	// ------------------------------------------------------------
	public function close():Void {
		if (__buffer != null) {
			__buffer.dispose();
			__buffer = null;
		}
	}

	// ------------------------------------------------------------
	// CREATION HELPERS
	// ------------------------------------------------------------
	public static function fromAudioBuffer(buffer:AudioBuffer):Sound {
		var s = new Sound();
		s.__buffer = buffer;
		return s;
	}

	public static function fromFile(path:String):Sound {
		return fromAudioBuffer(AudioBuffer.fromFile(path));
	}

	// ------------------------------------------------------------
	// LOAD FROM URL
	// ------------------------------------------------------------
	public function load(stream:URLRequest, context:SoundLoaderContext = null):Void {
		url = stream.url;

		AudioBuffer.loadFromFile(url)
			.onComplete(AudioBuffer_onURLLoad)
			.onError(_ -> AudioBuffer_onURLLoad(null));
	}

	// ------------------------------------------------------------
	// LOAD COMPRESSED (MP3/OGG)
	// ------------------------------------------------------------
	public function loadCompressedDataFromByteArray(bytes:ByteArray, bytesLength:Int):Void {
		if (bytes == null || bytesLength <= 0) {
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			return;
		}

		if (bytes.position > 0 || bytes.length > bytesLength) {
			var copy = new ByteArray(bytesLength);
			copy.writeBytes(bytes, bytes.position, bytesLength);
			bytes = copy;
		}

		__buffer = AudioBuffer.fromBytes(bytes);

		if (__buffer == null) {
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		} else {
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}

	// ------------------------------------------------------------
	// ASYNC LOAD
	// ------------------------------------------------------------
	public static function loadFromFile(path:String):Future<Sound> {
		return AudioBuffer.loadFromFile(path).then(buf ->
			Future.withValue(fromAudioBuffer(buf))
		);
	}

	// ------------------------------------------------------------
	// LOAD PCM DATA
	// ------------------------------------------------------------
	public function loadPCMFromByteArray(
		bytes:ByteArray,
		samples:Int,
		format:String = "float",
		stereo:Bool = true,
		sampleRate:Float = 44100
	):Void {

		if (bytes == null) {
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			return;
		}

		var bitsPerSample = (format == "float" ? 32 : 16);
		var channels = stereo ? 2 : 1;
		var bytesLength = Std.int(samples * channels * (bitsPerSample / 8));

		if (bytes.position > 0 || bytes.length > bytesLength) {
			var copy = new ByteArray(bytesLength);
			copy.writeBytes(bytes, bytes.position, bytesLength);
			bytes = copy;
		}

		var audioBuffer = new AudioBuffer();
		audioBuffer.bitsPerSample = bitsPerSample;
		audioBuffer.channels = channels;
		audioBuffer.data = new UInt8Array(bytes);
		audioBuffer.sampleRate = Std.int(sampleRate);

		__buffer = audioBuffer;
		dispatchEvent(new Event(Event.COMPLETE));
	}

	// ------------------------------------------------------------
	// PLAYBACK
	// ------------------------------------------------------------
	public function play(startTime:Float = 0.0, loops:Int = 0, sndTransform:SoundTransform = null):SoundChannel {
		if (__buffer == null || SoundMixer.__soundChannels.length >= SoundMixer.MAX_ACTIVE_CHANNELS) {
			return null;
		}

		if (sndTransform == null)
			sndTransform = new SoundTransform();

		var src = new AudioSource(__buffer);
		src.offset = Std.int(startTime);
		src.loops = loops;
		src.gain = SoundMixer.soundTransform.volume * sndTransform.volume;

		return new SoundChannel(src, sndTransform);
	}

	// ------------------------------------------------------------
	// ID3 + LENGTH
	// ------------------------------------------------------------
	private function get_id3():ID3Info {
		return new ID3Info();
	}

	private function get_length():Float {
		if (__buffer != null) {

			// Raw PCM
			if (__buffer.data != null) {
				return (__buffer.data.length) /
					(__buffer.channels * (__buffer.bitsPerSample >> 3) * __buffer.sampleRate) * 1000;
			}

			// Platform player (JS/HTML5 WebAudio)
			if (__buffer.src != null) {
				return __buffer.src.duration() * 1000;
			}
		}
		return 0;
	}

	// ------------------------------------------------------------
	// INTERNAL LOAD CALLBACK
	// ------------------------------------------------------------
	private function AudioBuffer_onURLLoad(buffer:AudioBuffer):Void {
		if (buffer == null) {
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		} else {
			__buffer = buffer;
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}

}
#else
typedef Sound = flash.media.Sound;
#end
