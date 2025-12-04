package data.dialogue;

/**
 * Defines the data inside each dialogue entry.
 */
typedef DialogueEntryData = {
    /**
     * Who is speaking (speaker ID).
     */
    var speaker:String;

    /**
     * Optional expression name.
     */
    @:optional
    var expression:String;

    /**
     * Localization key for text.
     */
    @:optional @:default("")
    var text:String;

    /**
     * Typing speed for this entry.
     */
    @:optional @:default(0.04)
    var typeSpeed:Float;

    /**
     * "left", "middle", or "right".
     */
    var side:String;

    /**
     * Optional modifier string.
     */
    @:optional
    var modifier:Null<String>;

    /**
     * Optional position offsets.
     */
    @:optional @:default([0, 0])
    var offsets:Array<Float>;
}
