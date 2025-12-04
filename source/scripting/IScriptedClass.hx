package scripting;

import scripting.events.ScriptEvent;
import scripting.events.UpdateScriptEvent;
import scripting.events.PreferenceScriptEvent;
import scripting.events.StateChangeScriptEvent;
import scripting.events.ConductorScriptEvent;
import scripting.events.CountdownScriptEvent;
import scripting.events.CameraScriptEvent;
import scripting.events.GhostNoteScriptEvent;
import scripting.events.NoteScriptEvent;
import scripting.events.HoldNoteScriptEvent;
import scripting.events.AddPropScriptEvent;
import scripting.events.AddCharacterScriptEvent;
import scripting.events.DialogueScriptEvent;

/**
 * Base dispatcher interface for any class that can fire ScriptEvents.
 */
interface IEventDispatcher {
    public function dispatchEvent(event:ScriptEvent):Void;
}

/**
 * Base scripting interface. All scripted classes must implement these.
 */
interface IScriptedClass {
    public function onScriptEvent(event:ScriptEvent):Void;
    public function onScriptEventPost(event:ScriptEvent):Void;

    public function onCreate(event:ScriptEvent):Void;
    public function onUpdate(event:UpdateScriptEvent):Void;
    public function onDestroy(event:ScriptEvent):Void;

    public function onPreferenceChanged(event:PreferenceScriptEvent):Void;
}

/**
 * Interfaces related to state transitions.
 */
interface IStateChangeScriptedClass extends IScriptedClass {
    public function onStateChange(event:StateChangeScriptEvent):Void;
    public function onStateChangePost(event:StateChangeScriptEvent):Void;

    public function onSubStateOpen(event:StateChangeScriptEvent):Void;
    public function onSubStateOpenPost(event:StateChangeScriptEvent):Void;

    public function onSubStateClose(event:StateChangeScriptEvent):Void;
    public function onSubStateClosePost(event:StateChangeScriptEvent):Void;
}

/**
 * Conductor-synced callbacks.
 */
interface IConductorSyncedScriptedClass extends IScriptedClass {
    public function onStepHit(event:ConductorScriptEvent):Void;
    public function onBeatHit(event:ConductorScriptEvent):Void;
    public function onMeasureHit(event:ConductorScriptEvent):Void;

    public function onTimeChangeHit(event:ConductorScriptEvent):Void;
}

/**
 * Note-based callbacks.
 */
interface INoteScriptedClass extends IScriptedClass {
    public function onNoteSpawn(event:NoteScriptEvent):Void;
    public function onOpponentNoteHit(event:NoteScriptEvent):Void;
    public function onPlayerNoteHit(event:NoteScriptEvent):Void;
    public function onNoteMiss(event:NoteScriptEvent):Void;

    public function onHoldNoteDrop(event:HoldNoteScriptEvent):Void;
}

/**
 * PlayState script functions.
 */
interface IPlayStateScriptedClass
    extends IConductorSyncedScriptedClass
    extends INoteScriptedClass
{
    public function onCreatePost(event:ScriptEvent):Void;
    public function onCreateUI(event:ScriptEvent):Void;

    public function onSongStart(event:ScriptEvent):Void;
    public function onSongLoad(event:ScriptEvent):Void;
    public function onSongEnd(event:ScriptEvent):Void;

    public function onPause(event:ScriptEvent):Void;
    public function onResume(event:ScriptEvent):Void;

    public function onPressSeven(event:ScriptEvent):Void;

    public function onGameOver(event:ScriptEvent):Void;

    public function onCountdownStart(event:CountdownScriptEvent):Void;
    public function onCountdownTick(event:CountdownScriptEvent):Void;
    public function onCountdownTickPost(event:CountdownScriptEvent):Void;
    public function onCountdownFinish(event:CountdownScriptEvent):Void;

    public function onCameraMove(event:CameraScriptEvent):Void;
    public function onCameraMoveSection(event:CameraScriptEvent):Void;

    public function onGhostNoteMiss(event:GhostNoteScriptEvent):Void;
}

/**
 * Stage script functions.
 */
interface IStageScriptedClass extends IScriptedClass {
    public function onAdd(event:AddPropScriptEvent):Void;
    public function onCharacterAdd(event:AddCharacterScriptEvent):Void;
}

/**
 * Dialogue script callbacks.
 */
interface IDialogueScriptedClass extends IScriptedClass {
    public function onDialogueStart(event:DialogueScriptEvent):Void;
    public function onDialogueLine(event:DialogueScriptEvent):Void;
    public function onDialogueLineComplete(event:DialogueScriptEvent):Void;
    public function onDialogueEnd(event:DialogueScriptEvent):Void;
    public function onDialogueSkip(event:DialogueScriptEvent):Void;
}
