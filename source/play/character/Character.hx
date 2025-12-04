// ------------------------------------------------------------
// CLEAN & MODERN Character.hx — OpenFL 9 / HaxeFlixel 5.7
// ------------------------------------------------------------
package play.character;

import backend.Conductor;
import controls.PlayerSettings;
import data.IRegistryEntry;
import data.animation.Animation;
import data.character.CharacterData;
import data.character.CharacterRegistry;
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
// TYPES
// ------------------------------------------------------------
typedef CharacterSheet = {
	var path:String;
	var anims:Array<AnimationData>;
	var ?offsetFile:String;
}

enum CharacterType {
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
	inline function get_characterName() return _data != null ? _data.name : "Unknown";

	public var characterIcon(get, never):String;
	inline function get_characterIcon() return _data != null ? _data.icon : id;

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
	private var _conductor:Conductor;

	inline function get_conductor() return _conductor == null ? Conductor.instance : _conductor;
	function set_conductor(v:Conductor) {
		removeConductor(conductor);
		setupConductor(v);
		_conductor = v;
		return v;
	}

	public var cameraNoteOffset:FlxPoint = FlxPoint.get();
	public var cameraFocusPoint(default, null):FlxPoint = FlxPoint.get();

	public var isDead:Bool = false;
	public var startsCountdown:Bool = false;

	public var baseScale:Float = 1;
	public var offsetScale:Float = 1;
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
	// CREATION
	// ------------------------------------------------------------
	public static function create(?x:Float = 0, ?y:Float = 0, id:String, ?ctype:CharacterType = OTHER):Character {
		var char = new Character(id);
		char.characterType = ctype;
		char.setPosition(x, y);
		ScriptEventDispatcher.callEvent(char, new ScriptEvent(ScriptEventType.CREATE, false));
		return char;
	}

	public function new(id:String) {
		super(0, 0);
		this.id = id;

		_data = fetchData(id);
		globalOffset = _data.globalOffset;
		danceSnap = _data.danceSnap;
		singDuration = _data.singDuration;
		characterColor = FlxColor.fromString(_data.color);

		countdownGraphicType = _data.countdownData.graphicPath;
		countdownSoundType = _data.countdownData.soundPath;
		antialiasing = _data.antialiasing;

		flipX = _data.flipX;
		nativelyPlayable = _data.nativelyPlayable;

		skins.set("normal", id);
		skins.set("gfSkin", "gf-none");
		skins.set("noteSkin", "normal");
		skins.set("deathSkin", "generic-death");
	}

	// ------------------------------------------------------------
	// UPDATE
	// ------------------------------------------------------------
	override function update(elapsed:Float) {
		if (animation == null || animation.curAnim == null)
			return super.update(elapsed);

		super.update(elapsed);

		if (debugMode || isDead)
			return;

		// reset hold if fresh press
		if (justPressedNote() && characterType == PLAYER)
			holdTimer = 0;

		var shouldStopSinging = (characterType == PLAYER) ? !isHoldingNote() : true;

		if (!isSingAnimation(animation.curAnim.name)
		&& !isDanceAnimation(animation.curAnim.name)
		&& !animation.curAnim.finished)
			shouldStopSinging = false;

		// singing logic
		if (isSinging()) {
			holdTimer += elapsed;

			var singTimeSteps = (conductor.stepCrochet / 1000) * singDuration;
			if (holdTimer >= singTimeSteps && shouldStopSinging) {
				holdTimer = 0;
				dance(true);
			}
		}
	}

	override function destroy() {
		scaleOffset.put();
		removeConductor(conductor);
		super.destroy();
	}

	// ------------------------------------------------------------
	// ON CREATE
	// ------------------------------------------------------------
	public function onCreate(event:ScriptEvent):Void {
		animation.finishCallback = function(name:String) {
			if (hasEase(name)) {
				holdTimer = 0;
				dance(true);
			}
		}

		setupConductor(conductor);
		load();

		setScale(_data.scale, _data.scale);
		baseScale = _data.scale;

		dance(true);
		updateHitbox();
		resetCameraFocusPoint();

		if (characterType == PLAYER)
			this.flipX = !this.flipX;
	}

