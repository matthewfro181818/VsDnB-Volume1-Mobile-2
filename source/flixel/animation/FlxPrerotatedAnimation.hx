package flixel.animation;

import flixel.FlxSprite;

class FlxPrerotatedAnimation
{
	public var angle:Float = 0;
	public var bakedRotationAngle:Float = 0;

	var controller:FlxAnimationController;

	public function new(controller:FlxAnimationController, bakedRotationAngle:Float)
	{
		this.controller = controller;
		this.bakedRotationAngle = bakedRotationAngle;
	}

	public function destroy():Void {}
}
