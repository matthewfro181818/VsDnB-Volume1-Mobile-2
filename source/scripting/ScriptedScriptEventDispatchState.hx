package scripting;

import scripting.events.ScriptEventDispatcher;
import polymod.hscript.HScriptedClass;

@:hscriptClass
class ScriptedScriptEventDispatchState extends ScriptEventDispatcher implements HScriptedClass
{
	public function new()
	{
		super();
	}
}
