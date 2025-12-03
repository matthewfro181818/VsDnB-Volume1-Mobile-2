package play.dialogue;

import audio.GameSound;
import data.IRegistryEntry;
import data.dialogue.DialogueData;
import data.dialogue.DialogueRegistry;
import data.dialogue.SpeakerRegistry;
import data.language.LanguageManager;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import scripting.events.ScriptEvent;
import scripting.events.ScriptEventDispatcher;
import scripting.IScriptedClass.IDialogueScriptedClass;
import scripting.IScriptedClass.IEventDispatcher;
import util.TweenUtil;

/**
 * Dialogue State Enum
 */
enum DialogueState
{
    Opening;
    Typing;
    Idle;
    Ending;
}

/**
 * Psych-Engine compatible Dialogue System
 */
class Dialogue extends FlxSpriteGroup
    implements IDialogueScriptedClass
    implements IRegistryEntry<DialogueData>
{
    public final id:String;

    var _data:DialogueData;
    final DEFAULT_DIALOGUE_SOUND:FlxSound = SoundController.load(Paths.sound('dialogue/pixelText'));

    var dialogueMusicPath:Null<String>;

    final boxOffsets:Map<String, FlxPoint> =
    [
        'normal' => FlxPoint.get(0, 0),
        'none'   => FlxPoint.get(0, -51),
    ];

    var dialogueList(get, never):Array<DialogueEntryData>;
    function get_dialogueList():Array<DialogueEntryData>
        return _data?.dialogue ?? [];

    var state:DialogueState = Opening;

    var music:GameSound = null;

    var background:FlxSprite;
    var dialogueBox:FlxSprite;
    var dialogueText:FlxTypeText;
    var speaker:Speaker;

    var outroTween:FlxTween;
    public var onFinish:Void->Void;

    public var isDialogueEnding(get, never):Bool;
    function get_isDialogueEnding():Bool return outroTween != null;

    var currentDialogueLine:Int = 0;

    var currentDialogueEntry(get, never):DialogueEntryData;
    function get_currentDialogueEntry():DialogueEntryData
        return dialogueList[currentDialogueLine];

    var dialogueEntryCount(get, never):Int;
    function get_dialogueEntryCount():Int
        return dialogueList.length - 1;

    public function new(id:String)
    {
        super();
        this.id = id;
        _data = fetchData(id);
    }

    // =============================================================
    // INITIALIZATION
    // =============================================================

    public function onCreate(event:ScriptEvent):Void
    {
        currentDialogueLine = 0;
        dialogueMusicPath = _data.music;

        buildMusic();
        buildBackground();
        createDialogueBox();
        refresh();
    }

    public function onUpdate(event:UpdateScriptEvent):Void
    {
        switch (state)
        {
            case Typing:
                if (FlxG.keys.justPressed.ENTER)
                    advanceDialogue();

            case Idle:
                if (FlxG.keys.justPressed.ENTER)
                    advanceDialogue();

            default:
        }
    }

    public function onDestroy(event:ScriptEvent):Void
    {
        dispatchToChildren(event);

        if (outroTween != null)
        {
            outroTween.cancel();
            outroTween.destroy();
            outroTween = null;
        }

        if (music != null)
        {
            SoundController.remove(music);
            music.stop();
            music = null;
        }

        if (speaker != null)
            killSpeaker();

        if (dialogueBox != null)
        {
            FlxTween.cancelTweensOf(dialogueBox);
            dialogueBox.destroy();
            remove(dialogueBox);
            dialogueBox = null;
        }

        if (background != null)
        {
            FlxTween.cancelTweensOf(background);
            background.destroy();
            remove(background);
            background = null;
        }

        if (dialogueText != null)
        {
            dialogueText.destroy();
            dialogueText = null;
        }

        clear();
    }

    override function kill():Void
    {
        super.kill();
        if (outroTween != null)
        {
            outroTween.cancel();
            outroTween.destroy();
            outroTween = null;
        }
    }

    // =============================================================
    // LAYERS / REFRESH
    // =============================================================

    /**
     * Psych-Engine compatible sorting.
     * No zIndex used. We manually reorder children.
     */
    public function refresh():Void
    {
        // Remove all layers to re-add in proper order
        remove(background, false);
        remove(dialogueBox, false);
        remove(dialogueText, false);
        if (speaker != null) remove(speaker, false);

        // Add in correct render order
        add(background);     // bottom
        add(dialogueBox);
        add(dialogueText);
        if (speaker != null) add(speaker); // top
    }

    // =============================================================
    // MUSIC
    // =============================================================

    function buildMusic():Void
    {
        if (dialogueMusicPath != null)
        {
            music = new GameSound().load(Paths.music(dialogueMusicPath));
            music.looped = true;
            SoundController.add(music);
            startMusicFadeIn();
            music.play();
        }
    }

    function startMusicFadeIn():Void
    {
        if (_data.fadeInTime != null && _data.fadeInTime > 0)
        {
            music.volume = 0;
            FlxTween.tween(music, {volume: 0.8}, _data.fadeInTime);
        }
    }

    function fadeOutMusic():Void
    {
        if (music != null)
        {
            FlxTween.cancelTweensOf(music);
            if (_data.fadeOutTime > 0)
                FlxTween.tween(music, {volume: 0.0}, _data.fadeOutTime);
        }
    }

    public function pauseMusic():Void if (music != null) music.pause();
    public function resumeMusic():Void if (music != null) music.resume();

    // =============================================================
    // BACKGROUND & BOX
    // =============================================================

    function buildBackground():Void
    {
        background = new FlxSprite().makeGraphic(1, 1, 0xFF8A9AF5);
        background.scale.set(FlxG.width * 2, FlxG.height * 2);
        background.scrollFactor.set();
        background.alpha = 0.0;
        add(background);
    }

    function createDialogueBox():Void
    {
        dialogueBox = new FlxSprite(0, 325);
        dialogueBox.frames = Paths.getSparrowAtlas('ui/dialogue/speech_bubble_talking');
        dialogueBox.animation.addByPrefix('normal', 'chatboxnorm', 24);
        dialogueBox.animation.addByPrefix('none', 'chatboxnone', 24);
        dialogueBox.screenCenter(X);
        dialogueBox.alpha = 0.0;
        add(dialogueBox);

        playBoxAnimation('none');
        buildText();
    }

    function playBoxAnimation(anim:String)
    {
        dialogueBox.updateHitbox();
        dialogueBox.animation.play(anim, true);

        var off = boxOffsets.get(anim);
        dialogueBox.offset.set(off.x, off.y);
    }

    // =============================================================
    // TEXT
    // =============================================================

    function buildText():Void
    {
        dialogueText = new FlxTypeText(140, 425, Std.int(FlxG.width * 0.8), "", 32);
        dialogueText.font = Paths.font('comic.ttf');
        dialogueText.color = 0xFF000000;
        dialogueText.antialiasing = true;
        dialogueText.completeCallback = onTypingComplete;
        add(dialogueText);
    }

    function updateDialogueText():Void
    {
        var typingSpeed:Float = currentDialogueEntry.typeSpeed;
        var currentText:String = LanguageManager.getTextString(currentDialogueEntry.text, LanguageManager.currentDialogueList);
        var sounds:Array<FlxSound> = speaker != null ? speaker.dialogueSounds : [cast DEFAULT_DIALOGUE_SOUND];

        if (currentText == '')
        {
            dialogueText.resetText(currentText);
            onTypingComplete();
        }
        else
        {
            dialogueText.sounds = sounds.length == 0 ? null : sounds;
            dialogueText.resetText(currentText);
            dialogueText.start(typingSpeed, true);
        }
    }

    function onTypingComplete():Void
    {
        state = Idle;
    }

    // =============================================================
    // SPEAKER
    // =============================================================

    function updateSpeaker():Void
    {
        var speakerId:String = currentDialogueEntry.speaker;
        var expressionId:Null<String> = currentDialogueEntry.expression;
        var speakingSide:String = currentDialogueEntry.side;

        killSpeaker();

        speaker = SpeakerRegistry.instance.fetchEntry(speakerId);
        if (speaker != null)
        {
            if (speakerId == 'generic')
                return;

            speaker.revive();
            add(speaker);
            refresh();

            switch (speakingSide)
            {
                case 'left':   speaker.setPosition(100, 100);
                case 'middle': speaker.setPosition(dialogueBox.x + dialogueBox.width / 2, 100);
                case 'right':  speaker.setPosition(800, 100);
            }

            if (expressionId != null)
                speaker.switchToExpression(expressionId);

            if (speakingSide == 'middle')
                speaker.x -= speaker.width / 2;

            speaker.x += speaker.globalOffsets[0];
            speaker.y += speaker.globalOffsets[1];
            speaker.x += currentDialogueEntry?.offsets[0] ?? 0;
            speaker.y += currentDialogueEntry?.offsets[1] ?? 0;

            fadeInSpeaker(speakingSide);
            ScriptEventDispatcher.callEvent(speaker, new ScriptEvent(CREATE, false));
        }
    }

    function fadeInSpeaker(side:String)
    {
        var push:Float = switch(side)
        {
            case 'left': -100;
            case 'right': 100;
            default: -50;
        }

        speaker.x += push;
        speaker.alpha = 0;

        FlxTween.cancelTweensOf(speaker);
        FlxTween.tween(speaker, {x: speaker.x - push, alpha: 1}, 0.2);
    }

    function killSpeaker():Void
    {
        if (speaker != null)
        {
            speaker.kill();
            remove(speaker);
            speaker = null;
        }
    }

    // =============================================================
    // DIALOGUE FLOW
    // =============================================================

    function updateDialogueToEntry():Void
    {
        updateDialogueBox();
        updateSpeaker();
        updateDialogueText();

        if (currentDialogueEntry.modifier != null)
            applyModifier(currentDialogueEntry.modifier);
    }

    function updateDialogueBox():Void
    {
        var speakerId:String = currentDialogueEntry.speaker;
        var side:String = currentDialogueEntry.side;

        if (speakerId == 'generic' || side == 'middle')
            playBoxAnimation('none');
        else
        {
            playBoxAnimation('normal');
            dialogueBox.flipX = (side == 'right');
        }
    }

    function beginDialogue():Void
    {
        FlxTween.tween(dialogueBox, {alpha: 1}, 1, {
            onComplete: (t) -> {
                state = Typing;
                updateDialogueToEntry();
            }
        });

        FlxTween.tween(background, {alpha: 0.7}, 4.0);
    }

    public function start():Void
        dispatchEvent(new DialogueScriptEvent(DIALOGUE_START, this, false));

    public function skipDialogue():Void
        dispatchEvent(new DialogueScriptEvent(DIALOGUE_SKIP, this, true));

    function advanceDialogue():Void
    {
        var event:DialogueScriptEvent = switch (state)
        {
            case Typing: new DialogueScriptEvent(DIALOGUE_LINE_COMPLETE, this, true);
            case Idle:   new DialogueScriptEvent(DIALOGUE_LINE, this, true);
            case Ending: new DialogueScriptEvent(DIALOGUE_END, this, false);
            default:     null;
        }

        if (event != null)
            dispatchEvent(event);
    }

    public function onDialogueStart(event:DialogueScriptEvent):Void
    {
        dispatchToChildren(event);
        if (!event.eventCanceled)
            beginDialogue();
    }

    public function onDialogueLine(event:DialogueScriptEvent):Void
    {
        dispatchToChildren(event);

        currentDialogueLine++;
        state = Typing;

        if (currentDialogueLine > dialogueEntryCount)
        {
            state = Ending;
            advanceDialogue();
        }
        else updateDialogueToEntry();
    }

    public function onDialogueLineComplete(event:DialogueScriptEvent):Void
    {
        dispatchToChildren(event);
        if (!event.eventCanceled)
            dialogueText.skip();
    }

    public function onDialogueSkip(event:DialogueScriptEvent):Void
    {
        dispatchToChildren(event);
        if (!event.eventCanceled)
            dispatchEvent(new DialogueScriptEvent(DIALOGUE_END, this, false));
    }

    public function onDialogueEnd(event:DialogueScriptEvent):Void
    {
        dispatchToChildren(event);
        playOutro();
    }

    public function applyModifier(modifier:String) {}

    // =============================================================
    // OUTRO
    // =============================================================

    public function playOutro():Void
    {
        if (isDialogueEnding) return;

        var hasOutro:Bool = (_data.fadeOutTime != null && _data.fadeOutTime > 0);

        if (hasOutro)
        {
            TweenUtil.completeTweensOf(background);
            TweenUtil.completeTweensOf(dialogueBox);
            if (speaker != null) TweenUtil.completeTweensOf(speaker);

            fadeOutMusic();

            outroTween = FlxTween.tween(this, {alpha: 0}, _data.fadeOutTime, {
                onComplete: (t) -> onOutroComplete()
            });
        }
        else
            onOutroComplete();
    }

    function onOutroComplete():Void
    {
        ScriptEventDispatcher.callEvent(this, new ScriptEvent(DESTROY, false));
        if (onFinish != null) onFinish();
    }

    // =============================================================
    // SCRIPT / UTIL
    // =============================================================

    public function dispatchEvent(event:ScriptEvent):Void
    {
        var handler:IEventDispatcher = cast FlxG.state;
        if (handler != null)
            handler.dispatchEvent(event);
    }

    function dispatchToChildren(event:ScriptEvent):Void
    {
        if (speaker != null)
            ScriptEventDispatcher.callEvent(speaker, event);
    }

    public function fetchData(id:String):DialogueData
        return DialogueRegistry.instance.parseEntryDataWithMigration(id);
                    
public function onScriptEvent(event:ScriptEvent):Void
{
    // Relay events to dialogue children
    dispatchToChildren(event);
}

    public function onScriptEventPost(event:ScriptEvent):Void {}
    public function onPreferenceChanged(event:PreferenceScriptEvent):Void {}
}
