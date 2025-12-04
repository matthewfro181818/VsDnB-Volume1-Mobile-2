package play.song;

import data.song.SongRegistry;
import data.IRegistryEntry;
import flixel.FlxG;

import data.song.SongData.SongSection;
import data.song.SongData.SongTimeChange;
import data.song.SongData.SongMetadata;
import data.song.SongData.SongChartData;

import scripting.IScriptedClass.IPlayStateScriptedClass;
import scripting.events.ScriptEvent;

import util.tools.Preloader;

/**
 * Holds all metadata and playable chart information for a song.
 */
class Song implements IRegistryEntry<SongMetadata> implements IPlayStateScriptedClass
{
    public static final DEFAULT_VARIATION:String = "default";

    /** The song ID */
    public final id:String;

    /** Default (base) metadata */
    var _data:SongMetadata;

    /** Metadata for each variation */
    var _metadata:Map<String, SongMetadata> = new Map();

    /** Charts for each variation */
    var charts:Map<String, SongPlayChart> = new Map();

    /** Whether scores are allowed to save */
    public var validScore:Bool = true;

    // ---------------------------------------------------------
    // PROPERTIES
    // ---------------------------------------------------------

    public var songName(get, never):String;
    function get_songName():String
    {
        if (_data == null || _data.songName == null)
            return "Unknown Name";
        return _data.songName;
    }

    public var songComposers(get, never):Array<String>;
    function get_songComposers():Array<String>
    {
        return (_data != null && _data.composers != null)
            ? _data.composers
            : ["Unknown Composers"];
    }

    public var songArtists(get, never):Array<String>;
    function get_songArtists():Array<String>
    {
        return (_data != null && _data.artists != null)
            ? _data.artists
            : ["Unknown Artists"];
    }

    public var songCharters(get, never):Array<String>;
    function get_songCharters():Array<String>
    {
        return (_data != null && _data.charters != null)
            ? _data.charters
            : ["Unknown Charters"];
    }

    public var songCoders(get, never):Array<String>;
    function get_songCoders():Array<String>
    {
        return (_data != null && _data.coders != null)
            ? _data.coders
            : ["Unknown Coders"];
    }

    // ---------------------------------------------------------
    // CONSTRUCTOR
    // ---------------------------------------------------------

    public function new(id:String)
    {
        this.id = id;

        _data = fetchData(id);
        if (_data == null)
            throw 'No Song data found for id "$id".';

        _metadata.set(DEFAULT_VARIATION, _data);

        // Load variations
        if (_data.variations != null)
        {
            for (variation in _data.variations)
            {
                var variationData = SongRegistry.instance.loadMetadataFile(id, variation);
                if (variationData != null)
                    _metadata.set(variation, variationData);
                else
                    FlxG.log.warn('Failed parsing metadata for variation "$variation"');
            }
        }

        populateMetadataCharts();
    }

    // ---------------------------------------------------------
    // FETCH METADATA
    // ---------------------------------------------------------

    public function fetchData(id:String):SongMetadata
    {
        return SongRegistry.instance.parseEntryData(id);
    }

    // ---------------------------------------------------------
    // CHART RETRIEVAL
    // ---------------------------------------------------------

    public function getChart(?variationId:String):SongPlayChart
    {
        var key = (variationId == null ? DEFAULT_VARIATION : variationId);

        if (charts.exists(key))
            return charts.get(key);

        return charts.exists(DEFAULT_VARIATION)
            ? charts.get(DEFAULT_VARIATION)
            : null;
    }

    public function hasChart(?variationId:String):Bool
    {
        var key = (variationId == null ? DEFAULT_VARIATION : variationId);
        return charts.exists(key);
    }

    // ---------------------------------------------------------
    // BUILD CHARTS
    // ---------------------------------------------------------

    function populateMetadataCharts():Void
    {
        for (variation in _metadata.keys())
        {
            var metadata = _metadata.get(variation);
            if (metadata == null) continue;

            var chartData:SongChartData =
                SongRegistry.instance.loadChartDataFile(id, variation);

            var playChart = new SongPlayChart(this, variation);

            playChart.songName     = metadata.songName;
            playChart.songComposers = metadata.composers;
            playChart.songArtists   = metadata.artists;
            playChart.songCharters  = metadata.charters;
            playChart.songCoders    = metadata.coders;

            playChart.player        = metadata.player;
            playChart.opponent      = metadata.opponent;
            playChart.girlfriend    = metadata.girlfriend;
            playChart.timeChanges   = metadata.timeChanges;
            playChart.stage         = metadata.stage;

            playChart.speed         = chartData.speed;
            playChart.notes         = chartData.notes;
            playChart.validScore    = (variation == DEFAULT_VARIATION);

            charts.set(variation, playChart);
        }
    }

