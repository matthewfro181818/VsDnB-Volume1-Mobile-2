package play;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxState;
import lime.app.Future;
import lime.app.Promise;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;
import openfl.utils.Assets;

import ui.MusicBeatState;

import play.PlayState.PlayStateParams;
import play.song.Song;
import audio.SoundController;

// ---------------------------------------

class LoadingState extends MusicBeatState
{
    public static var playStateParams:PlayStateParams;
    inline static var MIN_TIME = 1.0;

    var target:FlxState;
    var stopMusic:Bool = false;
    var callbacks:MultiCallback;

    public function new(target:FlxState, stopMusic:Bool)
    {
        super();
        this.target = target;
        this.stopMusic = stopMusic;
    }

    // Called externally
    public static function loadPlayState(params:PlayStateParams, stopMusic:Bool)
    {
        playStateParams = params;
        loadAndSwitchState(new PlayState(params), stopMusic);
    }

    override function create():Void
    {
        super.create();

        // Load "songs" manifest first
        initSongsManifest().onComplete(function(lib)
        {
            callbacks = new MultiCallback(onLoad);

            var introComplete = callbacks.add("introComplete");

            var targetSongId = playStateParams.targetSong.id ?? "house";
            var targetVar = playStateParams.targetVariation ?? Song.DEFAULT_VARIATION;

            checkLoadSound(getSongPath(targetSongId, targetVar));

            var voicesPath = getVocalPath(targetSongId, targetVar);

            if (Assets.exists(voicesPath))
                checkLoadSound(voicesPath);

            checkLibrary("shared");

            var fade = 0.5;
            FlxG.camera.fade(FlxG.camera.bgColor, fade, true);
            new FlxTimer().start(fade + MIN_TIME, _ -> introComplete());
        });
    }

    // ----------------------------------------------------
    // LOADING HELPERS
    // ----------------------------------------------------

    function checkLoadSound(path:String)
    {
        if (!Assets.cache.hasSound(path))
        {
            var callback = callbacks.add("sound:" + path);
            Assets.loadSound(path).onComplete(_ -> callback());
        }
    }

    function checkLibrary(library:String)
    {
        if (Assets.getLibrary(library) == null)
        {
            var callback = callbacks.add("library:" + library);
            Assets.loadLibrary(library).onComplete(_ -> callback());
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    function onLoad():Void
    {
        if (stopMusic && SoundController.music != null)
            SoundController.music.stop();

        FlxG.switchState(target);
    }

    // ----------------------------------------------------
    // STATIC HELPERS
    // ----------------------------------------------------

    static inline function getSongPath(id:String, variation:String):String
        return Paths.instPath(id, variation);

    static inline function getVocalPath(id:String, variation:String):String
        return Paths.voicesPath(id, variation);

    public static function loadAndSwitchState(target:FlxState, stopMusic:Bool = false):Void
    {
        FlxG.switchState(getNextState(target, stopMusic));
    }

    static function getNextState(target:FlxState, stopMusic:Bool):FlxState
    {
        #if NO_PRELOAD_ALL
        var songId = playStateParams.targetSong.id;
        var variation = playStateParams.targetVariation;

        var instPath = getSongPath(songId, variation);
        var vocals = getVocalPath(songId, variation);

        var hasVoices = Assets.exists(vocals);

        var ready =
            Assets.cache.hasSound(instPath) &&
            (!hasVoices || Assets.cache.hasSound(vocals)) &&
            (Assets.getLibrary("shared") != null);

        if (!ready)
            return new LoadingState(target, stopMusic);

        if (stopMusic && SoundController.music != null)
            SoundController.music.stop();

        return target;

        #else
        return new LoadingState(target, stopMusic);
        #end
    }

    override function destroy():Void
    {
        callbacks = null;
        super.destroy();
    }

    // ----------------------------------------------------
    // SONG MANIFEST LOADER
    // ----------------------------------------------------

    static function initSongsManifest():Future<AssetLibrary>
    {
        var id = "songs";
        var promise = new Promise<AssetLibrary>();

        var lib = LimeAssets.getLibrary(id);

        if (lib != null)
            return Future.withValue(lib);

        var path = id;
        var rootPath:String = null;

        // Get actual location from project manifest
        if (LimeAssets.libraryPaths.exists(id))
        {
            path = LimeAssets.libraryPaths[id];
            rootPath = Path.directory(path);
        }
        else if (StringTools.endsWith(path, ".bundle"))
        {
            rootPath = path;
            path += "/library.json";
        }
        else
        {
            rootPath = Path.directory(path);
        }

        path = LimeAssets.__cacheBreak(path);

        AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
        {
            if (manifest == null)
            {
                promise.error("Cannot parse asset manifest for '" + id + "'");
                return;
            }

            var library = AssetLibrary.fromManifest(manifest);

            if (library == null)
            {
                promise.error("Cannot open library '" + id + "'");
                return;
            }

            LimeAssets.libraries.set(id, library);
            library.onChange.add(LimeAssets.onChange.dispatch);

            promise.complete(library);

        }).onError(_ ->
            promise.error("No asset library with ID '" + id + "'")
        );

        return promise.future;
    }
}

// ----------------------------------------------------
// MULTI CALLBACK
// ----------------------------------------------------

class MultiCallback
{
    public var callback:Void->Void;
    public var logId:String;

    public var length(default,null):Int = 0;
    public var numRemaining(default,null):Int = 0;

    var unfired:Map<String, Void->Void> = [];
    var fired:Array<String> = [];

    public function new(cb:Void->Void, logId:String = null)
    {
        this.callback = cb;
        this.logId = logId;
    }

    public function add(id:String = "untitled"):Void->Void
    {
        id = length + ":" + id;
        length++;
        numRemaining++;

        var func:Void->Void = null;
        func = function()
        {
            if (unfired.exists(id))
            {
                unfired.remove(id);
                fired.push(id);
                numRemaining--;

                if (logId != null)
                    trace('$logId: fired $id, $numRemaining remaining');

                if (numRemaining == 0)
                {
                    if (logId != null)
                        trace('$logId: all callbacks fired');

                    callback();
                }
            }
            else
            {
                if (logId != null)
                    trace('$logId: already fired $id');
            }
        }

        unfired[id] = func;
        return func;
    }

    public function getFired():Array<String>
        return fired.copy();

    public function getUnfired():Array<String>
        return [for (id in unfired.keys()) id];
}
