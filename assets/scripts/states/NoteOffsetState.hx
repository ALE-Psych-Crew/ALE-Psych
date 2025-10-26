FlxG.sound.playMusic(Paths.music('offsetSong'));

var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
add(bg);
bg.color = FlxColor.fromRGB(75, 75, 75);

var textBG:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
add(textBG);
textBG.alpha = 0.5;

var text:FlxText = new FlxText(0, FlxG.height - 100, FlxG.width, '< Offset: ${ClientPrefs.data.noteOffset} ms >', 40);
text.font = Paths.font('vcr.ttf');
text.alignment = 'center';
add(text);

textBG.scale.x = text.width;
textBG.scale.y = text.height + 20;
textBG.updateHitbox();
textBG.y = text.y - 10;

for (obj in [text, textBG])
    obj.cameras = [game.camHUD];

function onBeatHit(curBeat:Int)
{
    if (curBeat % 4 == 0)
    {
        game.camGame.zoom = 1.1;

        bg.color = CoolUtil.colorFromArray(
            [
                for (i in 0...3)
                    75 + FlxG.random.int(-10, 10)
            ]
        );
    }
}

var timer:Float = 0;

var runTimers:Bool = false;
var initTimer:Float = 0;

var isRight:Bool = false;

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    if (canSelect)
    {
        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(new funkin.states.OptionsState(false));

            FlxG.sound.play(Paths.sound('cancelMenu'));
        }
    }

    game.camGame.zoom = CoolUtil.fpsLerp(game.camGame.zoom, 1, 0.1);

    if (Controls.UI_RIGHT_P != Controls.UI_LEFT_P && !runTimers)
    {
        runTimers = true;

        isRight = Controls.UI_RIGHT_P;

        ClientPrefs.data.noteOffset += (isRight ? 1 : -1);
    }

    if ((Controls.UI_RIGHT_R && isRight) || (Controls.UI_LEFT_R && !isRight))
    {
        runTimers = false;

        initTimer = 0;
    }

    if (runTimers)
    {
        if (initTimer < 0.5)
        {
            initTimer += elapsed;
        } else {
            timer += elapsed;
        }

        if (timer >= 0.025)
        {
            timer = 0;

            ClientPrefs.data.noteOffset += (isRight ? 1 : -1);
        }
    }

    ClientPrefs.data.noteOffset = FlxMath.bound(ClientPrefs.data.noteOffset, -500, 500);

    text.text = '< Offset: ${ClientPrefs.data.noteOffset} ms >';
}

var mobileCamera:FlxCamera;

function postCreate()
{
    Conductor.bpm = 128;
    
    if (CoolVars.mobileControls)
    {
        mobileCamera = new ALECamera();
        
        FlxG.cameras.add(mobileCamera, false);

        var buttonMap:Array<Dynamic> = [
            [50, 485, ClientPrefs.controls.ui.left, '< normal'],
            [200, 485, ClientPrefs.controls.ui.right, '> normal'],
            [FlxG.width - 175, 485, ClientPrefs.controls.ui.back, 'b uppercase'],
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

    CoolUtil.save.savePreferences();

    FlxG.sound.playMusic(Paths.music('freakyMenu'));

    Conductor.bpm = CoolVars.data.bpm;
}