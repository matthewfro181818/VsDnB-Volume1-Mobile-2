// ------------------------------------------------------------
// FULLY MODERNIZED Character.hx — OpenFL 9 / HF 5.7 Compatible
// ------------------------------------------------------------
package play.character;

import backend.Conductor;
import data.IRegistryEntry;
import data.animation.Animation;
import data.character.CharacterData;
import data.character.CharacterRegistry;
import controls.PlayerSettings;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import play.notes.Note;
import scripting.events.ScriptEvent;
import scripting.events.ScriptEventDispatcher;
import scripting.IScriptedClass.IPlayStateScriptedClass;

// ------------------------------------------------------------
// Character Sheet typedef
// ------------------------------------------------------------
typedef CharacterSheet =
{
    var path:String;
    var anims:Array<AnimationData>;
    var ?offsetFile:String;
}

// ------------------------------------------------------------
// Character Types
// ------------------------------------------------------------

enum CharacterType
{
    PLAYER;
    OPPONENT;
    GF;
    OTHER;
}

// ------------------------------------------------------------
// CHARACTER CLASS
// ------------------------------------------------------------

class Character extends FlxSprite implements IRegistryEntry<CharacterData> implements IPlayStateScriptedClass
{
    public final id:String;
    public var _data:CharacterData;

    public var characterName(get, never):String;
    inline function get_characterName() return _data?.name ?? "Unknown";

    public var characterIcon(get, never):String;
    inline function get_characterIcon() return _data?.icon ?? id;

    public var animOffsets:Map<String, Array<Float>> = new Map();
    public var globalOffset:Array<Float> = [];
    public var cameraOffset:Array<Float> = [];
    public var characterColor:FlxColor;

    public var danceSnap:Int = 2;
    public var singDuration:Float = 4;

    public var countdownGraphicType:String = "normal";
    public var countdownSoundType:String = "default";

    public var skins:Map<String, String> = new Map();
    public var sheetsInUse(default, null):Array<CharacterSheet> = [];

    public var characterType:CharacterType = PLAYER;
    public var debugMode:Bool = false;

    public var conductor(get, set):Conductor;
    var _conductor:Conductor;

    inline function get_conductor() return (_conductor == null) ? Conductor.instance : _conductor;
    function set_conductor(value:Conductor)
    {
        removeConductor(conductor);
        setupConductor(value);
        _conductor = value;
        return value;
    }

    public var cameraNoteOffset:FlxPoint = FlxPoint.get();
    public var cameraFocusPoint(default, null):FlxPoint = FlxPoint.get();

    public var isDead:Bool = false;
    public var startsCountdown:Bool = false;

    public var baseScale:Float = 1;
    public var offsetScale:Float = 1.0;
    public var scaleOffset(default, null):FlxPoint = FlxPoint.get();

    public var canDance:Bool = true;
    public var danceTypes:Array<String> = ["idle"];
    public var altDanceSuffix:String = "";
    private var danced:Bool = false;

    public var canSing:Bool = true;
    public var altSingSuffix:String = "";
    public var holdTimer:Float = 0;
    public var nativelyPlayable:Bool;

    // ------------------------------------------------------------
    // Static Creation
    // ------------------------------------------------------------

    public static function create(?x:Float = 0, ?y:Float = 0, id:String, ?characterType:CharacterType = OTHER):Character
    {
        var char = CharacterRegistry.instance.fetchEntry(id);
        char.characterType = characterType;
        char.setPosition(x, y);
        ScriptEventDispatcher.callEvent(char, new ScriptEvent(CREATE, false));
        return char;
    }

    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------

    public function new(id:String)
    {
        super(0, 0);
        this.id = id;
        _data = fetchData(id);

        this.globalOffset = _data.globalOffset;
        this.danceSnap = _data.danceSnap;
        this.singDuration = _data.singDuration;
        this.characterColor = FlxColor.fromString(_data.color);

        this.countdownGraphicType = _data.countdownData.graphicPath;
        this.countdownSoundType = _data.countdownData.soundPath;
        this.antialiasing = _data.antialiasing;

        this.flipX = _data.flipX;
        this.nativelyPlayable = _data.nativelyPlayable;

        skins.set("normal", id);
        skins.set("gfSkin", "gf-none");
        skins.set("noteSkin", "normal");
        skins.set("deathSkin", "generic-death");
    }

