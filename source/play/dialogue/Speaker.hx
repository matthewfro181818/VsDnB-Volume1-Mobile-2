package play.dialogue;

import audio.GameSound;
import audio.SoundController;
import data.IRegistryEntry;
import data.animation.Animation;
import data.dialogue.SpeakerData;
import data.dialogue.SpeakerRegistry;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import scripting.IScriptedClass.IDialogueScriptedClass;
import scripting.events.ScriptEvent;
import scripting.events.ScriptEvent.UpdateScriptEvent;
import scripting.events.ScriptEvent.PreferenceScriptEvent;
import scripting.events.ScriptEvent.DialogueScriptEvent;

/**
 * Dialogue speaker portrait handler.
 */
class Speaker extends FlxSprite implements IDialogueScriptedClass implements IRegistryEntry<SpeakerData>
{
	/** Registry ID for this speaker */
	public final id:String;

	/** Loaded speaker data */
	var _data:SpeakerData;

	/** Speaker name */
	public var speakerName(get, never):String;
	function get_speakerName():String
	{
		return (_data != null && _data.name != null) ? _data.name : "Unknown Speaker";
	}

	/** Global offsets for portrait position */
	public var globalOffsets(get, never):Array<Float>;
	function get_globalOffsets():Array<Float>
	{
		return (_data != null && _data.globalOffsets != null) ? _data.globalOffsets : [0, 0];
	}

	/** Full list of expressions */
	var expressions(get, never):Array<SpeakerExpressionData>;
	function get_expressions():Array<SpeakerExpressionData>
	{
		return (_data != null && _data.expressions != null) ? _data.expressions : [];
	}

	/** Cached dialogue sounds */
	public var dialogueSounds:Array<FlxSound> = [];

	// ======================================================
	// CONSTRUCTOR
	// ======================================================
	public function new(id:String)
	{
		super();
		this.id = id;
		_data = fetchData(id);
	}

	// ======================================================
	// LIFECYCLE
	// ======================================================
	public function onCreate(event:ScriptEvent):Void
	{
		if (dialogueSounds.length == 0 && _data != null && _data.sounds != null && _data.sounds.length > 0)
		{
			populateDialogueSounds();
		}
	}

	override function kill():Void
	{
		clearDialogueSounds();
		super.kill();
	}

	public function onDestroy(event:ScriptEvent):Void
	{
		clearDialogueSounds();
	}

	// ======================================================
	// DIALOGUE SOUNDS
	// ======================================================
	public function populateDialogueSounds():Void
	{
		for (path in _data.sounds)
		{
			var snd = constructDialogueSound(path);
			dialogueSounds.push(snd);
		}
	}

	public function clearDialogueSounds():Void
	{
		for (snd in dialogueSounds)
		{
			if (snd != null)
			{
				SoundController.remove(cast snd);
				snd.stop();
			}
		}
		dialogueSounds = [];
	}

	function constructDialogueSound(path:String):GameSound
	{
		var snd:GameSound = SoundController.load(Paths.sound(path));
		snd.volume = 0.8;
		return snd;
	}

	// ======================================================
	// EXPRESSIONS
	// ======================================================
	public function switchToExpression(expressionId:String):Void
	{
		if (!hasExpression(expressionId))
			return var expressionData = getExpressionData(expressionId);
		var assetPath:String = expressionData.assetPath;

		// Animated expression
		if (expressionData.animation != null)
		{
			this.frames = Paths.getSparrowAtlas('ui/dialogue/portraits/$assetPath');
			Animation.addToSprite(this, expressionData.animation);
			this.animation.play(expressionData.animation.name, true);
		}
		else
		{
			// Static image
			loadGraphic(Paths.image('ui/dialogue/portraits/$assetPath'));
		}

		this.scale.set(expressionData.scale, expressionData.scale);
		this.updateHitbox();
		this.antialiasing = expressionData.antialiasing;

		// Apply basic offsets
		this.x += expressionData.offsets[0];
		this.y += expressionData.offsets[1];

		// Animation offsets if present
		if (expressionData.animation != null)
		{
			this.offset.x += expressionData.animation.offsets[0];
			this.offset.y += expressionData.animation.offsets[1];
		}
	}

	public function hasExpression(name:String):Bool
	{
		return getExpressionData(name) != null;
	}

	function getExpressionData(name:String):SpeakerExpressionData
	{
		for (expr in expressions)
		{
			if (expr.name == name)
				return expr;
		}
		return null;
	}

	// ======================================================
	// REGISTRY
	// ======================================================
	public function fetchData(id:String):SpeakerData
	{
		return SpeakerRegistry.instance.parseEntryDataWithMigration(id);
	}

	// ======================================================
	// SCRIPT INTERFACE
	// ======================================================
	public function onUpdate(event:UpdateScriptEvent):Void {}
	public function onScriptEvent(event:ScriptEvent):Void {}
	public function onScriptEventPost(event:ScriptEvent):Void {}
	public function onPreferenceChanged(event:PreferenceScriptEvent):Void {}

	public function onDialogueStart(event:DialogueScriptEvent):Void {}
	public function onDialogueLine(event:DialogueScriptEvent):Void {}
	public function onDialogueLineComplete(event:DialogueScriptEvent):Void {}
	public function onDialogueEnd(event:DialogueScriptEvent):Void {}
	public function onDialogueSkip(event:DialogueScriptEvent):Void {}
}
