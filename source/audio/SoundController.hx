package audio;

import audio.GameSound;
import audio.SoundType;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;
import flixel.system.FlxAssets.FlxSoundAsset;
import openfl.media.Sound;
import util.tools.Preloader;
import play.save.Preferences;

/**
 * Sound controller for managing GameSound instances.
 * Behaves similarly to Psych's SoundFrontEnd but for your custom GameSound class.
 */
class SoundController
{
    /** Pool of GameSound objects for reuse. */
    public static var pool(default, null):FlxTypedGroup<GameSound> = new FlxTypedGroup<GameSound>();

    /** Redirect to FlxG.sound.music */
    public static var music(get, set):FlxSound;

    static function get_music():FlxSound
        return FlxG.sound.music;

    static function set_music(v:FlxSound):FlxSound
    {
        FlxG.sound.music = v;
        return v;
    }

    /** Construct an empty GameSound */
    public static function construct():GameSound
    {
        var snd = new GameSound();
        pool.add(snd);
        return snd;
    }

    /** Add GameSound to pool */
    public static function add(snd:GameSound):GameSound
    {
        pool.add(snd);
        return snd;
    }

    /** Remove GameSound from pool */
    public static function remove(snd:GameSound):GameSound
    {
        pool.remove(snd);
        return snd;
    }

    /**
     * Play music track (wrapper around FlxG.sound.music)
     */
    public static function playMusic(
        embeddedMusic:FlxSoundAsset,
        volume:Float = 1.0,
        looped:Bool = true,
        ?group:FlxSoundGroup
    ):Void
    {
        if (group == null)
            group = FlxG.sound.defaultMusicGroup;

        if (music == null)
            music = new GameSound(SoundType.MUSIC);
        else if (music.active)
            music.stop();

        music.loadEmbedded(embeddedMusic, looped);
        music.volume = volume;
        music.persist = true;

        group.add(music);
        music.play();
    }

    /**
     * Play a single sound immediately.
     */
    public static function play(
        embeddedSound:FlxSoundAsset,
        volume:Float = 1.0,
        looped:Bool = false,
        ?soundType:SoundType = SoundType.SFX,
        ?group:FlxSoundGroup,
        autoDestroy:Bool = true,
        ?onComplete:Void->Void
    ):GameSound
    {
        if (embeddedSound is String)
            embeddedSound = cache(cast embeddedSound);

        var snd:GameSound = pool.recycle(construct)
            .load(embeddedSound, looped, autoDestroy, onComplete);

        snd.soundType = soundType;

        return loadHelper(snd, volume, group, true);
    }

    /**
     * Load a sound without necessarily playing it.
     */
    public static function load(
        embeddedSound:FlxSoundAsset,
        volume:Float = 1.0,
        looped:Bool = false,
        ?soundType:SoundType = SoundType.SFX,
        ?group:FlxSoundGroup,
        autoDestroy:Bool = false,
        autoPlay:Bool = false,
        ?onComplete:Void->Void,
        ?onLoad:Void->Void
    ):GameSound
    {
        if (embeddedSound == null)
            return null;

        var snd:GameSound = pool.recycle(construct)
            .load(embeddedSound, looped, autoDestroy, onComplete);

        snd.soundType = soundType;

        loadHelper(snd, volume, group, autoPlay);

        // Haxe privateAccess check to mimic old Psych Engine behavior
        @:privateAccess
        if (onLoad != null && snd._sound != null)
            onLoad();

        return snd;
    }

    /** Pause all sounds */
    public static function pause():Void
        FlxG.sound.pause();

    /** Resume all sounds */
    public static function resume():Void
        FlxG.sound.resume();

    /** Cache a sound through Preloader */
    public static function cache(key:FlxSoundAsset):Sound
        return Preloader.cacheSound(key);

    /**
     * Shared helper for play() and load()
     */
    static function loadHelper(
        snd:GameSound,
        volume:Float,
        ?group:FlxSoundGroup,
        autoPlay:Bool = false
    ):GameSound
    {
        if (group == null)
            group = FlxG.sound.defaultSoundGroup;

        snd.volume = volume;
        group.add(snd);

        if (autoPlay)
            snd.play();

        return snd;
    }
}