    // ------------------------------------------------------------
    // Update
    // ------------------------------------------------------------

    override function update(elapsed:Float)
    {
        if (animation == null || animation.curAnim == null)
            return super.update(elapsed);

        super.update(elapsed);

        if (debugMode || isDead)
            return;

        if (justPressedNote() && characterType == PLAYER)
            holdTimer = 0;

        var shouldStopSinging = (characterType == PLAYER) ? !isHoldingNote() : true;

        if (!isSingAnimation(animation.curAnim.name)
            && !isDanceAnimation(animation.curAnim.name)
            && !animation.curAnim.finished)
        {
            shouldStopSinging = false;
        }

        if (isSinging())
        {
            holdTimer += elapsed;
            var singTimeSteps = (conductor.stepCrochet / 1000) * singDuration;

            if (holdTimer >= singTimeSteps && shouldStopSinging)
            {
                holdTimer = 0;
                dance(true);
            }
        }
        else
            holdTimer = 0;
    }

    override function destroy()
    {
        scaleOffset.put();
        removeConductor(conductor);
        super.destroy();
    }

    // ------------------------------------------------------------
    // Creation Events
    // ------------------------------------------------------------

    public function onCreate(event:ScriptEvent):Void
    {
        animation.onFinish.add(function(anim:String)
        {
            if (hasEase(anim))
            {
                holdTimer = 0;
                dance(true);
            }
        });

        setupConductor(conductor);
        load();

        this.setScale(_data.scale, _data.scale);
        this.baseScale = _data.scale;

        dance(true);
        updateHitbox();
        resetCameraFocusPoint();

        if (characterType == PLAYER)
            this.flipX = !flipX;
    }

    // ------------------------------------------------------------
    // Loading
    // ------------------------------------------------------------

    function load():Void {}

    public function fetchData(id:String):CharacterData
        return CharacterRegistry.instance.fetchData(id);

    // ⭐ MODERN ATLAS LOADING (no addAtlas)
    public function addCharAtlas(path:String, animations:Array<AnimationData>, ?offsetFile:String):Void
    {
        var atlas = FlxAtlasFrames.fromSparrow(path + ".png", path + ".xml");

        if (atlas != null)
        {
            this.frames = atlas;
            if (atlas.frames.length > 0)
                this.frame = atlas.frames[0];
        }

        for (anim in animations)
            Animation.addToSprite(this, anim);

        if (offsetFile != null)
            loadOffsetFile(offsetFile);

        sheetsInUse.push({path: path, anims: animations, offsetFile: offsetFile});
    }

    // ------------------------------------------------------------
    // Dancing
    // ------------------------------------------------------------

    public function dance(force:Bool = false):Void
    {
        if (!canDance || (!force && hasEase() && !animation.curAnim.finished))
            return;

        if (!force && isSinging())
            return;

        cameraNoteOffset.set();

        if (danceTypes.contains("alternate"))
        {
            danced = !danced;
            playAnim(danced ? "danceRight" : "danceLeft", true);
        }
        else
            playAnim("idle", true);
    }

    // ------------------------------------------------------------
    // Singing
    // ------------------------------------------------------------

    public function sing(direction:Int, ?miss:Bool = false, ?alt:String = "", ?singArray:Array<String>)
    {
        if (singArray == null)
            singArray = ["LEFT", "DOWN", "UP", "RIGHT"];

        var noteToPlay = singArray[direction];

        holdTimer = 0;

        if ((characterType == PLAYER && !nativelyPlayable) || (characterType == OPPONENT && nativelyPlayable))
        {
            switch (noteToPlay)
            {
                case "LEFT":  noteToPlay = "RIGHT";
                case "RIGHT": noteToPlay = "LEFT";
            }
        }

        if (miss)
            noteToPlay += "miss";

        playAnim("sing" + noteToPlay + alt, true);
    }

