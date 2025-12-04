package scripting.events;

import play.dialogue.Dialogue;
import audio.GameSound;
import data.song.SongData.SongTimeChange;

import flixel.FlxState;
import flixel.FlxSprite;

import play.character.Character;
import play.notes.Note;
import play.notes.SustainNote;
import play.ui.Countdown.CountdownStep;
import play.subtitle.Subtitle;

/**
 * A base class that represents for all script events that are dispatched to scripted classes.
 */
class ScriptEvent {
	public var type(default, null):ScriptEventType;
	public var cancelable(default, null):Bool;
	public var eventCanceled(default, null):Bool = false;
	public var shouldPropagate(default, null):Bool = true;

	public function new(type:ScriptEventType, cancelable:Bool = false) {
		this.type = type;
		this.cancelable = cancelable;
	}

	public function cancel():Void {
		if (cancelable) eventCanceled = true;
	}

	public function revive():Void {
		if (cancelable && eventCanceled) eventCanceled = false;
	}

	public function stopPropagation():Void {
		shouldPropagate = false;
	}

	public function resumePropagation():Void {
		shouldPropagate = true;
	}

	public function toString():String {
		return 'ScriptEvent(type=$type, cancelable=$cancelable)';
	}
}

// UPDATE EVENT
class UpdateScriptEvent extends ScriptEvent {
	public var elapsed(default, null):Float;

	public function new(elapsed:Float) {
		super(UPDATE, false);
		this.elapsed = elapsed;
	}

	override function toString():String {
		return 'UpdateScriptEvent(elapsed=$elapsed)';
	}
}

// PREFERENCE EVENT
class PreferenceScriptEvent extends ScriptEvent {
	public var preference(default, null):String;
	public var value(default, null):Any;

	public function new(preference:String, value:Any) {
		super(PREFERENCE_CHANGE, false);
		this.preference = preference;
		this.value = value;
	}

	override function toString():String {
		return 'PreferenceScriptEvent(preference=$preference, value=$value)';
	}
}

// STATE CHANGE EVENT
class StateChangeScriptEvent extends ScriptEvent {
	var targetState(default, null):FlxState;

	public function new(type:ScriptEventType, targetState:FlxState, cancelable:Bool = false) {
		super(type, cancelable);
		this.targetState = targetState;
	}

	override function toString():String {
		return 'StateChangeScriptEvent(type=$type, targetState=$targetState)';
	}
}

// CONDUCTOR EVENT
class ConductorScriptEvent extends ScriptEvent {
	var step(default, null):Int;
	var beat(default, null):Int;
	var measure(default, null):Int;
	var timeChange(default, null):SongTimeChange;

	public function new(type:ScriptEventType, step:Int, beat:Int, measure:Int, timeChange:SongTimeChange, cancelable:Bool = true) {
		super(type, cancelable);
		this.step = step;
		this.beat = beat;
		this.measure = measure;
		this.timeChange = timeChange;
	}

	override function toString():String {
		return 'ConductorScriptEvent(type=$type, step=$step, beat=$beat, measure=$measure, timeChange=$timeChange)';
	}
}

// COUNTDOWN
class CountdownScriptEvent extends ScriptEvent {
	public var step:CountdownStep;

	public function new(type:ScriptEventType, step:CountdownStep, cancelable:Bool = true) {
		super(type, cancelable);
		this.step = step;
	}

	override function toString():String {
		return 'CountdownScriptEvent(type=$type, step=$step)';
	}
}

// CAMERA EVENT
class CameraScriptEvent extends ScriptEvent {
	var isOpponent(default, null):Bool;

	public function new(type:ScriptEventType, isOpponent:Bool, cancelable:Bool = false) {
		super(type, cancelable);
		this.isOpponent = isOpponent;
	}

	override function toString():String {
		return 'CameraScriptEvent(type=$type, isOpponent=$isOpponent)';
	}
}

// NOTE EVENT
class NoteScriptEvent extends ScriptEvent {
	public var note(default, null):Note;
	public var character(default, null):Character;
	public var healthChange:Float;
	public var comboCount(default, null):Int;
	public var missSound:GameSound;

	public function new(type:ScriptEventType, note:Note, character:Character, healthChange:Float, comboCount:Int, missSound:GameSound, cancelable:Bool = true) {
		super(type, cancelable);
		this.note = note;
		this.character = character;
		this.healthChange = healthChange;
		this.comboCount = comboCount;
		this.missSound = missSound;
	}

	override function toString():String {
		return 'NoteScriptEvent(type=$type, note=$note, character=$character, healthChange=$healthChange, comboCount=$comboCount, missSound=$missSound)';
	}
}

// HOLD NOTE
class HoldNoteScriptEvent extends NoteScriptEvent {
	public var holdNote:SustainNote;

	public function new(type:ScriptEventType, holdNote:SustainNote, character:Character, healthChange:Float, combo:Int, missSound:GameSound, cancelable:Bool = true) {
		super(type, null, character, healthChange, combo, missSound, cancelable);
		this.holdNote = holdNote;
	}
}

// GHOST NOTE
class GhostNoteScriptEvent extends NoteScriptEvent {
	public var direction(default, null):Int;

	public function new(direction:Int, character:Character, healthChange:Float, comboCount:Int, missSound:GameSound, cancelable:Bool = true) {
		super(GHOST_NOTE_MISS, null, character, healthChange, comboCount, missSound, cancelable);
		this.direction = direction;
	}

	override function toString():String {
		return 'GhostNoteScriptEvent(direction=$direction)';
	}
}

// STAGE: ADD PROP
class AddPropScriptEvent extends ScriptEvent {
	var prop(default, null):FlxSprite;

	public function new(prop:FlxSprite, cancelable:Bool = true) {
		super(ON_ADD, cancelable);
		this.prop = prop;
	}
}

// STAGE: ADD CHARACTER
class AddCharacterScriptEvent extends ScriptEvent {
	var character(default, null):Character;

	public function new(character:Character, cancelable:Bool = true) {
		super(ON_CHARACTER_ADD, cancelable);
		this.character = character;
	}
}

// SUBTITLE EVENT
class SubtitleScriptEvent extends ScriptEvent {
	var subtitle(default, null):Subtitle;

	public function new(type:ScriptEventType, subtitle:Subtitle, cancelable:Bool = true) {
		super(type, cancelable);
		this.subtitle = subtitle;
	}
}

// DIALOGUE EVENT
class DialogueScriptEvent extends ScriptEvent {
	var dialogue(default, null):Dialogue;

	public function new(type:ScriptEventType, dialogue:Dialogue, cancelable:Bool = true) {
		super(type, cancelable);
		this.dialogue = dialogue;
	}

	override function toString():String {
		return 'DialogueScriptEvent(type=$type, dialogue=$dialogue)';
	}
}
