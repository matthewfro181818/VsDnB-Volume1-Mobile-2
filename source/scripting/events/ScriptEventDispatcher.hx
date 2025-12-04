package scripting.events;

import scripting.IScriptedClass;
import scripting.IScriptedClass.IConductorSyncedScriptedClass;
import scripting.IScriptedClass.IDialogueScriptedClass;
import scripting.IScriptedClass.INoteScriptedClass;
import scripting.IScriptedClass.IStageScriptedClass;
import scripting.IScriptedClass.IStateChangeScriptedClass;
import scripting.IScriptedClass.IPlayStateScriptedClass;
import scripting.events.ScriptEvent;

/**
 * Dispatches ScriptEvent objects into ScriptedClasses with proper routing.
 */
class ScriptEventDispatcher
{
    public static function callEvent(target:IScriptedClass, event:ScriptEvent):Void
    {
        if (target == null || event == null)
            return;

        // Generic handler
        target.onScriptEvent(event);

        if (!event.shouldPropagate)
            return;

        // ---------------------------------------------------------
        // BASE EVENTS
        // ---------------------------------------------------------
        switch (event.type)
        {
            case CREATE:
                target.onCreate(event);
            case UPDATE:
                target.onUpdate(cast event);
            case DESTROY:
                target.onDestroy(event);
            case PREFERENCE_CHANGE:
                target.onPreferenceChanged(cast event);
            case _:
        }

        // ---------------------------------------------------------
        // STATE CHANGE EVENTS
        // ---------------------------------------------------------
        if (Std.isOfType(target, IStateChangeScriptedClass))
        {
            final eventTarget:IStateChangeScriptedClass = cast target;

            switch (event.type)
            {
                case STATE_CHANGE:
                    eventTarget.onStateChange(cast event);

                case STATE_CHANGE_POST:
                    eventTarget.onStateChangePost(cast event);

                case SUBSTATE_OPEN:
                    eventTarget.onSubStateOpen(cast event);

                case SUBSTATE_OPEN_POST:
                    eventTarget.onSubStateOpenPost(cast event);

                case SUBSTATE_CLOSE:
                    eventTarget.onSubStateClose(cast event);

                case SUBSTATE_CLOSE_POST:
                    eventTarget.onSubStateClosePost(cast event);

                case _:
            }
        }

        // ---------------------------------------------------------
        // CONDUCTOR-SYNCED EVENTS
        // ---------------------------------------------------------
        if (Std.isOfType(target, IConductorSyncedScriptedClass))
        {
            final eventTarget:IConductorSyncedScriptedClass = cast target;

            switch (event.type)
            {
                case STEP_HIT:
                    eventTarget.onStepHit(cast event);

                case BEAT_HIT:
                    eventTarget.onBeatHit(cast event);

                case MEASURE_HIT:
                    eventTarget.onMeasureHit(cast event);

                case TIME_CHANGE_HIT:
                    eventTarget.onTimeChangeHit(cast event);

                case _:
            }
        }

        // ---------------------------------------------------------
        // PLAYSTATE EVENTS
        // ---------------------------------------------------------
        if (Std.isOfType(target, IPlayStateScriptedClass))
        {
            final eventTarget:IPlayStateScriptedClass = cast target;

            switch (event.type)
            {
                case CREATE_POST:
                    eventTarget.onCreatePost(cast event);

                case CREATE_UI:
                    eventTarget.onCreateUI(cast event);

                case SONG_START:
                    eventTarget.onSongStart(cast event);

                case SONG_LOAD:
                    eventTarget.onSongLoad(cast event);

                case SONG_END:
                    eventTarget.onSongEnd(cast event);

                case PAUSE:
                    eventTarget.onPause(cast event);

                case RESUME:
                    eventTarget.onResume(cast event);

                case GAME_OVER:
                    eventTarget.onGameOver(cast event);

                case PRESS_SEVEN:
                    eventTarget.onPressSeven(cast event);

                case COUNTDOWN_START:
                    eventTarget.onCountdownStart(cast event);

                case COUNTDOWN_TICK:
                    eventTarget.onCountdownTick(cast event);

                case COUNTDOWN_TICK_POST:
                    eventTarget.onCountdownTickPost(cast event);

                case COUNTDOWN_END:
                    eventTarget.onCountdownFinish(cast event);

                case CAMERA_MOVE:
                    eventTarget.onCameraMove(cast event);

                case CAMERA_MOVE_SECTION:
                    eventTarget.onCameraMoveSection(cast event);

                case GHOST_NOTE_MISS:
                    eventTarget.onGhostNoteMiss(cast event);

                case _:
            }
        }

        // ---------------------------------------------------------
        // NOTE EVENTS
        // ---------------------------------------------------------
        if (Std.isOfType(target, INoteScriptedClass))
        {
            final eventTarget:INoteScriptedClass = cast target;

            switch (event.type)
            {
                case NOTE_SPAWN:
                    eventTarget.onNoteSpawn(cast event);

                case OPPONENT_NOTE_HIT:
                    eventTarget.onOpponentNoteHit(cast event);

                case PLAYER_NOTE_HIT:
                    eventTarget.onPlayerNoteHit(cast event);

                case NOTE_MISS:
                    eventTarget.onNoteMiss(cast event);

                case NOTE_HOLD_DROP:
                    eventTarget.onHoldNoteDrop(cast event);

                case _:
            }
        }

        // ---------------------------------------------------------
        // STAGE EVENTS
        // ---------------------------------------------------------
        if (Std.isOfType(target, IStageScriptedClass))
        {
            final eventTarget:IStageScriptedClass = cast target;

            switch (event.type)
            {
                case ON_ADD:
                    eventTarget.onAdd(cast event);

                case ON_CHARACTER_ADD:
                    eventTarget.onCharacterAdd(cast event);

                case _:
            }
        }

        // ---------------------------------------------------------
        // DIALOGUE EVENTS
        // ---------------------------------------------------------
        if (Std.isOfType(target, IDialogueScriptedClass))
        {
            final eventTarget:IDialogueScriptedClass = cast target;

            switch (event.type)
            {
                case DIALOGUE_START:
                    eventTarget.onDialogueStart(cast event);

                case DIALOGUE_LINE:
                    eventTarget.onDialogueLine(cast event);

                case DIALOGUE_LINE_COMPLETE:
                    eventTarget.onDialogueLineComplete(cast event);

                case DIALOGUE_END:
                    eventTarget.onDialogueEnd(cast event);

                case DIALOGUE_SKIP:
                    eventTarget.onDialogueSkip(cast event);

                case _:
            }
        }

        // ---------------------------------------------------------
        // Final "post" callback
        // ---------------------------------------------------------
        target.onScriptEventPost(event);
    }
}
