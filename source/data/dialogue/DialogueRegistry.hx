package data.dialogue;

import openfl.utils.Assets;
import json2object.JsonParser;
import play.dialogue.Dialogue;
import play.dialogue.ScriptedDialogue;
import data.BaseRegistry;

class DialogueRegistry extends BaseRegistry<Dialogue, DialogueData> {
    // -------------------------------------------------------------------------
    // SEMVER VERSIONING
    // -------------------------------------------------------------------------

    public static var VERSION:thx.semver.Version = "1.0.0";
    public static var VERSION_RULE:thx.semver.VersionRule = "1.0.x";

    // Singleton
    public static var instance(get, never):DialogueRegistry;
    static var _instance:DialogueRegistry = null;

    static function get_instance():DialogueRegistry {
        if (_instance == null)
            _instance = new DialogueRegistry();
        return _instance;
    }

    // -------------------------------------------------------------------------
    // CONSTRUCTOR
    // -------------------------------------------------------------------------

    public function new() {
        super("DialogueRegistry", "dialogue", VERSION_RULE);
    }

    // -------------------------------------------------------------------------
    // PARSING
    // -------------------------------------------------------------------------

    override public function parseEntryData(id:String):DialogueData {
        var parser = new JsonParser<DialogueData>();

        try {
            Reflect.setField(parser, "ignoreUnknownVariables", true);
        } catch (e) {}

        switch (loadEntryFile(id)) {
            case { fileName: fileName, contents: contents }:
                parser.fromJson(contents, fileName);

            default:
                return null;
        }

        if (parser.errors.length > 0)
            printErrors(parser.errors);

        return parser.value;
    }

    // -------------------------------------------------------------------------
    // SCRIPTED DIALOGUE SUPPORT
    // -------------------------------------------------------------------------

    override function createScriptedEntry(clsName:String):Dialogue {
        return ScriptedDialogue.init(clsName, "generic");
    }

    override function getScriptedClasses():Array<String> {
        return ScriptedDialogue.listScriptClasses();
    }
}