    // ---------------------------------------------------------
    // UTILITIES
    // ---------------------------------------------------------

    public function listVariationIds():Array<String>
    {
        var out = [];
        for (v in _metadata.keys())
            out.push(v);
        return out;
    }

    public static function validateVariationPath(?variation:String):String
    {
        return (variation == null || variation == "" || variation == DEFAULT_VARIATION)
            ? ""
            : '-$variation';
    }

    public static function validateVariation(?variation:String):String
    {
        return (variation == null || variation == "" || variation == DEFAULT_VARIATION)
            ? DEFAULT_VARIATION
            : variation;
    }

    // ---------------------------------------------------------
    // SCRIPT EVENTS (EMPTY STUBS)
    // ---------------------------------------------------------

    public function onScriptEvent(event:ScriptEvent):Void {}
    public function onScriptEventPost(event:ScriptEvent):Void {}
    public function onCreate(event:ScriptEvent):Void {}
    public function onUpdate(event:UpdateScriptEvent):Void {}
    public function onDestroy(event:ScriptEvent):Void {}
    public function onPreferenceChanged(event:PreferenceScriptEvent):Void {}
    public function onStepHit(event:ConductorScriptEvent):Void {}
    public function onBeatHit(event:ConductorScriptEvent):Void {}
    public function onMeasureHit(event:ConductorScriptEvent):Void {}
    public function onTimeChangeHit(event:ConductorScriptEvent):Void {}
    public function onCreatePost(event:ScriptEvent):Void {}
    public function onCreateUI(event:ScriptEvent):Void {}
    public function onSongStart(event:ScriptEvent):Void {}
    public function onSongLoad(event:ScriptEvent):Void {}
    public function onSongEnd(event:ScriptEvent):Void {}
    public function onPause(event:ScriptEvent):Void {}
    public function onResume(event:ScriptEvent):Void {}
    public function onPressSeven(event:ScriptEvent):Void {}
    public function onGameOver(event:ScriptEvent):Void {}
    public function onCountdownStart(event:CountdownScriptEvent):Void {}
    public function onCountdownTick(event:CountdownScriptEvent):Void {}
    public function onCountdownTickPost(event:CountdownScriptEvent):Void {}
    public function onCountdownFinish(event:CountdownScriptEvent):Void {}
    public function onCameraMove(event:CameraScriptEvent):Void {}
    public function onCameraMoveSection(event:CameraScriptEvent):Void {}
    public function onGhostNoteMiss(event:GhostNoteScriptEvent):Void {}
    public function onNoteSpawn(event:NoteScriptEvent):Void {}
    public function onOpponentNoteHit(event:NoteScriptEvent):Void {}
    public function onPlayerNoteHit(event:NoteScriptEvent):Void {}
    public function onNoteMiss(event:NoteScriptEvent):Void {}
    public function onHoldNoteDrop(event:HoldNoteScriptEvent):Void {}
}

/**
 * Stores playable chart data for one variation.
 */
class SongPlayChart
{
    public final song:Song;
    public final variation:String;

    public var songName:String;
    public var songComposers:Array<String>;
    public var songArtists:Array<String>;
    public var songCharters:Array<String>;
    public var songCoders:Array<String>;

    public var stage:String;
    public var player:String;
    public var opponent:String;
    public var girlfriend:String;
    public var timeChanges:Array<SongTimeChange>;

    public var speed:Float;
    public var notes:Array<SongSection>;
    public var validScore:Bool;

    public function new(song:Song, variation:String)
    {
        this.song = song;
        this.variation = variation;
    }

    public function cacheInstrumental():Void
    {
        Preloader.cacheSound(getInstrumentalPath());
    }

    public function cacheVocals():Void
    {
        Preloader.cacheSound(getVoicesPath());
    }

    public function getInstrumentalPath():String
    {
        return Paths.instPath(song.id, variation);
    }

    public function getVoicesPath():String
    {
        return Paths.voicesPath(song.id, variation);
    }
}
