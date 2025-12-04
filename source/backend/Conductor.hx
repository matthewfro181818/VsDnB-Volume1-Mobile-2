package backend;

import data.song.SongData.SongMusicData;
import data.song.SongData.SongTimeChange;
import data.song.SongRegistry;
import flixel.FlxG;
import flixel.util.FlxSignal;
import util.SortUtil;
import play.save.Preferences;

/**
 * Core musical timing system.
 * Supports BPM changes, time signatures, and step/beat/measure events.
 */
class Conductor
{
    // ---------------------------------------------------------
    // STATIC INSTANCE
    // ---------------------------------------------------------

    private static var _instance:Conductor;

    public static var instance(get, never):Conductor;
    static function get_instance():Conductor {
        if (_instance == null)
            _instance = new Conductor();
        return _instance;
    }

    // ---------------------------------------------------------
    // CONSTANTS
    // ---------------------------------------------------------

    public static inline var STEP_VALUE:Int = 16;
    static inline var DEFAULT_BPM:Float = 100.0;

    static inline var SAFE_FRAMES:Int = 10;
    public var safeZoneOffset:Float = (SAFE_FRAMES / 60) * 1000;

    // ---------------------------------------------------------
    // INSTANCE FIELDS
    // ---------------------------------------------------------

    public var songPosition:Float = 0;
    public var offsets:Float = 0;

    public var currentTimeChange(default, null):SongTimeChange;
    public var timeChangeMap:Array<SongTimeChange> = [];

    public var curStep(default, null):Int = 0;
    public var curBeat(default, null):Int = 0;
    public var curMeasure(default, null):Int = 0;

    public var offset:Float = 0;

    private static var newStep:Int = 0;

    // ---------------------------------------------------------
    // SIGNALS
    // ---------------------------------------------------------

    public var onStepHit = new FlxTypedSignal<Int->Void>();
    public var onBeatHit = new FlxTypedSignal<Int->Void>();
    public var onMeasureHit = new FlxTypedSignal<Int->Void>();
    public var onTimeChangeHit = new FlxTypedSignal<SongTimeChange->Void>();

    // ---------------------------------------------------------
    // GETTERS
    // ---------------------------------------------------------

    public var startingBpm(get, never):Float;
    function get_startingBpm():Float {
        return timeChangeMap.length > 0 ? timeChangeMap[0].bpm : DEFAULT_BPM;
    }

    public var bpm(get, never):Float;
    function get_bpm():Float {
        return currentTimeChange != null ? currentTimeChange.bpm : DEFAULT_BPM;
    }

    public var stepCrochet(get, never):Float;
    function get_stepCrochet():Float {
        return stepCrochetOf(bpm, currentTimeChange.numerator, currentTimeChange.denominator);
    }

    public var crochet(get, never):Float;
    function get_crochet():Float {
        return crochetOf(bpm, currentTimeChange.numerator, currentTimeChange.denominator);
    }

    public var measureLength(get, never):Float;
    function get_measureLength():Float {
        return measureLengthOf(bpm, currentTimeChange.numerator, currentTimeChange.denominator);
    }

    // ---------------------------------------------------------
    // CONSTRUCTOR
    // ---------------------------------------------------------

    public function new() {}

    // ---------------------------------------------------------
    // INITIALIZATION
    // ---------------------------------------------------------

    public function initialize(bpm:Float, numerator:Int = 4, denominator:Int = 4):Void
    {
        var tc = new SongTimeChange(0, bpm, numerator, denominator);
        mapTimeChanges([tc]);
        reset();
    }

    // ---------------------------------------------------------
    // RESET
    // ---------------------------------------------------------

    public function reset():Void {
        update(0, false);
    }

    // ---------------------------------------------------------
    // UPDATE LOOP
    // ---------------------------------------------------------

    public function update(?songPos:Float, canDispatch:Bool = true, applyOffsets:Bool = true):Void
    {
        var music = SoundController.music;

        var currentTime = music != null ? music.time : 0.0;
        var currentLength = music != null ? music.length : 0.0;

        if (songPos == null)
            songPos = Math.min(currentLength, currentTime);

        if (applyOffsets)
            songPos += offsets;

        songPosition = songPos;

        if (timeChangeMap.length == 0)
            return var newTC = getTimeChangeAt(songPosition);

        if (currentTimeChange != newTC)
        {
            currentTimeChange = newTC;
            if (canDispatch)
                onTimeChangeHit.dispatch(currentTimeChange);
        }

        updateStepsInfo(songPos, canDispatch);
    }

