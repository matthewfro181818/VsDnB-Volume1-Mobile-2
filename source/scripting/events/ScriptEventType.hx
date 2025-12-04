package scripting.events;

/**
 * The full list of all script event types used throughout the engine.
 * 
 * Implemented as a string-backed abstract enum to support JSON, modding,
 * and dynamic script calling while still providing type safety.
 */
@:enum
abstract ScriptEventType(String) from String to String
{
    // ---------------------------------------------------------
    // GLOBAL LIFECYCLE EVENTS
    // ---------------------------------------------------------
    var CREATE              = "create";
    var UPDATE              = "update";
    var DESTROY             = "destroy";

    var PREFERENCE_CHANGE   = "preference_change";
    var PRESS_SEVEN         = "press_seven";

    // ---------------------------------------------------------
    // STATE CHANGES (State → Substate → Back)
    // ---------------------------------------------------------
    var STATE_CHANGE        = "state_change";
    var STATE_CHANGE_POST   = "state_change_post";

    var SUBSTATE_OPEN       = "substate_open";
    var SUBSTATE_OPEN_POST  = "substate_open_post";
    var SUBSTATE_CLOSE      = "substate_close";
    var SUBSTATE_CLOSE_POST = "substate_close_post";

    // ---------------------------------------------------------
    // CONDUCTOR / TIMING EVENTS
    // ---------------------------------------------------------
    var STEP_HIT            = "step_hit";
    var BEAT_HIT            = "beat_hit";
    var MEASURE_HIT         = "measure_hit";

    var TIME_CHANGE_HIT     = "time_change_hit";

    // ---------------------------------------------------------
    // PLAYSTATE EVENTS
    // ---------------------------------------------------------
    var CREATE_POST         = "create_post";
    var CREATE_UI           = "create_ui";

    var SONG_START          = "song_start";
    var SONG_LOAD           = "song_load";
    var SONG_END            = "song_end";

    var PAUSE               = "pause";
    var RESUME              = "resume";

    var GAME_OVER           = "game_over";

    var COUNTDOWN_START     = "countdown_start";
    var COUNTDOWN_TICK      = "countdown_tick";
    var COUNTDOWN_TICK_POST = "countdown_tick_post";
    var COUNTDOWN_END       = "countdown_end";

    var CAMERA_MOVE         = "camera_move";
    var CAMERA_MOVE_SECTION = "camera_move_section";

    // ---------------------------------------------------------
    // NOTE EVENTS
    // ---------------------------------------------------------
    var NOTE_SPAWN          = "note_spawn";

    var OPPONENT_NOTE_HIT   = "opponent_note_hit";
    var PLAYER_NOTE_HIT     = "player_note_hit";

    var NOTE_MISS           = "note_miss";
    var NOTE_HOLD_DROP      = "note_hold_drop";
    var GHOST_NOTE_MISS     = "ghost_note_miss";

    // ---------------------------------------------------------
    // STAGE EVENTS
    // ---------------------------------------------------------
    var ON_ADD              = "on_add";
    var ON_CHARACTER_ADD    = "on_character_add";

    // ---------------------------------------------------------
    // DIALOGUE EVENTS
    // ---------------------------------------------------------
    var DIALOGUE_START          = "dialogue_start";
    var DIALOGUE_LINE           = "dialogue_line";
    var DIALOGUE_LINE_COMPLETE  = "dialogue_line_complete";
    var DIALOGUE_END            = "dialogue_end";
    var DIALOGUE_SKIP           = "dialogue_skip";
}
