package play.subtitle;

// Has to be imported or else a compile error will happen.
import play.subtitle.ScriptedSubtitle;

import backend.Conductor;
import data.IRegistryEntry;
import data.subtitle.SubtitleData;
import data.subtitle.SubtitleRegistry;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import play.subtitle.Subtitle;
import scripting.events.ScriptEvent;
import scripting.events.ScriptEventDispatcher;
import scripting.IScriptedClass.IPlayStateScriptedClass;

/**
 * A container that stores a list of subtitles for it's specific entry.
 * 
 * Users can further extend this class to customize the way this subtitle container looks in-game.
 */
class SubtitleManager extends FlxSpriteGroup implements IRegistryEntry<SongSubtitleData> implements IPlayStateScriptedClass
{
    /**
     * The id of the entry.
     */
    public final id:String;

    /**
     * The data for this subtitle container.
     */
    var _data:SongSubtitleData;

    /**
     * The scripted class that subtitles are initialized from.
     */
    public var subtitleScriptClass(get, never):Null<String>;
    function get_subtitleScriptClass():Null<String>
    {
        return _data?.scriptClass ?? null;
    }

    /**
     * The sounds used while typing subtitles.
     */
    public var subtitleSounds(get, never):Null<Array<String>>;
    function get_subtitleSounds():Null<Array<String>>
    {
        return _data?.sounds ?? null;
    }

    /**
     * Remaining subtitles to show.
     */
    var songSubtitles:Array<SubtitleData> = [];

    /**
     * The conductor.
     */
    var conductor(get, set):Conductor;
    function get_conductor():Conductor
    {
        if (_conductor == null)
            _conductor = Conductor.instance;
        return _conductor;
    }
    function set_conductor(value:Conductor)
    {
        return _conductor = value;
    }
    var _conductor:Conductor;

    /**
     * Group containing active subtitles.
     */
    var subtitlesGroup:FlxSpriteGroup = new FlxSpriteGroup();

    public function new(id:String)
    {
        super();
        this.id = id;
        _data = fetchData(id);
        add(subtitlesGroup);
    }

    public function onCreate(event:ScriptEvent):Void
    {
        this.revive();

        // Initialize new subtitles
        songSubtitles = getDataSubtitles().copy();

        // Clear anything old
        subtitlesGroup.clear();
    }

    public function onUpdate(event:UpdateScriptEvent):Void
    {
        if (songSubtitles.length > 0)
        {
            if (conductor.songPosition > songSubtitles[0].time * 1000.0)
            {
                var subtitle:SubtitleData = songSubtitles.shift();
                addSubtitle(subtitle);
            }
        }
    }

    public function onDestroy(e:ScriptEvent)
    {
        songSubtitles = [];
        subtitlesGroup.clear();
    }

    /**
     * Flixel 5.x requires (i:Int, sprite:FlxSprite) for forEach-style callbacks.
     */
    public function onScriptEvent(event:ScriptEvent):Void
    {
       this.forEach(function(sprite:FlxSprite)
       {
            sprite.alpha = 1;
       });
    }

    /**
     * Adds a subtitle instance.
     */
    public function addSubtitle(data:SubtitleData)
    {
        var subtitle:Subtitle = null;

        var scriptClass:Null<String> = data.scriptClass ?? subtitleScriptClass ?? null;
        if (scriptClass != null)
        {
            subtitle = ScriptedSubtitle.init(scriptClass, data, this);
        }
        else
        {
            subtitle = new Subtitle(data, this);
        }

        subtitlesGroup.add(subtitle);
        subtitle.startSubtitle();
    }

    /**
     * Called when a subtitle finishes.
     */
    public function onSubtitleComplete(subtitle:Subtitle)
    {
        subtitlesGroup.remove(subtitle);
    }

    function getDataSubtitles():Array<SubtitleData>
    {
        return _data?.subtitles ?? [];
    }

    /**
     * Retrieve registry data.
     */
    public function fetchData(id:String):SongSubtitleData
    {
        return SubtitleRegistry.instance.parseEntryDataWithMigration(id);
    }

    override function destroy():Void
    {
        songSubtitles = [];

        for (sprite in subtitlesGroup)
        {
            subtitlesGroup.remove(sprite);
            sprite.destroy();
        }
        subtitlesGroup.clear();

        super.destroy();
    }

    override function toString():String
    {
        return 'SubtitleManager(id=$id)';
    }

    public function onScriptEventPost(event:ScriptEvent):Void {}
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
