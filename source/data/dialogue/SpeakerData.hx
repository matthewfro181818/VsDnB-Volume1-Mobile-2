package data.dialogue;

import json2object.JsonWriter;
import data.animation.Animation.AnimationData;

/**
 * Stores data used to define a dialogue speaker.
 */
class SpeakerData
{
	/** The semantic version of this SpeakerData object. */
	public var version:String;

	/** The readable name of this speaker. */
	public var name:String;

	/** Position offsets applied globally when this speaker talks. */
	@:default([0, 0])
	public var globalOffsets:Array<Float>;

	/** A list of sound asset paths to play when the character is talking. */
	public var sounds:Array<String>;

	/** A list of all expressions this character has. */
	@:default([])
	public var expressions:Array<SpeakerExpressionData>;

	public function new() {}

	/** Serializes this SpeakerData into JSON. */
	public function serialize():String
	{
		var writer:JsonWriter<SpeakerData> = new JsonWriter<SpeakerData>();
		writer.ignoreNullOptionals = true;
		return writer.write(this, " ");
	}
}

/**
 * Defines data for a single speaker expression.
 */
typedef SpeakerExpressionData =
{
	/** The name/id of this expression. */
	var name:String;

	/** Asset path for the portrait (no extension). */
	var assetPath:String;

	/** Optional animation data (sparrow or atlas). */
	@:optional
	var ?animation:AnimationData;

	/** How much this expression is scaled. */
	@:default(1)
	var scale:Float;

	/** Whether antialiasing is used. */
	@:default(true)
	@:optional
	var ?antialiasing:Bool;

	/** Custom position offsets for this expression. */
	@:default([0, 0])
	@:optional
	var ?offsets:Array<Float>;
}
