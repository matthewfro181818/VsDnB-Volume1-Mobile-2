package play;

import audio.GameSound;
import audio.SoundController;
import data.language.LanguageManager;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextAlign;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import graphics.GameCamera;
import lime.app.Application;

import play.PlayState;
import play.PlayStatePlaylist;
import ui.Alphabet;
import ui.MusicBeatSubstate;
import ui.menu.settings.SettingsMenu;
import ui.menu.story.StoryMenuState;
import ui.menu.freeplay.FreeplayState;
import ui.menu.MainMenuState;
import ui.select.charSelect.CharacterSelect;
import ui.select.playerSelect.BackseatSelect;
import ui.secret.MathGameState;

typedef PauseOption = {
    var name:String;
    var callback:PauseSubState->Void;
};

class PauseSubState extends MusicBeatSubstate
{
    // ------------------------------------------
    // OPTION LISTS
    // ------------------------------------------

    static final STORY_MODE_OPTIONS:Array<PauseOption> = [
        {name: "Resume",        callback: closeMenu},
        {name: "Restart Song",  callback: restartSong},
        #if debug
        {name: "No Miss Mode",  callback: toggleNoMiss},
        #end
        {name: "Options",       callback: openSettingsMenu},
        {name: "Exit to menu",  callback: returnBackToMenu}
    ];

    static final STORY_MODE_DIALOGUE_OPTIONS:Array<PauseOption> = [
        {name: "Resume",        callback: closeMenu},
        {name: "Skip Dialogue", callback: finishDialogue},
        {name: "Options",       callback: openSettingsMenu},
        {name: "Exit to menu",  callback: returnBackToMenu}
    ];

    static final FREEPLAY_OPTIONS:Array<PauseOption> = [
        {name: "Resume",        callback: closeMenu},
        {name: "Restart Song",  callback: restartSong},
        #if debug
        {name: "No Miss Mode",  callback: toggleNoMiss},
        #end
        {name: "Change Character", callback: changeCharacter},
        {name: "Options",       callback: openSettingsMenu},
        {name: "Exit to menu",  callback: returnBackToMenu}
    ];

    static final NO_SELECT_OPTIONS:Array<PauseOption> = [
        {name: "Resume",        callback: closeMenu},
        {name: "Restart Song",  callback: restartSong},
        #if debug
        {name: "No Miss Mode",  callback: toggleNoMiss},
        #end
        {name: "Options",       callback: openSettingsMenu},
        {name: "Exit to menu",  callback: returnBackToMenu}
    ];

    static final FREEPLAY_PLAYER_SELECT_OPTIONS:Array<PauseOption> = [
        {name: "Resume",        callback: closeMenu},
        {name: "Restart Song",  callback: restartSong},
        #if debug
        {name: "No Miss Mode",  callback: toggleNoMiss},
        #end
        {name: "Change Player", callback: returnToPlayerSelect},
        {name: "Options",       callback: openSettingsMenu},
        {name: "Exit to menu",  callback: returnBackToMenu}
    ];

    // ------------------------------------------

    var menuItems:Array<PauseOption>;
    var bg:FlxBackdrop;
    var grpMenuShit:FlxTypedGroup<Alphabet>;
    var pauseMusic:GameSound;
    var curSelected:Int = 0;

    // ------------------------------------------

    public function new()
    {
        super();

        getPauseOptions();
        buildMusic();
        buildBackground();
        buildPauseUI();
        generatePauseOptions();
        changeSelection();
        setupPauseCamera();
    }

    // ------------------------------------------
    // UPDATE
    // ------------------------------------------

    override function update(elapsed:Float)
    {
        bg.x -= 50 * elapsed;
        bg.y -= 50 * elapsed;

        if (pauseMusic.volume < 0.75)
            pauseMusic.volume += 0.01 * elapsed;

        super.update(elapsed);

        if (controls.UP_P) changeSelection(-1);
        if (controls.DOWN_P) changeSelection(1);
        if (controls.ACCEPT) selectOption();
    }

    // ------------------------------------------

    override function destroy()
    {
        if (pauseMusic != null)
            pauseMusic.destroy();

        FlxG.cameras.remove(camera);
        camera.destroy();
        super.destroy();
    }

    override function close()
    {
        SoundController.remove(pauseMusic);
        super.close();
    }

    // ------------------------------------------
    // SELECTION HANDLING
    // ------------------------------------------

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if (curSelected < 0)
            curSelected = menuItems.length - 1;
        if (curSelected >= menuItems.length)
            curSelected = 0;

        var idx = 0;
        for (item in grpMenuShit.members)
        {
            item.targetY = idx - curSelected;
            item.alpha = (item.targetY == 0 ? 1 : 0.6);
            idx++;
        }