    // ------------------------------------------------------------
    // Play Animation (Modernized)
    // ------------------------------------------------------------

    public function playAnim(animName:String, force:Bool=false, reversed:Bool=false, frame:Int=0):Void
    {
        if (animation == null || animation.getByName(animName) == null
            || (isDanceAnimation(animName) && !canDance)
            || (isSingAnimation(animName) && !canSing))
            return;

        if (isDanceAnimation(animName.toLowerCase()))
            animName += altDanceSuffix;
        else if (isSingAnimation(animName.toLowerCase()))
            animName += altSingSuffix;

        animation.play(animName, force, reversed, frame);

        if (animOffsets.exists(animName))
        {
            var da = animOffsets.get(animName);
            offset.set(
                (da[0] * offsetScale) + scaleOffset.x,
                (da[1] * offsetScale) + scaleOffset.y
            );
        }
        else
            offset.set(scaleOffset.x, scaleOffset.y);
    }


    /**
     * Dispatched when the opponent hits a note.
     * @param event The data associated with this note.
     */
    public function onOpponentNoteHit(event:NoteScriptEvent):Void {}

    /**
     * Dispatched when the player hits a note.
     * @param event The data associated with this note.
     */
    public function onPlayerNoteHit(event:NoteScriptEvent):Void {}
	
    public function onNoteMiss(event:NoteScriptEvent):Void
	{
		if (event.eventCanceled || event.note.character != this)
			return;

		switch (characterType)
		{
			case GF:
				playAnim('sad', true);
			case PLAYER:
				var note:Note = event.note;
				switch (note.noteStyle)
				{
					default:
						this.sing(note.direction, true);
				}
			default:
		}
	}
	
    public function onGhostNoteMiss(event:GhostNoteScriptEvent):Void
	{
		if (event.eventCanceled || event.character != this)
			return;

		switch (characterType)
		{
			case GF:
				playAnim('sad', true);
			case PLAYER:
				this.sing(event.direction, true);
			default:
		}
	}
	
    public function onHoldNoteDrop(event:HoldNoteScriptEvent):Void
	{
		if (event.eventCanceled || event.character != this)
			return;

		switch (characterType)
		{
			case GF:
				playAnim('sad', true);
			case PLAYER:
				this.sing(event.holdNote.direction, true);
			default:
		}
	}
	
	/**
	 * Plays the GF hey based on the player's current combo.
	 * @param combo The current combo the player has.
	 */
	public function playComboAnimation(combo:Int)
	{
		// Play the GF hey animation every 100 combo hits.
		if (combo % 100 == 0 && this.animation.getByName("cheer") != null)
		{
			this.canDance = false;
			this.playAnim('cheer', true);
			this.animation.onFinish.addOnce(function(anim:String) {
				this.canDance = true;
			});
		}
	}

    // ------------------------------------------------------------
    // Easing & Anim Type Helpers
    // ------------------------------------------------------------

    public function hasEase(?anim:String):Bool
    {
        var animToDo = (anim == null) ? (animation?.curAnim?.name ?? "") : anim;

        for (i in danceTypes)
        {
            if (i == "ease" || (i.endsWith("-ease") && (animToDo + "-ease") == i))
                return true;

            var check = isDanceAnimation(animToDo) ? "idle"
                      : isSingAnimation(animToDo)  ? "pose"
                      : "";

            switch (check)
            {
                case "idle": if (i == "idleEase") return true;
                case "pose": if (i == "poseEase") return true;
            }
        }
        return false;
    }

    public inline function isSinging():Bool
        return isSingAnimation(animation?.curAnim?.name ?? "");

    public inline function isSingAnimation(anim:String)
        return anim.startsWith("sing");

    public inline function isDanceAnimation(anim:String)
        return (anim.startsWith("idle") || anim.startsWith("dance"));

