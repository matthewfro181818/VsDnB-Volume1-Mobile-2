package audio;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.system.FlxAssets.FlxSoundAsset;
import play.save.Preferences;

/**
 * Type of sound, used to automatically apply user-defined volume multipliers.
 */
enum SoundType {
    MUSIC;
    VOICES;
    SFX;
}

/**
 * Extended FlxSound with category-based volume scaling (Music, Voices, SFX).
 */
class GameSound extends FlxSound
{
    public var soundType:SoundType = SFX;

    public function new(?type:SoundType = SFX)
    {
        super();
        this.soundType = type;
    }

    /**
     * Loads a sound into this GameSound instance.
     */
    public function load(
        embeddedSound:FlxSoundAsset,
        looped:Bool = false,
        autoDestroy:Bool = false,
        ?onComplete:Void->Void
    ):GameSound
    {
        loadEmbedded(embeddedSound, looped, autoDestroy, onComplete);
        return this;
    }

    // -------------------------------------------------------------
    // OVERRIDE VOLUME CALCULATION USING Preferences API
    // -------------------------------------------------------------

    override function updateTransform():Void
    {
        // Category-specific multiplier
        var volumeMultiplier:Float = switch (soundType)
        {
            case MUSIC:  Preferences.musicVolume;
            case VOICES: Preferences.voicesVolume;
            case SFX:    Preferences.sfxVolume;
        };

        // Global muting / master volume
        var master:Float = (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume;

        // Group volume (sound groups in Flixel)
        var groupVol:Float = (group != null ? group.volume : 1);

        // FULL VOLUME CHAIN
        _transform.volume = master * groupVol * _volume * _volumeAdjust * volumeMultiplier;

        // PAN
        _transform.pan = _pan;

        // Apply to channel
        if (_channel != null)
            _channel.soundTransform = _transform;
    }
}
