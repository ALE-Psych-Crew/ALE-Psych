import flixel.util.FlxColor;

import funkin.visuals.objects.Alphabet;

var skippedIntro:Bool = false;

var epicTexts:FlxTypedGroup = new FlxTypedGroup();

var logo:FlxSprite;
var gf:FlxSprite;
var pressEnter:FlxSprite;

Paths.music('freakyMenu');

Paths.sound('confirmMenu');

function onCreate()
{
    WindowsAPI.setWindowBorderColor(33, 33, 33);
    
    add(epicTexts);

    logo = new FlxSprite(-125, -100);
    logo.frames = Paths.getSparrowAtlas('introState/logo');
    logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
    logo.animation.play('bump');
    add(logo);
    logo.antialiasing = ClientPrefs.data.antialiasing;
    logo.alpha = 0;
    
    gf = new FlxSprite(550, 50);
    gf.frames = Paths.getSparrowAtlas('introState/gf');
    gf.animation.addByIndices('danceLeft', 'gf', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    gf.animation.addByIndices('danceRight', 'gf', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
    add(gf);
    gf.antialiasing = ClientPrefs.data.antialiasing;
    gf.alpha = 0;

    pressEnter = new FlxSprite(150, 576);
    pressEnter.frames = Paths.getSparrowAtlas('introState/titleEnter');
    pressEnter.animation.addByPrefix('idle', "idle", 24);
    pressEnter.animation.addByPrefix('press', "press", 24);
    pressEnter.animation.addByPrefix('freeze', "freeze", 24);
    add(pressEnter);
    pressEnter.antialiasing = ClientPrefs.data.antialiasing;
    pressEnter.animation.play('idle');
    pressEnter.centerOffsets();
    pressEnter.updateHitbox();

    pressEnter.alpha = 0;
    pressEnter.color = 0xFF33FFFF;
    
    if (FlxG.sound.music == null)
        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
    else
        skipIntro();
}

function skipIntro()
{
    skippedIntro = true;
    
    epicTexts.clear();

    gf.alpha = 1;
    logo.alpha = 1;
    pressEnter.alpha = 1;
}

var curTime:Float = 0;

var changingState:Bool = false;

var canSelect = true;

function onUpdate(elapsed:Float)
{
    curTime += elapsed;

    if (canSelect && Controls.ACCEPT && !changingState)
    {
        if (skippedIntro)
        {
            pressEnter.animation.play(ClientPrefs.data.flashing ? 'press' : 'freeze');
            
            changingState = true;

            pressEnter.color = FlxColor.WHITE;
            pressEnter.alpha = 1;

            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

            new FlxTimer().start(1.2, function(tmr:FlxTimer)
            {
                CoolUtil.switchState(new CustomState('MainMenuState'));
            });

            canSelect = false;
        } else {
            game.camGame.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : FlxColor.BLACK, ClientPrefs.data.flashing ? 3 : 1);

            skipIntro();
        }
    }

    if (skippedIntro && !changingState)
        pressEnter.alpha = 0.64 + Math.sin(curTime * 2) * 0.36;
}

function changeShit(text:String)
{
    var alphabet:Alphabet = new Alphabet(FlxG.width / 2, epicTexts.members.length >= 1 ? epicTexts.members[epicTexts.members.length - 1].height + epicTexts.members[epicTexts.members.length - 1].y + 15 : 200, text);
    alphabet.scaleX = alphabet.scaleY = 0.8;
    alphabet.alignment = 'centered';
    epicTexts.add(alphabet);
}

var sickBeats:Float = 0;

var randomText:Array<String> = File.getContent(Paths.getPath('introTexts.txt')).split('\n');
randomText = randomText[FlxG.random.int(0, randomText.length - 1)].toUpperCase().split('::');

var phrases:Array<String> = [
    null,
    "NINJAMUFFIN\nPHANTOMARCADE\nKAWAIISPRITE\nEVILSK ER",
    null,
    'PRESENT',
    null,
    'NOT ASSOCIATED WITH',
    null,
    'NEWGROUNDS',
    null,
    randomText[0],
    null,
    randomText[1],
    null,
    'FRIDAY',
    'NIGHT',
    "FUNKIN'",
];

function onBeatHit(curBeat:Int)
{
    if(logo != null)
        logo.animation.play('bump', true);

    if (curBeat % 2 == 0)
        gf.animation.play('danceRight');
    
    if (curBeat % 2 == 1)
        gf.animation.play('danceLeft');

    sickBeats = sickBeats + 1;

    if (!skippedIntro)
    {
        if (sickBeats == 16)
        {
            game.camGame.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : FlxColor.BLACK, ClientPrefs.data.flashing ? 3 : 1);
            
            skipIntro();
        } else if (sickBeats < 16) {
            if (sickBeats % 4 == 0)
                epicTexts.clear();

            if (phrases[sickBeats] != null)
                changeShit(phrases[sickBeats]);
        }
    }
}

var mobileCamera:FlxCamera;

function postCreate()
{
    if (CoolVars.mobileControls)
    {
        mobileCamera = new ALECamera();
        
        FlxG.cameras.add(mobileCamera, false);

        var buttonMap:Array<Dynamic> = [
            [1105, 485, ClientPrefs.controls.ui.accept, 'a uppercase']
        ];

        for (button in buttonMap)
        {
            var obj:MobileButton = new MobileButton(button[0], button[1], button[2], button[3]);
            add(obj);
            obj.label.angle = button[4] ?? 0;
            obj.cameras = [mobileCamera];
        }
    }
}

function onDestroy()
{
    if (CoolVars.mobileControls)
        FlxG.cameras.remove(mobileCamera);
}