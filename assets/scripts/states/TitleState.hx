import funkin.visuals.objects.Alphabet;

Conductor.bpm = CoolVars.data.bpm;

var randomPhrases:String = Paths.getContent('data/introTexts.txt').split('\n');

var phrase:Array<String> = randomPhrases[FlxG.random(0, randomPhrases.length - 1)].split('::');

var introTexts:IntMap = [
    0 => 'Ninjamuffin\nPhantomArcade\nKawaiiSprite\nEvilsk ER',
    2 => 'Present',
    3 => null,
    4 => 'Not Associated With',
    6 => 'Newgrounds',
    7 => null,
    8 => phrase[0],
    10 => phrase[1],
    11 => null,
    12 => 'Friday',
    13 => 'Night',
    14 => 'Funkin\'',
    15 => 'ALE Psych'
];

var texts:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>();
add(texts);

function spawnIntroText(text:String)
{
    if (text == null)
    {
        texts.clear();

        return;
    }

    var objOffset:Float = FlxG.height * 0.225;

    if (texts.members.length >= 1)
    {
        var lastObj:Alphabet = texts.members[texts.members.length - 1];

        objOffset = lastObj.y + lastObj.height + 15;
    }

    var obj:Alphabet = new Alphabet(FlxG.width / 2, objOffset, text);
    texts.add(obj);
    obj.alignment = 'centered';
}

var logo:FlxSprite = new FlxSprite(-130, -100);
logo.frames = Paths.getSparrowAtlas('menus/title/logo');
logo.animation.addByPrefix('idle', 'idle', 24);

var gf:FlxSprite = new FlxSprite(550, 50);
gf.frames = Paths.getSparrowAtlas('menus/title/gf');
gf.animation.addByPrefix('left', 'left', 24);
gf.animation.addByPrefix('right', 'right', 24);

var enter:FlxSprite = new FlxSprite(135, 600);
enter.frames = Paths.getSparrowAtlas('menus/title/enter');
enter.animation.addByPrefix('idle', 'idle', 1);
enter.animation.addByPrefix('press', 'press', 24);
enter.animation.addByPrefix('freeze', 'freeze', 1);
enter.animation.play('idle');
enter.color = FlxColor.CYAN;

FlxTween.tween(enter, {alpha: 0.25}, 1.5, {ease: FlxEase.smoothStepInOut, type: FlxTweenType.PINGPONG});

var finishedIntro:Bool = false;

function finishIntro()
{
    if (finishedIntro)
        return;

    finishedIntro = true;

    texts.clear();
        
    add(logo);

    add(gf);

    add(enter);
}

function onSafeBeatHit(safeBeat:Int)
{
    if (!finishedIntro)
    {
        if (safeBeat >= 16)
        {
            finishIntro();

            if (ClientPrefs.data.flashing)
                camGame.flash(FlxColor.WHITE, 2);
        } else if (introTexts.exists(safeBeat)) {
            spawnIntroText(introTexts.get(safeBeat));
        }
    }
}

function postBeatHit(curBeat:Int)
{
    if (finishedIntro)
    {
        logo.animation.play('idle', true);

        gf.animation.play(curBeat % 2 == 0 ? 'left' : 'right', true);
    }
}

if (FlxG.sound.music == null)
{
    FlxG.sound.playMusic(Paths.music('freakyMenu'));

    onSafeBeatHit(0);
} else {
    finishIntro();
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    Conductor.songPosition = FlxG.sound.music.time;

    if (canSelect)
    {
        if (Controls.ACCEPT)
        {
            if (finishedIntro)
            {
                canSelect = false;

                FlxTween.cancelTweensOf(enter);

                enter.alpha = 1;
                enter.color = FlxColor.WHITE;
                enter.animation.play(ClientPrefs.data.flashing ? 'press' : 'freeze', true);

                FlxG.sound.play(Paths.sound('confirmMenu', true));

                if (ClientPrefs.data.flashing)
                    camGame.flash(FlxColor.WHITE, 1, null, true);

                FlxTimer.wait(1, () -> {
                    CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));
                });
            } else {
                finishIntro();

                camGame.flash(FlxColor.BLACK, 0.5);
            }
        }
    }
}

MobileAPI.createButtons(FlxG.width - 100, FlxG.height - 100, [{label: 'A', keys: ClientPrefs.controls.ui.accept}]);