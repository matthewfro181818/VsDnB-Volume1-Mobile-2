package data;

import data.IRegistryEntry;
import flixel.FlxG;
import haxe.Constraints.Constructible;
import openfl.utils.Assets;
import util.VersionUtil;
import thx.semver.Version;
import thx.semver.VersionRule;

/**
 * Internal file info returned by loadEntryFile().
 */
typedef JsonFile = {
    var fileName:String;
    var contents:String;
};

/**
 * Generic base class for any registry in the engine.
 */
@:generic
abstract class BaseRegistry<T:(IRegistryEntry<J> & Constructible<String->Void>), J> {

    final registryId:String;
    final dataFolder:String;
    var fileType:String = ".json";
    var versionRule:VersionRule = VersionRule.fromString(">=1.0.0");

    var entries:Map<String, T> = new Map();
    var scriptedEntries:Map<String, T> = new Map();

    // ---------------------------------------------------------
    // CONSTRUCTOR
    // ---------------------------------------------------------

    public function new(registryId:String, dataFolder:String, ?versionRule:VersionRule, fileType:String = ".json") {
        this.registryId = registryId;
        this.dataFolder = dataFolder;
        if (versionRule != null) this.versionRule = versionRule;
        this.fileType = fileType;

        // Register to console for debugging
        FlxG.console.registerObject(registryId, this);
    }

    // ---------------------------------------------------------
    // LOAD ENTRIES
    // ---------------------------------------------------------

    public function loadEntries():Void {
        clearEntries();

        var scriptedClasses = getScriptedClasses();

        // ---------------------------
        // Load scripted entries
        // ---------------------------
        for (cls in scriptedClasses) {
            var scriptedEntry = createScriptedEntry(cls);
            if (scriptedEntry != null) {
                entries.set(scriptedEntry.id, scriptedEntry);
                scriptedEntries.set(scriptedEntry.id, scriptedEntry);
            } else {
                log('Error while creating scripted entry for class "$cls"');
            }
        }

        // ---------------------------
        // Load unscripted entries
        // ---------------------------
        var entryIds = DataAssets.listAssetsFromPath(dataFolder, fileType);

        var unscriptedEntries = entryIds.filter(function(entry:String) {
            return !entries.exists(entry) || entries.get(entry) == null;
        });

        for (entryId in unscriptedEntries) {
            var entry = createEntry(entryId);
            if (entry != null) {
                entries.set(entry.id, entry);
            } else {
                log('Error creating entry with id "$entryId"');
            }
        }

        log('Parsed ${countEntries()} entries (${scriptedEntries.size()} scripted, ${unscriptedEntries.length} unscripted)');
    }

    // ---------------------------------------------------------
    // CLEAR ENTRIES
    // ---------------------------------------------------------

    public function clearEntries():Void {
        for (key in entries.keys()) {
            var entry = entries.get(key);
            if (entry != null) entry.destroy();
        }
        entries.clear();
    }

    // ---------------------------------------------------------
    // FETCH / LIST / COUNT
    // ---------------------------------------------------------

    public function fetchEntry(id:String):Null<T>
        return entries.get(id);

    public function listEntryIds():Array<String>
        return entries.keys().array();

    public function countEntries():Int
        return entries.size();

    // ---------------------------------------------------------
    // ENTRY CREATION
    // ---------------------------------------------------------

    function createEntry(id:String):Null<T> {
        return new T(id);
    }

    public function hasEntry(id:String):Bool
        return entries.exists(id);

    function isScriptedEntry(id:String):Bool
        return scriptedEntries.exists(id);

    // ---------------------------------------------------------
    // LOGGING & ERROR REPORTING
    // ---------------------------------------------------------

    function log(message:String):Void
        trace('[$registryId] $message');

    public function printErrors(errors:Array<json2object.Error>):Void {
        var errorString = json2object.ErrorUtils.convertErrorArray(errors);
        var msg = 'Error while parsing JSON file\n\n$errorString';

        trace(errorString);
        FlxG.stage.application.window.alert(msg, '[$registryId] JSON Error');
    }

    // ---------------------------------------------------------
    // VERSIONING
    // ---------------------------------------------------------

    public function fetchEntryVersion(id:String):Version {
        var entry = loadEntryFile(id);
        return VersionUtil.getVersionFromJSON(entry.contents);
    }

    function loadEntryFile(id:String):JsonFile {
        var fileName = Paths.json('${dataFolder}/$id');
        var contents = Assets.getText(fileName).trim();
        return {fileName: fileName, contents: contents};
    }

    public function parseEntryDataWithMigration(id:String, ?version:Version):Null<J> {
        if (version == null || VersionUtil.validateVersion(version, versionRule)) {
            return parseEntryData(id);
        } else {
            throw "Migration does not exist for version " + version;
        }
    }

    // ---------------------------------------------------------
    // ABSTRACT METHODS
    // ---------------------------------------------------------

    public abstract function parseEntryData(id:String):J;

    abstract function createScriptedEntry(clsName:String):T;

    abstract function getScriptedClasses():Array<String>;
}
