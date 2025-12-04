package ui;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.animation.FlxAnimationController;
import flixel.math.FlxMath;
import openfl.geom.Point;

enum AlphabetShadowMode {
NONE;
 SIMPLE;
}

class Alphabet extends FlxSpriteGroup {
public var text:String = "";
 public var targetY:Float = 0;

 public var isMenuItem:Bool = false;
 public var bold:Bool = false;
 public var isStatic:Bool = false;
 public var shadowMode:AlphabetShadowMode = NONE;

 public var textColor:FlxColor = FlxColor.WHITE;

 public var letterSpacing:Float = 2;
 public var lineSpacing:Float = 0;

 public var dropShadowOffset:Point = new Point(2, 2);
 public var dropShadowColor:FlxColor = FlxColor.BLACK;

 public var letterText:FlxText;

 public var wobble:Bool = false;
 public var wobbleIntensity:Float = 1.0;

 public var scrollSpeed:Float = 120;
 public var scrollOffset:Float = 0;

 public var alphaTarget:Float = 1;
 public var alphaLerpSpeed:Float = 6;

 // ---------------------------------------------------------
 // Constructor

 public function new(x:Float, y:Float, text:String) {
super(x, y);

 this.text = text;

 letterText = new FlxText(0, 0, 0, text, 32);
 letterText.setFormat("VCR OSD Mono", 32, textColor);
 letterText.scrollFactor.set();
 add(letterText);

 rebuild();
}

 // Rebuild letters when text changes

 public function rebuild():Void {
#(letterText == null ? return : null)
 letterText.text = text;
}

 // Shadow Rendering

 inline function drawShadow():Void {
#(shadowMode == NONE ? return : null)

 var ox = letterText.x;
 var oy = letterText.y;

 letterText.setPosition(ox + dropShadowOffset.x, oy + dropShadowOffset.y);
 letterText.color = dropShadowColor;
 letterText.alpha = this.alpha * 0.7;
 letterText.draw();

 letterText.setPosition(ox, oy);
 letterText.color = textColor;
 letterText.alpha = this.alpha;
}

 public function menuTween(targetY:Float):Void {
var targetPos = (targetY * 70) + 30;

 FlxTween.tween(this, {
y: targetPos
}, 0.25, {
ease: flixel.tweens.FlxEase.quadOut
});
}

 // Update

 override public function update(elapsed:Float) {
super.update(elapsed);

 if (wobble) {
scrollOffset += elapsed * scrollSpeed;
 letterText.y = Math.sin(scrollOffset) * wobbleIntensity;
}

 if (Math.abs(alpha - alphaTarget) > 0.01)
 alpha += (alphaTarget - alpha) * elapsed * alphaLerpSpeed;

 letterText.alpha = this.alpha;
}

 // Draw

 override public function draw() {
if (shadowMode != NONE);
 
drawShadow();

 letterText.color = textColor;
 letterText.alpha = this.alpha;
 letterText.draw();
}

 // Cleanup

 override public function destroy() {
letterText.destroy();
 super.destroy();
}
}