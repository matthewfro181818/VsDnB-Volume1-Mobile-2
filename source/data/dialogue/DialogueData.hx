package data.dialogue;

import json2object.JsonWriter;

/**
 * The data that defines the dialogue that happens before a song starts.
 */
class DialogueData {
    /**
     * The semantic version number for this data object.
     */
    public var version:String;

    /**
     * The asset path for the music that's used for the dialogue.
     * If `null` is provided, no music will be played.
     */
    @:optional
    public var music:Null<String>;

    /**
     * The amount of time (in seconds) to fade in the music.
     */
    @:default(1)
    @:optional
    public var fadeInTime:Null<Float>;

    /**
     * The amount of time (in seconds) to fade the music out.
     */
    @:default(0.5)
    @:optional
    public var fadeOutTime:Null<Float>;

    /**
     * A list of all speaker dialogue entries.
     */
    public var dialogue:Array<DialogueEntryData>;

    public function new() {}

    /**
     * Serializes this DialogueData object into a JSON string.
     */
    public function serialize():String {
        var writer = new JsonWriter<DialogueData>();
        writer.ignoreNullOptionals = true;
        return writer.write(this, " ");
    }
}
