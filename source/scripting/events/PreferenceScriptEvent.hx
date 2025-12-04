package scripting.events;

class PreferenceScriptEvent extends ScriptEvent {
    public var preference:String;
    public var value:Dynamic;

    public function new(preference:String, value:Dynamic, ?canceled:Bool = false) {
        super(ScriptEventType.PREFERENCE_CHANGE, canceled);
        this.preference = preference;
        this.value = value;
    }
}
