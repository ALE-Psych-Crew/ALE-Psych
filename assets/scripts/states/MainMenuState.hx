import funkin.states.OptionsState;

import flixel.text.FlxTextBorderStyle;
import flixel.effects.FlxFlicker;

var options:Array = ['storyMode', 'freeplay', 'credits', 'options'];

var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuBGYellow'));
add(bg);
bg.antialiasing = ClientPrefs.data.antialiasing;
bg.scrollFactor.set(0, 0.75 / options.length);
bg.scale.set(1.25, 1.25);
bg.screenCenter('x');

var magentaBg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuBGMagenta'));
add(magentaBg);
magentaBg.antialiasing = ClientPrefs.data.antialiasing;
magentaBg.scrollFactor.set(0, 0.75 / options.length);
magentaBg.scale.set(1.25, 1.25);
magentaBg.screenCenter('x');
magentaBg.visible = false;

var version = new FlxText(10, 0, 0, 'ALE Psych ' + CoolVars.engineVersion + '\n\nFriday Night Funkin\' v0.2.8');
version.setFormat(Paths.font('vcr.ttf'), 17, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
add(version);
version.scrollFactor.set();
version.y = FlxG.height - version.height - 10;

var sprites:Array<FlxSprite> = [];

for (index => option in options)
{
    var img:FlxSprite = new FlxSprite();
    img.frames = Paths.getSparrowAtlas('mainMenuState/' + option);
    img.animation.addByPrefix('basic', 'basic', 24, true);
    img.animation.addByPrefix('white', 'white', 24, true);
    img.animation.play('basic');
    img.antialiasing = ClientPrefs.data.antialiasing;
    img.x = FlxG.width / 2 - img.width / 2;
    img.y = 175 * index;
    add(img);
    img.animation.callback = (_, __, ___) -> {
        img.centerOffsets();
        img.centerOrigin();
    }

    sprites.push(img);
}

var selInt:Int = CoolUtil.save.custom.data.mainMenu ?? 0;

function changeShit()
{   
    for (index => sprite in sprites)
    {
        sprite.animation.play(index == selInt ? 'white' : 'basic');
    }
}

changeShit();

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    game.camGame.scroll.y = CoolUtil.fpsLerp(game.camGame.scroll.y, selInt * 175 - FlxG.height * (0.25 + 0.5 * selInt / sprites.length), 0.3);

    if (canSelect)
    {
        if (Controls.UI_UP_P || Controls.UI_DOWN_P || Controls.MOUSE_WHEEL)
        {
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                if (selInt <= 0)
                    selInt = sprites.length - 1;
                else
                    selInt--;

            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                if (selInt >= sprites.length - 1)
                    selInt = 0;
                else
                    selInt++;

            changeShit();

            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        
        if (Controls.ACCEPT)
        {
            canSelect = false;

            FlxG.sound.play(Paths.sound('confirmMenu'));

            if (ClientPrefs.data.flashing)
                FlxFlicker.flicker(magentaBg, 1.1, 0.15, false);

            for (index => sprite in sprites)
            {
                if (index == selInt)
                {
                    if (ClientPrefs.data.flashing)
                        FlxFlicker.flicker(sprite, 0, 0.05);
                } else {
                    FlxTween.tween(sprite, {alpha: 0}, 60 / Conductor.bpm, {ease: FlxEase.cubeIn});
                }
            }

            new FlxTimer().start(1, (_) -> {
                switch (options[selInt])
                {
                    case 'storyMode':
                        CoolUtil.switchState(new CustomState(CoolVars.data.storyMenuState));
                    case 'freeplay':
                        CoolUtil.switchState(new CustomState(CoolVars.data.freeplayState));
                    case 'credits':
                        CoolUtil.switchState(new CustomState('CreditsState'));
                    case 'options':
                        CoolUtil.switchState(new OptionsState(false));
                }
            });
        }

        if (Controls.BACK)
        {
            canSelect = false;

            FlxG.sound.play(Paths.sound('cancelMenu'));

            CoolUtil.switchState(new CustomState(CoolVars.data.initialState));
        }

        if (Controls.ENGINE_MASTER_EDITOR && CoolVars.data.developerMode)
        {
            canSelect = false;

            CoolUtil.switchState(new CustomState(CoolVars.data.masterEditorState));
        }
    }
}

var mobileCamera:FlxCamera;

function postCreate()
{
    if (CoolVars.mobileControls)
    {
        mobileCamera = new FlxCamera();
        mobileCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(mobileCamera, false);

        var buttonMap:Array<Dynamic> = [
            [50, 395, ClientPrefs.controls.ui.up, '< normal', 90],
            [50, 550, ClientPrefs.controls.ui.down, '> normal', 90],
            [1105, 485, ClientPrefs.controls.ui.accept, 'a uppercase'],
            [950, 485, ClientPrefs.controls.ui.back, 'b uppercase']
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

    CoolUtil.save.custom.data.mainMenu = selInt;
    CoolUtil.save.custom.flush();
}