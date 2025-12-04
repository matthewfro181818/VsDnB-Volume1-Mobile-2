package scripting.events;

import scripting.IEventDispatcher;

/**
 * Event fired when a user preference / option changes.
 *
 * Dispatched from Preferences when something like "downscroll" or
 * "musicVolume" is updated, so scripts / states can react.
 */
class PreferenceScriptEvent extends ScriptEvent {
    /** The name/key of the preference, e.g. "downscroll", "musicVolume". */
    public var key:String;

    /** The new value of the preference (Bool, Int, Float, String, etc.). */
    public var value:Dynamic;

    public function new(key:String, value:Dynamic) {
        // We don't care about ScriptEventType here specifically; pass null
        // to the base ScriptEvent constructor so it still has a valid instance.
        super(null);

        this.key = key;
        this.value = value;
    }
}