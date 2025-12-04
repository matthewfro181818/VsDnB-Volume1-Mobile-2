package scripting;

import flixel.FlxSubState;
import flixel.addons.ui.FlxUISubState;
import scripting.IScriptedClass.IEventDispatcher;
import scripting.events.ScriptEvent;
import scripting.events.StateChangeScriptEvent;
import scripting.events.ScriptEventType;

/**
 * An `FlxUISubState` that dispatches script events.
 */
class ScriptEventDispatchSubState extends FlxUISubState implements IEventDispatcher
{
	public function new()
	{
		super();
	}

	/** Dispatch event to the current state's dispatcher (automatically overridden in subclasses). */
	public function dispatchEvent(event:ScriptEvent):Void
	{
		// Override this in Scripted subclasses
	}

	// ============================================================
	// OPEN SUBSTATE
	// ============================================================
	override public function openSubState(SubState:FlxSubState):Void
	{
		var event = new StateChangeScriptEvent(
			ScriptEventType.SUBSTATE_OPEN,
			SubState,
			true
		);

		dispatchEvent(event);

		if (event.eventCanceled)
			return super.openSubState(SubState);
		onOpenSubStateComplete(SubState);
	}

	function onOpenSubStateComplete(subState:FlxSubState):Void
	{
		dispatchEvent(
			new StateChangeScriptEvent(
				ScriptEventType.SUBSTATE_OPEN_POST,
				subState,
				false
			)
		);
	}

	// ============================================================
	// CLOSE SUBSTATE
	// ============================================================
	override public function closeSubState():Void
	{
		var event = new StateChangeScriptEvent(
			ScriptEventType.SUBSTATE_CLOSE,
			this.subState,
			true
		);

		dispatchEvent(event);

		if (event.eventCanceled)
			return var closing = this.subState;
		super.closeSubState();
		onCloseSubStateComplete(closing);
	}

	function onCloseSubStateComplete(subState:FlxSubState):Void
	{
		dispatchEvent(
			new StateChangeScriptEvent(
				ScriptEventType.SUBSTATE_CLOSE_POST,
				subState,
				false
			)
		);
	}
}