    // ---------------------------------------------------------
    // TIME CHANGE SYSTEM
    // ---------------------------------------------------------

    public function mapTimeChanges(list:Array<SongTimeChange>):Void
    {
        if (list == null || list.length == 0)
            return timeChangeMap = [];
        list.sort(SortUtil.sortTimeChanges);

        for (i in 0...list.length)
        {
            var tc = list[i];

            if (i == 0)
            {
                tc.stepTime = tc.time / stepCrochetOf(tc.bpm, tc.numerator, tc.denominator);
                tc.beatTime = tc.time / crochetOf(tc.bpm, tc.numerator, tc.denominator);
                tc.measureTime = tc.time / measureLengthOf(tc.bpm, tc.numerator, tc.denominator);
            }
            else
            {
                var prev = list[i - 1];

                var sc = stepCrochetOf(prev.bpm, prev.numerator, prev.denominator);
                var bc = crochetOf(prev.bpm, prev.numerator, prev.denominator);
                var mc = measureLengthOf(prev.bpm, prev.numerator, prev.denominator);

                var dt = tc.time - prev.time;

                tc.stepTime = prev.stepTime + (dt / sc);
                tc.beatTime = prev.beatTime + (dt / bc);
                tc.measureTime = prev.measureTime + (dt / mc);
            }

            timeChangeMap.push(tc);
        }
    }

    public function getTimeChangeAt(position:Float):SongTimeChange
    {
        var found = timeChangeMap[0];

        for (tc in timeChangeMap)
        {
            if (tc.time <= position)
                found = tc;
            else
                break;
        }

        return found;
    }

    // ---------------------------------------------------------
    // STEP/BEAT/MESSAGE UPDATER
    // ---------------------------------------------------------

    private function updateStepsInfo(position:Float, canDispatch:Bool):Void
    {
        var delta = position - currentTimeChange.time;

        var oldStep = curStep;
        var oldBeat = curBeat;
        var oldMeasure = curMeasure;

        newStep = Math.floor(currentTimeChange.stepTime + (delta / stepCrochet));

        if (newStep != curStep)
        {
            if (newStep > curStep)
            {
                while (curStep < newStep)
                {
                    curStep++;
                    curBeat = Math.floor(currentTimeChange.beatTime + (delta / crochet));
                    curMeasure = Math.floor(currentTimeChange.measureTime + (delta / measureLength));

                    if (canDispatch)
                    {
                        onStepHit.dispatch(curStep);

                        if (curBeat != oldBeat)
                            onBeatHit.dispatch(curBeat);

                        if (curMeasure != oldMeasure)
                            onMeasureHit.dispatch(curMeasure);
                    }

                    oldBeat = curBeat;
                    oldMeasure = curMeasure;
                }
            }
            else
            {
                curStep = newStep;
            }
        }
    }

    // ---------------------------------------------------------
    // MUSIC LOADING
    // ---------------------------------------------------------

    public function loadMusicData(id:String, ?variation:String):Void
    {
        if (!SongRegistry.instance.hasMusicDataFile(id, variation))
            return var data = SongRegistry.instance.loadMusicDataFile(id, variation);
        applyMusicData(data);
    }

    public function applyMusicData(data:SongMusicData):Void
    {
        mapTimeChanges(data.timeChanges);
        reset();
    }

    // ---------------------------------------------------------
    // UTILS
    // ---------------------------------------------------------

    public static inline function beatSteps(den:Float):Int
        return Std.int(STEP_VALUE / den);

    public static inline function beatLength(bpm:Float):Float
        return (60 / bpm) * 1000;

    public static inline function stepCrochetOf(bpm:Float, num:Int = 4, den:Int = 4):Float
        return beatLength(bpm) / 4;

    public static inline function crochetOf(bpm:Float, num:Int = 4, den:Int = 4):Float
        return stepCrochetOf(bpm, num, den) * beatSteps(den);

    public static inline function measureLengthOf(bpm:Float, num:Int = 4, den:Int = 4):Float
        return crochetOf(bpm, num, den) * num;
}
