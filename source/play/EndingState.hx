package play;

import audio.SoundController;
import data.animation.Animation;
import data.animation.Animation.AnimationData;
import data.language.LanguageManager;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import ui.MusicBeatState;
import ui.menu.story.StoryMenuState;

// ------------------------
// Ending parameters
// ------------------------
typedef EndingStateParams = {
	var week:String;
	var ending:String;
	var ?song:String;
	var ?anims:Array<AnimationData>;
	var ?startAnim:String;
};

// ------------------------
// Ending State
// ------------------------
class EndingState extends MusicBeatState
{
	var lastParams:EndingStateParams;
	var params:EndingStateParams;

	var week:String;
	var ending:String;

	var endingTitleText:String;
	var song:String;

	var endingTitle:FlxText;
	var endingDescription:FlxText;

	public function new(params:EndingStateParams)
	{
		super();

		// fallback to lastParams if null
		if (params == null)
			params = lastParams;

		this.params = params;
		this.lastParams = params;

		this.week    = params.week;
		this.ending  = params.ending ?? "unknown";
		this.song    = params.song   ?? "goodEnding";

		this.endingTitleText = LanguageManager.getTextString('ending_title_${ending}');
	}

	override public function create():Void
	{
		super.create();

		// Play ending theme
		SoundController.playMusic(Paths.music(song), 1, true);

		// Ending visual sprite
		var endingSpr = new FlxSprite();

		if (params.anims != null && params.anims.length > 0)
		{
			for (anim in params.anims)
				Animation.addToSprite(endingSpr, anim);

			if (params.startAnim != null)
				endingSpr.animation.play(params.startAnim);
		}

		add(endingSpr);

		// ------------------------
		// Ending title text
		// ------------------------
		endingTitle = new FlxText(0, 40, FlxG.width, endingTitleText, 32);
		endingTitle.setFormat(null, 32, FlxColor.WHITE, "center");
		add(endingTitle);

		// Ending description
		var descriptionText = LanguageManager.getTextString('ending_desc_${ending}');
		endingDescription = new FlxText(0, 120, FlxG.width, descriptionText, 24);
		endingDescription.setFormat(null, 24, FlxColor.WHITE, "center");
		add(endingDescription);

		// Fade-in
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
	}

	var justTouched:Bool = false;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Mobile: detect simple tap
		justTouched = false;
		for (t in FlxG.touches.list)
			if (t.justPressed)
				justTouched = true;

		// Keyboard or touch → exit ending
		if (controls.ACCEPT || justTouched)
			endIt();
	}

	public function endIt():Void
	{
		FlxG.switchState(new StoryMenuState());
		SoundController.playMusic(Paths.music("freakyMenu"));
	}
}
