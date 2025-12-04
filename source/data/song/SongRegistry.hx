package data.song;

import util.VersionUtil;
import data.song.SongData.SongChartData;
import data.song.SongData.SongMetadata;
import data.song.SongData.SongMusicData;
import json2object.JsonParser;
import openfl.utils.Assets;
import play.song.ScriptedSong;
import play.song.Song;
import thx.semver.Version;
import thx.semver.VersionRule;
import Paths;
import data.BaseRegistry;

typedef FileRead = { fileName:String, contents:String };
class SongRegistry extends BaseRegistry<Song, SongMetadata> {
    // ------------------------------------------------------------
    // VERSION CONSTANTS
    // ------------------------------------------------------------

    public static var METADATA_VERSION:Version = Version.fromString("2.0.0");
    public static var METADATA_VERSION_RULE:VersionRule = VersionRule.fromString("2.0.x");

    public static var CHART_DATA_VERSION:Version = Version.fromString("2.0.0");
    public static var CHART_DATA_VERSION_RULE:VersionRule = VersionRule.fromString("2.0.x");

    public static var MUSIC_DATA_VERSION:Version = Version.fromString("1.0.0");
    public static var MUSIC_DATA_VERSION_RULE:VersionRule = VersionRule.fromString("1.0.x");

    // ------------------------------------------------------------
    // SINGLETON
    // ------------------------------------------------------------

    public static var instance(get, never):SongRegistry;
    static var _instance:SongRegistry = null;

    static function get_instance():SongRegistry {
        if (_instance == null)
            _instance = new SongRegistry();
        return _instance;
    }

    // ------------------------------------------------------------
    // CONSTRUCTOR
    // ------------------------------------------------------------

    public function new() {
        super("SongRegistry", "songs", METADATA_VERSION_RULE, "-metadata.json");
    }

    // ------------------------------------------------------------
    // SCRIPTED SONG HANDLING
    // ------------------------------------------------------------

    override function createScriptedEntry(cls:String):Song {
        // Scripted songs must use their ID — not a hardcoded stage name
        return ScriptedSong.init(cls, cls);
    }

    override function getScriptedClasses():Array<String> {
        return ScriptedSong.listScriptClasses();
    }

    // ------------------------------------------------------------
    // METADATA LOADING
    // ------------------------------------------------------------

    override function parseEntryData(id:String):SongMetadata {
        return loadMetadataFile(id);
    }

    public function readMetadataEntryFile(id:String, ?variation:String):FileRead {
        var base = 'songs/$id/$id';
        var path = Paths.json('${base}-metadata${Song.validateVariationPath(variation)}');
        var contents = Assets.getText(path);
        return { fileName: path, contents: contents };
    }

    public function fetchEntryMetadataVersion(id:String, ?variation:String):Version {
        return VersionUtil.getVersionFromJSON(readMetadataEntryFile(id, variation).contents);
    }

    public function loadMetadataFile(id:String, ?variation:String):SongMetadata {
        var parser = new JsonParser<SongMetadata>();
        try parser.ignoreUnknownVariables = true catch (_){}

        var file = readMetadataEntryFile(id, variation);
        parser.fromJson(file.contents, file.fileName);

        if (parser.errors.length > 0)
            printErrors(parser.errors);

        return parser.value;
    }

    // ------------------------------------------------------------
    // CHART DATA LOADING
    // ------------------------------------------------------------

    public function readChartEntryFile(id:String, ?variation:String, ?suffix:String):FileRead {
        var base = 'songs/$id/$id';
        var file = Paths.json('${base}${suffix != null ? "-$suffix" : ""}-chart${Song.validateVariationPath(variation)}');
        var contents = Assets.getText(file).trim();
        return { fileName: file, contents: contents };
    }

    public function loadChartDataFile(id:String, ?variation:String, ?suffix:String):SongChartData {
        var parser = new JsonParser<SongChartData>();
        try parser.ignoreUnknownVariables = true catch (_){}

        var file = readChartEntryFile(id, variation, suffix);
        parser.fromJson(file.contents, file.fileName);

        if (parser.errors.length > 0)
            printErrors(parser.errors);

        return parser.value;
    }

    public function fetchEntryChartDataVersion(id:String, ?variation:String, ?suffix:String):Version {
        return VersionUtil.getVersionFromJSON(readChartEntryFile(id, variation, suffix).contents);
    }

    // ------------------------------------------------------------
    // MUSIC DATA LOADING
    // ------------------------------------------------------------

    public function hasMusicDataFile(id:String, ?variation:String):Bool {
        var file = Paths.json('music/$id${Song.validateVariationPath(variation)}');
        return Assets.exists(file);
    }

    public function readMusicDataFile(id:String, ?variation:String):FileRead {
        var file = Paths.json('music/$id${Song.validateVariationPath(variation)}');
        var contents = Assets.getText(file).trim();
        return { fileName: file, contents: contents };
    }

    public function loadMusicDataFile(id:String, ?variation:String):SongMusicData {
        var parser = new JsonParser<SongMusicData>();
        try parser.ignoreUnknownVariables = true catch (_){}

        var file = readMusicDataFile(id, variation);
        parser.fromJson(file.contents, file.fileName);

        if (parser.errors.length > 0)
            printErrors(parser.errors);

        return parser.value;
    }

    // ------------------------------------------------------------
    // ERROR REPORTING
    // ------------------------------------------------------------
    function printErrors(errors:Array<Dynamic>):Void {
        for (e in errors)
            trace('[SongRegistry JSON ERROR] $e');
    }
}
