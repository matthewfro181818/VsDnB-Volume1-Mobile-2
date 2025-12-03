package flixel.animation;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.util.FlxDestroyUtil;

/**
 * Generates baked rotated copies for fast rotation display.
 */
class FlxPrerotatedAnimation implements IFlxDestroyable
{
	public var angle(default, set):Float = 0;

	var _controller:FlxAnimationController;
	var _sprite:FlxSprite;
	var _bakedAngle:Float;

	public function new(controller:FlxAnimationController, bakedAngle:Float)
	{
		_controller = controller;
		_sprite = controller._sprite;
		_bakedAngle = bakedAngle;
	}

	function set_angle(v:Float):Float
	{
		var snapped = FlxAngle.wrapAngle(v);
		_sprite.angle = snapped - (snapped % _bakedAngle);
		return angle = v;
	}

	public function destroy():Void
	{
		_controller = null;
		_sprite = null;
	}
}
