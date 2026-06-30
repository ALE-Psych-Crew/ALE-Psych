import funkin.visuals.objects.Alphabet;
import funkin.visuals.objects.Bopper;

using StringTools;

@:typedef JsonTitle = {
    var directory:String;
    
    var logo:JsonSprite;
    var gf:JsonSprite;
    var enter:JsonSprite;

    var enterPressAnimation:String;

    var texts:Dynamic;
    var textsOffset:Float;

    var randomTexts:Array<String>;

    var introDuration:Int;
}

@:typedef TextData = {
    @:optional var text:Null<String>;
    @:optional var offset:Float;
};

final config:JsonTitle = Paths.json('data/menus/title');

var currentTextData(get, never):Null<TextData>;
function get_currentTextData():Null<TextData>
    return Reflect.field(config.texts, Std.string(Conductor.safeBeat));

function getRandomText():String
    return config.randomTexts[FlxG.random.int(0, config.randomTexts.length - 1)].split('::');

var logo:Bopper;
var gf:Bopper;
var enter:Bopper;
var text:Alphabet;

var skippedIntro:Bool = false ?? (Conductor.music != null);

function skipIntro()
{
    if (skippedIntro)
        return;

    skippedIntro = true;

    remove(text, true);

    text.destroy();

    for (obj in [logo, gf, enter])
        obj.exists = true;
}

function onCreate()
{
    final path:String = 'menus/' + config.directory + '/';

    logo = new Bopper();
    logo.fromJson(config.logo, path);

    gf = new Bopper();
    gf.fromJson(config.gf, path);

    enter = new Bopper();
    enter.fromJson(config.enter, path);

    FlxTween.tween(enter, {alpha: 0.25}, 4 * Conductor.secCrochet, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});

    for (spr in [logo, gf, enter])
    {
        spr.configBeatHitAnimations();
        spr.exists = false;
        
        add(spr);
    }

    text = new Alphabet(FlxG.width / 2, config.textsOffset);
    text.alignment = 'centered';
    add(text);

    if (Conductor.music == null)
    {
        Conductor.play(Paths.music('freakyMenu'), CoolVars.meta.bpm, CoolVars.meta.stepsPerBeat, CoolVars.meta.beatsPerSection);

        onSafeBeatHit(0);
    } else {
        skipIntro();
    }
}

var splitRandomText:Array<String> = [];
var randomIndex:Int = 0;

function setText(str:Null<String>)
    text.text = str == '' ? '' : text.text + (text.text == '' ? '' : '\n') + str;

function onSafeBeatHit(curBeat:Int)
{
    if (!skippedIntro)
    {
        if (curBeat == config.introDuration)
        {
            skipIntro();
        
            camGame.flash(FlxColor.WHITE, Conductor.secSectionCrochet);
        } else {
            if (currentTextData != null)
            {
                if (currentTextData.text == null)
                {
                    if (randomIndex % 2 == 0)
                        splitRandomText = getRandomText();

                    setText(splitRandomText[randomIndex++]);
                } else {
                    setText(currentTextData.text);
                }

                text.y = currentTextData.offset ?? config.textsOffset;
            }
        }
    }
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    if (canSelect && Controls.ACCEPT)
    {
        if (skippedIntro)
        {
            canSelect = false;

            FlxTween.cancelTweensOf(enter);

            enter.alpha = 1;

            if (ClientPrefs.data.flashing)
                enter.playAnim(config.enterPressAnimation);

            camGame.flash(FlxColor.WHITE, 1, null, true);

            CoolUtil.playSound('confirm');

            FlxTimer.wait(1, () -> CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState)));
        } else {
            skipIntro();
            
            camGame.flash(FlxColor.BLACK, Conductor.secCrochet);
        }
    }
}