	// ------------------------------------------------------------
	// DATA / LOADING
	// ------------------------------------------------------------
	function load():Void {}

	public function fetchData(id:String):CharacterData {
		return CharacterRegistry.instance.fetchData(id);
	}

	public function addCharAtlas(path:String, animations:Array<AnimationData>, ?offsetFile:String):Void {
		var atlas = FlxAtlasFrames.fromSparrow(path + ".png", path + ".xml");
		if (atlas != null) {
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
	// DANCING
	// ------------------------------------------------------------
	public function dance(force:Bool = false):Void {
		if (!canDance) return if (!force && hasEase() && !animation.curAnim.finished) return if (!force && isSinging()) return cameraNoteOffset.set();

		if (danceTypes.contains("alternate")) {
			danced = !danced;
			playAnim(danced ? "danceRight" : "danceLeft", true);
		} else {
			playAnim("idle", true);
		}
	}

	// ------------------------------------------------------------
	// SINGING
	// ------------------------------------------------------------
	public function sing(direction:Int, ?miss:Bool=false, ?alt:String="", ?singArray:Array<String>) {
		if (singArray == null)
			singArray = ["LEFT", "DOWN", "UP", "RIGHT"];

		var noteToPlay = singArray[direction];
		holdTimer = 0;

		if ((characterType == PLAYER && !nativelyPlayable)
		||  (characterType == OPPONENT && nativelyPlayable)) {
			if (noteToPlay == "LEFT") noteToPlay = "RIGHT";
			else if (noteToPlay == "RIGHT") noteToPlay = "LEFT";
		}

		if (miss)
			noteToPlay += "miss";

		playAnim("sing" + noteToPlay + alt, true);
	}

	// ------------------------------------------------------------
	// PLAY ANIMATION
	// ------------------------------------------------------------
	public function playAnim(animName:String, force:Bool=false, reversed:Bool=false, frame:Int=0):Void {
		if (animation == null) return if (animation.getByName(animName) == null) return if (isDanceAnimation(animName) && !canDance) return if (isSingAnimation(animName) && !canSing) return if (isDanceAnimation(animName))
			animName += altDanceSuffix;
		else if (isSingAnimation(animName))
			animName += altSingSuffix;

		animation.play(animName, force, reversed, frame);

		if (animOffsets.exists(animName)) {
			var da = animOffsets.get(animName);
			offset.set((da[0] * offsetScale) + scaleOffset.x, (da[1] * offsetScale) + scaleOffset.y);
		} else {
			offset.set(scaleOffset.x, scaleOffset.y);
		}
	}

	// ------------------------------------------------------------
	// OFFSET LOADING
	// ------------------------------------------------------------
	public function addOffset(name:String, x:Float=0, y:Float=0):Void {
		animOffsets[name] = [x, y];
	}

	function loadOffsetFile(character:String):Void {
		var fp = Paths.offsetFile(character);
		if (!Assets.exists(fp)) return var lines = Assets.getText(fp).trim().split("\n");
		for (line in lines) {
			var parts = line.split(" ");
			addOffset(parts[0], Std.parseFloat(parts[1]), Std.parseFloat(parts[2]));
		}
	}

	// ------------------------------------------------------------
	// CHECKS
	// ------------------------------------------------------------
	public inline function isSinging():Bool
		return isSingAnimation(animation.curAnim.name);

	public inline function isSingAnimation(anim:String):Bool
		return anim.startsWith("sing");

	public inline function isDanceAnimation(anim:String):Bool
		return anim.startsWith("idle") || anim.startsWith("dance");

	public function hasEase(?anim:String):Bool {
		var target = (anim == null) ? (animation != null ? animation.curAnim.name : "") : anim;
		for (i in danceTypes) {
			if (i == "ease" || (i.endsWith("-ease") && target + "-ease" == i))
				return true;
		}
		return false;
	}

	// ------------------------------------------------------------
	// SCALE / POSITION
	// ------------------------------------------------------------
	public function setScale(x:Float, y:Float) {
		scale.set(baseScale * x, baseScale * y);

		width = Math.abs(scale.x) * frameWidth;
		height = Math.abs(scale.y) * frameHeight;

		scaleOffset.set(
			-0.5 * (width - frameWidth),
			-0.5 * (height - frameHeight)
		);

		resetCameraFocusPoint();
	}

	public function resetCameraFocusPoint():Void {
		cameraFocusPoint.x = this.x + (width / 2) + _data.cameraOffsets[0];
		cameraFocusPoint.y = this.y + (height / 2) + _data.cameraOffsets[1];
	}

	public function flip():Void {
		flipX = !flipX;
		nativelyPlayable = !nativelyPlayable;
	}

	public function reposition():Void {
		this.x += globalOffset[0];
		this.y += globalOffset[1];
	}

	override function set_x(v:Float):Float {
		var diff = v - this.x;
		cameraFocusPoint.x += diff;
		return super.set_x(v);
	}

	override function set_y(v:Float):Float {
		var diff = v - this.y;
		cameraFocusPoint.y += diff;
		return super.set_y(v);
	}

	override function set_flipX(v:Bool):Bool {
		animOffsets.clear();

		var flipped = v != getDataFlipX();
		loadOffsetFile(flipped ? _data.offsetFilePlayer : _data.offsetFileOpponent);

		return super.set_flipX(v);
	}

	inline function getDataFlipX():Bool {
		return _data != null ? _data.flipX : false;
	}

	// ------------------------------------------------------------
	// INPUT HELPERS
	// ------------------------------------------------------------
	function isHoldingNote():Bool {
		return (
			PlayerSettings.controls.LEFT ||
			PlayerSettings.controls.DOWN ||
			PlayerSettings.controls.UP ||
			PlayerSettings.controls.RIGHT
		);
	}

	function justPressedNote():Bool {
		return (
			PlayerSettings.controls.LEFT_P ||
			PlayerSettings.controls.DOWN_P ||
			PlayerSettings.controls.UP_P ||
			PlayerSettings.controls.RIGHT_P
		);
	}

	// ------------------------------------------------------------
	// CONDUCTOR HOOKS
	// ------------------------------------------------------------
	function removeConductor(c:Conductor) {
		c.onStepHit.remove(stepHit);
		c.onBeatHit.remove(beatHit);
		c.onMeasureHit.remove(measureHit);
	}

	function setupConductor(c:Conductor) {
		c.onStepHit.add(stepHit);
		c.onBeatHit.add(beatHit);
		c.onMeasureHit.add(measureHit);
	}

	function stepHit(step:Int) {}
	function beatHit(beat:Int) {
		if (beat % danceSnap == 0 && canDance)
			dance();
	}
	function measureHit(measure:Int) {}

	// ------------------------------------------------------------
	// SCRIPTING HOOKS (EMPTY)
	// ------------------------------------------------------------
	public function onScriptEvent(e:ScriptEvent):Void {}
	public function onScriptEventPost(e:ScriptEvent):Void {}
	public function onUpdate(e:Dynamic):Void {}
	public function onDestroy(e:ScriptEvent):Void {}
	public function onNoteSpawn(e:Dynamic):Void {}
	public function onPreferenceChanged(e:Dynamic):Void {}
	public function onStepHit(e:Dynamic):Void {}
	public function onBeatHit(e:Dynamic):Void {}
	public function onMeasureHit(e:Dynamic):Void {}
	public function onTimeChangeHit(e:Dynamic):Void {}
	public function onCreatePost(e:ScriptEvent):Void {}
	public function onCreateUI(e:ScriptEvent):Void {}
	public function onSongStart(e:ScriptEvent):Void {}
	public function onSongLoad(e:ScriptEvent):Void {}
	public function onSongEnd(e:ScriptEvent):Void {}
	public function onPause(e:ScriptEvent):Void {}
	public function onResume(e:ScriptEvent):Void {}
	public function onPressSeven(e:ScriptEvent):Void {}
	public function onGameOver(e:ScriptEvent):Void {}
	public function onCountdownStart(e:Dynamic):Void {}
	public function onCountdownTick(e:Dynamic):Void {}
	public function onCountdownTickPost(e:Dynamic):Void {}
	public function onCountdownFinish(e:Dynamic):Void {}
	public function onCameraMove(e:Dynamic):Void {}
	public function onCameraMoveSection(e:Dynamic):Void {}
}
