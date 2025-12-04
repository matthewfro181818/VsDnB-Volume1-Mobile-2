package play.save;

import util.PlatformUtil;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.util.FlxSignal.FlxTypedSignal;

import scripting.IScriptedClass.IEventDispatcher;

/**
 * Stores user settings / preferences and exposes them globally.
 */
class Preferences {
    public static var save(default, null):FlxSave;

    // ------------------------------------------------------------
    // Default Values
    // ------------------------------------------------------------
    public static var defaults(default, null):Map<String, Any> = [
        'downscroll' => false,
        'ghostTapping' => true,
        'cutscenes' => true,

        'flashingLights' => true,
        'cameraShaking' => true,
        'cameraNoteMovement' => true,

        'masterVolume' => 1.0,
        'musicVolume' => 1.0,
        'voicesVolume' => 1.0,
        'sfxVolume' => 1.0,
        'hitsoundsVolume' => 0.7,

        'minimalUI' => false,
        'debugUI' => false,
        'timerType' => "timeLeft",

        'gimmickWarnings' => true,
        'hitsounds' => false,
        'latencyOffsets' => 0,
        'language' => "en-US",

        'vsync' => true,
        'fps' => 144,
        'borderless' => false,
        'darkMode' => false,

        'botplay' => false
    ];

    /**
     * Fired when any preference changes.
     */
    public static var onPreferenceChanged:FlxTypedSignal<(key:String, value:Any)->Void>
        = new FlxTypedSignal<(key:String, value:Any)->Void>();

    // ------------------------------------------------------------
    // INITIALIZATION
    // ------------------------------------------------------------
    public static function init():Void {
        save = new FlxSave();
        save.bind("preferences", "dnbteam");

        if (save.data == null)
            save.flush();

        load();
    }

    /**
     * Loads preferences & fills missing keys with defaults.
     */
    public static function load():Void {
        onPreferenceChanged.removeAll();

        if (save.data == null) {
            save.bind("preferences", "dnbteam");
            save.flush();
        }

        // Apply defaults where fields are missing
        for (key => val in defaults) {
            if (!Reflect.hasField(save.data, key)) {
                Reflect.setField(save.data, key, val);
            }
        }

        // Event dispatching into PlayState
        onPreferenceChanged.add((pref:String, value:Any) -> {
            var handler:IEventDispatcher = cast FlxG.state;
            if (handler != null) {
				handler.dispatchEvent(new scripting.events.PreferenceScriptEvent(pref, value));
		}
        });

        FlxG.console.registerClass(Preferences);
    }


    // ------------------------------------------------------------
    // Generic Helpers
    // ------------------------------------------------------------
    static inline function getBool(key:String):Bool return cast Reflect.field(save.data, key);
    static inline function getInt(key:String):Int return cast Reflect.field(save.data, key);
    static inline function getFloat(key:String):Float return cast Reflect.field(save.data, key);
    static inline function getStr(key:String):String return cast Reflect.field(save.data, key);

    static inline function setValue(key:String, value:Any):Any {
        Reflect.setField(save.data, key, value);
        save.flush();
        onPreferenceChanged.dispatch(key, value);
        return value;
    }

    // ------------------------------------------------------------
    // INDIVIDUAL PREFERENCES
    // ------------------------------------------------------------

    public static var downscroll(get, set):Bool;
    static inline function get_downscroll() return getBool("downscroll");
    static inline function set_downscroll(v:Bool) return setValue("downscroll", v);

    public static var ghostTapping(get, set):Bool;
    static inline function get_ghostTapping() return getBool("ghostTapping");
    static inline function set_ghostTapping(v:Bool) return setValue("ghostTapping", v);

    public static var cutscenes(get, set):Bool;
    static inline function get_cutscenes() return getBool("cutscenes");
    static inline function set_cutscenes(v:Bool) return setValue("cutscenes", v);


    // ACCESSIBILITY
    public static var flashingLights(get, set):Bool;
    static inline function get_flashingLights() return getBool("flashingLights");
    static inline function set_flashingLights(v:Bool) return setValue("flashingLights", v);

    public static var cameraShaking(get, set):Bool;
    static inline function get_cameraShaking() return getBool("cameraShaking");
    static inline function set_cameraShaking(v:Bool) return setValue("cameraShaking", v);

    public static var cameraNoteMovement(get, set):Bool;
    static inline function get_cameraNoteMovement() return getBool("cameraNoteMovement");
    static inline function set_cameraNoteMovement(v:Bool) return setValue("cameraNoteMovement", v);


    // AUDIO
    public static var masterVolume(get, set):Float;
    static function get_masterVolume() return getFloat("masterVolume");
    static function set_masterVolume(v:Float):Float {
        save.data.masterVolume = v;
        FlxG.sound.volume = v;
        save.flush();
        onPreferenceChanged.dispatch("masterVolume", v);
        return v;
    }