    // ------------------------------------------------------------
    // Scale & Position
    // ------------------------------------------------------------

    public function setScale(x:Float, y:Float)
    {
        scale.set(baseScale * x, baseScale * y);

        width  = Math.abs(baseScale * x) * frameWidth;
        height = Math.abs(baseScale * y) * frameHeight;

        scaleOffset.set(
            -0.5 * (width - frameWidth),
            -0.5 * (height - frameHeight)
        );

        resetCameraFocusPoint();
    }

    public function resetCameraFocusPoint():Void
    {
        cameraFocusPoint.x = this.x + (width / 2) + _data.cameraOffsets[0];
        cameraFocusPoint.y = this.y + (height / 2) + _data.cameraOffsets[1];
    }

    public function flip():Void
    {
        this.flipX = !this.flipX;
        this.nativelyPlayable = !this.nativelyPlayable;
    }

    public function reposition():Void
    {
        this.x += globalOffset[0];
        this.y += globalOffset[1];
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
        animOffsets[name] = [x, y];

    function loadOffsetFile(character:String):Void
    {
        if (!Assets.exists(Paths.offsetFile(character), TEXT))
            return;

        var offsetData = Assets.getText(Paths.offsetFile(character)).trim().split("\n");
        for (line in offsetData)
        {
            var parts = line.split(" ");
            addOffset(parts[0], Std.parseFloat(parts[1]), Std.parseFloat(parts[2]));
        }
    }

    // ------------------------------------------------------------
    // Input Helpers
    // ------------------------------------------------------------

    function isHoldingNote():Bool
    {
        return (
            PlayerSettings.controls.LEFT ||
            PlayerSettings.controls.DOWN ||
            PlayerSettings.controls.UP ||
            PlayerSettings.controls.RIGHT
        );
    }

    function justPressedNote():Bool
    {
        return (
            PlayerSettings.controls.LEFT_P ||
            PlayerSettings.controls.DOWN_P ||
            PlayerSettings.controls.UP_P ||
            PlayerSettings.controls.RIGHT_P
        );
    }

    // ------------------------------------------------------------
    // Conductor Hooks
    // ------------------------------------------------------------

    function removeConductor(input:Conductor)
    {
        input.onStepHit.remove(stepHit);
        input.onBeatHit.remove(beatHit);
        input.onMeasureHit.remove(measureHit);
    }

    function setupConductor(input:Conductor)
    {
        input.onStepHit.add(stepHit);
        input.onBeatHit.add(beatHit);
        input.onMeasureHit.add(measureHit);
    }

    function stepHit(step:Int) {}
    function beatHit(beat:Int)
    {
        if (beat % danceSnap == 0 && canDance)
            dance();
    }
    function measureHit(measure:Int) {}

    // ------------------------------------------------------------
    // Position Overrides
    // ------------------------------------------------------------

    override function set_x(value:Float):Float
    {
        var diff = value - this.x;
        cameraFocusPoint.x += diff;
        return super.set_x(value);
    }

    override function set_y(value:Float):Float
    {
        var diff = value - this.y;
        cameraFocusPoint.y += diff;
        return super.set_y(value);
    }

    override function set_flipX(value:Bool):Bool
    {
        animOffsets.clear();
        var flipped = value != getDataFlipX();
        loadOffsetFile(flipped ? _data.offsetFilePlayer : _data.offsetFileOpponent);
        return super.set_flipX(value);
    }

    inline function getDataFlipX():Bool
        return _data?.flipX ?? false;

    // ------------------------------------------------------------
    // Script Events (empty hooks)
    // ------------------------------------------------------------

    public function onScriptEvent(event:ScriptEvent):Void {}
    public function onScriptEventPost(event:ScriptEvent):Void {}
    public function onUpdate(event:UpdateScriptEvent):Void {}
    public function onDestroy(event:ScriptEvent):Void {}
    public function onNoteSpawn(event:NoteScriptEvent):Void {}
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
}