        updateSongPositions();
    }

    function selectOption()
    {
        menuItems[curSelected].callback(this);
    }

    function updateSongPositions()
    {
        for (item in grpMenuShit.members)
            item.menuTween(item.targetY);
    }

    // ------------------------------------------
    // OPTION RESOLUTION
    // ------------------------------------------

    function getPauseOptions()
    {
        if (PlayStatePlaylist.isStoryMode)
        {
            if (PlayState.instance.currentDialogue != null
                && !PlayState.instance.currentDialogue.isDialogueEnding)
            {
                menuItems = STORY_MODE_DIALOGUE_OPTIONS;
            }
            else menuItems = STORY_MODE_OPTIONS;
        }
        else
        {
            var id = PlayState.instance.currentSong.id.toLowerCase();

            if (id == "backseat")
                menuItems = FREEPLAY_PLAYER_SELECT_OPTIONS;
            else
                menuItems = FREEPLAY_OPTIONS;
        }
    }

    // ------------------------------------------
    // MUSIC & UI
    // ------------------------------------------

    function buildMusic()
    {
        pauseMusic = new GameSound(MUSIC).load(Paths.music("breakfast"), true, true);
        pauseMusic.volume = 0;
        pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
        SoundController.add(pauseMusic);
    }

    function buildBackground()
    {
        var back = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        back.setGraphicSize(FlxG.width + 1, FlxG.height + 1);
        back.updateHitbox();
        back.screenCenter();
        back.alpha = 0.0001;
        add(back);
        FlxTween.tween(back, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

        bg = new FlxBackdrop(Paths.image("checkeredBG", "shared"), flixel.util.FlxAxes.XY, 1, 1);
        bg.alpha = 0.0001;
        add(bg);
        FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
    }

    function buildPauseUI()
    {
        var chart = PlayState.instance.currentChart;
        if (chart == null) return function makeText(y:Float, txt:String, size:Int):FlxText
        {
            var t = new FlxText(20, y, 0, txt, size);
            t.scrollFactor.set();
            t.antialiasing = true;
            t.setFormat(Paths.font("comic.ttf"), size, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            t.borderSize = 2.5;
            t.alpha = 0;
            return t;
        }

        var t1 = makeText(15, chart.songName, 32);
        t1.x = FlxG.width - (t1.textField.textWidth + 20);
        add(t1);

        var t2 = makeText(t1.y + 40, LanguageManager.getTextString("pause_composersText") + ": " + chart.songComposers.formatStringList(), 20);
        t2.x = FlxG.width - (t2.textField.textWidth + 50);  
        add(t2);

        var t3 = makeText(t2.y + 28, LanguageManager.getTextString("pause_artistsText") + ": " + chart.songArtists.formatStringList(), 20);
        t3.x = FlxG.width - (t3.textField.textWidth + 70);
        add(t3);

        var t4 = makeText(t3.y + 28, LanguageManager.getTextString("pause_chartersText") + ": " + chart.songCharters.formatStringList(), 20);
        t4.x = FlxG.width - (t4.textField.textWidth + 90);
        add(t4);

        var t5 = makeText(t4.y + 28, LanguageManager.getTextString("pause_codersText") + ": " + chart.songCoders.formatStringList(), 20);
        t5.x = FlxG.width - (t5.textField.textWidth + 110);
        add(t5);

        FlxTween.tween(t1, {alpha: 1, y: t1.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
        FlxTween.tween(t2, {alpha: 1, x: t2.x + 30}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1});
        FlxTween.tween(t3, {alpha: 1, x: t3.x + 40}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.2});
        FlxTween.tween(t4, {alpha: 1, x: t4.x + 50}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.4});
        FlxTween.tween(t5, {alpha: 1, x: t5.x + 60}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.6});
    }

    function generatePauseOptions()
    {
        grpMenuShit = new FlxTypedGroup<Alphabet>();
        add(grpMenuShit);

        for (i in 0...menuItems.length)
        {
            var a = new Alphabet(0, (70 * i) + 30, LanguageManager.getTextString("pause_" + menuItems[i].name));
            a.isMenuItem = true;
            a.targetY = i;
            grpMenuShit.add(a);
        }
    }

    function setupPauseCamera()
    {
        camera = new GameCamera();
        camera.bgColor.alpha = 0;
        FlxG.cameras.add(camera, false);
    }

    // ------------------------------------------
    // CALLBACKS
    // ------------------------------------------

    static function closeMenu(state:PauseSubState):Void
        state.close();

    static function restartSong(state:PauseSubState):Void
    {
        SoundController.music.volume = 0;
        PlayState.instance.vocals.volume = 0;
        PlayState.instance.shakeCam = false;
        PlayState.instance.camZooming = false;
        FlxG.resetState();
    }

    static function toggleNoMiss(state:PauseSubState):Void
        PlayState.instance.noMiss = !PlayState.instance.noMiss;

    static function openSettingsMenu(state:PauseSubState):Void
        state.openSubState(new SettingsMenu());

    static function finishDialogue(state:PauseSubState):Void
    {
        if (PlayState.instance.currentDialogue == null) return PlayState.instance.currentDialogue.skipDialogue();
        state.close();
    }

    static function changeCharacter(state:PauseSubState):Void
        FlxG.switchState(new CharacterSelect({targetSong: PlayState.instance.currentSong}));

    static function returnBackToMenu(state:PauseSubState):Void
    {
        var target =
            PlayStatePlaylist.isStoryMode ? new StoryMenuState() : new FreeplayState();

        doReturn(target);
    }

    static function returnToPlayerSelect(state:PauseSubState):Void
    {
        var id = PlayState.instance.currentSong.id.toLowerCase();
        var next:FlxState =
            switch (id)
            {
                case "backseat": new BackseatSelect();
                default: new MainMenuState();
            };

        doReturn(next);
    }

    static function doReturn(next:FlxState)
    {
        if (MathGameState.failedGame)
            MathGameState.failedGame = false;

        Application.current.window.title = Main.applicationName;

        PlayState.instance.shakeCam = false;
        PlayState.instance.camZooming = false;

        if (!SoundController.music.playing)
            SoundController.playMusic(Paths.music("freakyMenu"));

        FlxG.switchState(next);
    }
}