    public static var musicVolume(get, set):Float;
    static inline function get_musicVolume() return getFloat("musicVolume");
    static inline function set_musicVolume(v:Float) return setValue("musicVolume", v);

    public static var voicesVolume(get, set):Float;
    static inline function get_voicesVolume() return getFloat("voicesVolume");
    static inline function set_voicesVolume(v:Float) return setValue("voicesVolume", v);

    public static var sfxVolume(get, set):Float;
    static inline function get_sfxVolume() return getFloat("sfxVolume");
    static inline function set_sfxVolume(v:Float) return setValue("sfxVolume", v);

    public static var hitsoundsVolume(get, set):Float;
    static inline function get_hitsoundsVolume() return getFloat("hitsoundsVolume");
    static inline function set_hitsoundsVolume(v:Float) return setValue("hitsoundsVolume", v);


    // UI
    public static var minimalUI(get, set):Bool;
    static inline function get_minimalUI() return getBool("minimalUI");
    static inline function set_minimalUI(v:Bool) return setValue("minimalUI", v);

    public static var debugUI(get, set):Bool;
    static function get_debugUI() return getBool("debugUI");
    static function set_debugUI(v:Bool):Bool {
        save.data.debugUI = v;
        Main.fps.visible = v;
        save.flush();
        onPreferenceChanged.dispatch("debugUI", v);
        return v;
    }

    public static var timerType(get, set):String;
    static inline function get_timerType() return getStr("timerType");
    static inline function set_timerType(v:String) return setValue("timerType", v);


    // MISC
    public static var gimmickWarnings(get, set):Bool;
    static inline function get_gimmickWarnings() return getBool("gimmickWarnings");
    static inline function set_gimmickWarnings(v:Bool) return setValue("gimmickWarnings", v);

    public static var hitsounds(get, set):Bool;
    static inline function get_hitsounds() return getBool("hitsounds");
    static inline function set_hitsounds(v:Bool) return setValue("hitsounds", v);

    public static var botplay(get, set):Bool;
    static inline function get_botplay() return getBool("botplay");
    static inline function set_botplay(v:Bool) return setValue("botplay", v);

    public static var latencyOffsets(get, set):Int;
    static inline function get_latencyOffsets() return getInt("latencyOffsets");
    static inline function set_latencyOffsets(v:Int) return setValue("latencyOffsets", v);

    public static var language(get, set):String;
    static inline function get_language() return getStr("language");
    static inline function set_language(v:String) return setValue("language", v);


    // WINDOW / FRAMERATE

    public static var fps(get, set):Int;
    static function get_fps() return getInt("fps");
    static function set_fps(v:Int):Int {
        save.data.fps = v;
        save.flush();

        if (vsync) {
            #if !linux
            var refreshRate = FlxG.stage.window.displayMode.refreshRate;
            Main.frameRate = refreshRate;
            FlxG.updateFramerate = refreshRate;
            FlxG.drawFramerate = refreshRate;
            #else
            Main.frameRate = 144;
            FlxG.updateFramerate = 144;
            FlxG.drawFramerate = 144;
            #end
        } else {
            Main.frameRate = v;
            FlxG.updateFramerate = v;
            FlxG.drawFramerate = v;
        }

        onPreferenceChanged.dispatch("fps", v);
        return v;
    }

    public static var vsync(get, set):Bool;
    static function get_vsync() return getBool("vsync");
    static function set_vsync(v:Bool):Bool {
        save.data.vsync = v;
        save.flush();

        if (v) {
            #if !linux
            var refreshRate = FlxG.stage.window.displayMode.refreshRate;
            Main.frameRate = refreshRate;
            FlxG.updateFramerate = refreshRate;
            FlxG.drawFramerate = refreshRate;
            #else
            Main.frameRate = 144;
            FlxG.updateFramerate = 144;
            FlxG.drawFramerate = 144;
            #end
        } else {
            Main.frameRate = fps;
            FlxG.updateFramerate = fps;
            FlxG.drawFramerate = fps;
        }

        onPreferenceChanged.dispatch("vsync", v);
        return v;
    }


    public static var borderless(get, set):Bool;
    static function get_borderless() return getBool("borderless");
    static function set_borderless(v:Bool):Bool {
        save.data.borderless = v;
        save.flush();

        FlxG.stage.window.borderless = v;

        onPreferenceChanged.dispatch("borderless", v);
        return v;
    }


    public static var darkMode(get, set):Bool;
    static function get_darkMode() return getBool("darkMode");
    static function set_darkMode(v:Bool):Bool {
        save.data.darkMode = v;
        save.flush();

        PlatformUtil.setDarkMode(FlxG.stage.window.title, v);

        // Fix window flicker when switching dark mode
        if (!borderless) {
            FlxG.stage.window.borderless = true;
            FlxG.stage.window.borderless = false;
        }

        onPreferenceChanged.dispatch("darkMode", v);
        return v;
    }
}
