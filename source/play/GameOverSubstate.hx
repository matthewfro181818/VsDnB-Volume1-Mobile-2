package play;

import audio.SoundController;
import backend.Conductor;
import data.song.SongRegistry;
import data.song.SongData.SongMusicData;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.utils.AssetType;

import play.character.Character;
import play.song.Song;
import ui.MusicBeatSubstate;
import ui.debug.AnimationDebug;
import ui.menu.freeplay.FreeplayState;
import ui.menu.story.StoryMenuState;
import util.tools.Preloader;

/**
 * Game Over substate shown when the player dies.
 */
class GameOverSubstate extends MusicBeatSubstate
{
	public static var musicSuffix:String = "";
	public static var deathSuffix:String = "";

	var isEnding:Bool = false;
	var bf:Character;
	var camFollow:FlxObject;

	public function new(x:Float, y:Float, char:Character)
	{
		super();

		// Reset variation values
		reset();

		var deathChar = char.skins.get("deathSkin");
		bf = Character.create(x, y, deathChar, CharacterType.PLAYER);

		// fallback if character has no death animation
		if (bf.animation.getByName("firstDeath") == null)
		{
			bf.destroy();
			bf = Character.create(x, y, "bf-dead", CharacterType.PLAYER);
		}

		bf.isDead = true;
		add(bf);

		// camera follow
		camFollow = new FlxObject(bf.cameraFocusPoint.x, bf.cameraFocusPoint.y, 1, 1);
		add(camFollow);

		FlxG.camera.alpha = 1;
		FlxG.camera.setFilters(null);
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		// Load music data
		var hasMusicDataFile = SongRegistry.instance.hasMusicDataFile("game-over", musicSuffix);
		var musicData:SongMusicData = SongRegistry.instance.loadMusicDataFile("game-over", hasMusicDataFile ? musicSuffix : "");
		musicSuffix = hasMusicDataFile ? musicSuffix : "";

		Conductor.instance.applyMusicData(musicData);

		var gameOverMusic = Paths.music('gameOver/gameOver${Song.validateVariationPath(musicSuffix)}');
		var deathSfx = Paths.sound('death/fnf_loss_sfx' + deathSuffix, "shared");

		// Cache music
		Preloader.cacheSound(Paths.soundPath('gameOver/gameOver${Song.validateVariationPath(musicSuffix)}-', "music/", AssetType.MUSIC));

		// Play death sound
		SoundController.play(deathSfx);

		// Animation flow
		bf.playAnim("firstDeath", true);
		bf.animation.finishCallback = function(anim:String) {
			if (anim == "firstDeath")
			{
				bf.playAnim("deathLoop", true);
				SoundController.playMusic(gameOverMusic);
			}
		}

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
	}

	override function create():Void
	{
		super.create();

		#if mobile
		addVirtualPad(NONE, A_B);
		addVirtualPadCamera();
		#end
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// CONFIRM → Restart level
		if (controls.ACCEPT)
			endSequence();

		// BACK → Return to menu
		if (controls.BACK)
		{
			SoundController.playMusic(Paths.music("freakyMenu"));
			Conductor.instance.loadMusicData("freakyMenu");

			Application.current.window.title = Main.applicationName;

			if (PlayStatePlaylist.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		// Animation debugger
		if (FlxG.keys.justPressed.SEVEN)
			FlxG.switchState(new AnimationDebug(bf));

		Conductor.instance.update();
	}

	override function destroy():Void
	{
		// Unload cached audio
		Preloader.removeCachedSound(Paths.soundPath('gameOver/gameOver${Song.validateVariationPath(musicSuffix)}', "music/", MUSIC));
		Preloader.removeCachedSound(Paths.soundPath('gameOver/gameOver${Song.validateVariationPath(musicSuffix)}-', "music/", MUSIC));
		Preloader.removeCachedSound(Paths.soundPath('death/fnf_loss_sfx' + deathSuffix));

		reset();
		super.destroy();
	}

	public override function dispatchEvent(event:ScriptEvent):Void
	{
		super.dispatchEvent(event);

		if (bf != null)
			ScriptEventDispatcher.callEvent(bf, event);
	}

	/**
	 * Confirm death → fade out → restart
	 */
	function endSequence():Void
	{
		if (isEnding) return isEnding = true;
		bf.playAnim("deathConfirm", true);

		SoundController.music.stop();
		SoundController.play(Paths.music('gameOver/gameOver${Song.validateVariationPath(musicSuffix)}-'));

		new FlxTimer().start(0.7, _ -> {
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
				LoadingState.loadPlayState(PlayState.lastParams, true);
			});
		});
	}

	/**
	 * Reset static suffixes
	 */
	public static function reset():Void
	{
		musicSuffix = "";
		deathSuffix = "";
	}
}
