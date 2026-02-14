import funkin.visuals.objects.Alphabet;

import flixel.math.FlxPoint;

final bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
bg.cameras = [subCamera];
bg.alpha = 0;
bg.scrollFactor.set();
add(bg);

FlxTween.tween(bg, {alpha: 0.5}, 0.5, {ease: FlxEase.cubeOut});

for (index => txt in ['Song: ' + PlayState.instance.song, 'Difficulty: ' + PlayState.instance.difficulty, PlayState.instance.type == 'story' ? 'Story Mode' : 'Freeplay'])
{
    final text:FlxText = new FlxText(FlxG.width, 10 + 30 * index, 0, txt, 30);
    text.font = Paths.font('vcr.ttf');
    text.alpha = 0;
    text.cameras = [subCamera];
    text.scrollFactor.set();
    
    add(text);

    FlxTween.tween(text, {x: FlxG.width - 19 - text.width, alpha: 1}, 0.5, {ease: FlxEase.cubeOut, startDelay: index * 0.25});
}

final options:Array<String> = ['resume', 'restart song', 'exit to menu'];

final sprites:Array<Alphabet> = new Array<Alphabet>();

final SPACE:FlxPoint = FlxPoint.get(50, 150);

for (index => opt in options)
{
    final spr:Alphabet = new Alphabet(0, 0, opt);
    spr.cameras = [subCamera];
    spr.alpha = 0.5;
    add(spr);

    FlxTween.tween(spr, {x: SPACE.x * index, y: SPACE.y * index}, 0.3, {ease: FlxEase.cubeOut});

    sprites.push(spr);
}

var selInt:Int = 0;

function changeOption()
{
    if (selInt < 0)
        selInt = sprites.length - 1;

    if (selInt > sprites.length - 1)
        selInt = 0;

    for (index => spr in sprites)
        spr.alpha = index == selInt ? 1 : 0.5;
}

changeOption();

function onUpdate(elapsed:Float)
{
    subCamera.scroll.x = CoolUtil.fpsLerp(subCamera.scroll.x, SPACE.x * selInt - 100, 0.3);
    subCamera.scroll.y = CoolUtil.fpsLerp(subCamera.scroll.y, SPACE.y * selInt - 250, 0.3);

    if (Controls.UI_UP_P || Controls.UI_DOWN_P || Controls.MOUSE_WHEEL)
    {
        if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
            selInt--;

        if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
            selInt++;

        changeOption();

        FlxG.sound.play(Paths.sound('scrollMenu', true));
    }

    if (Controls.ACCEPT)
    {
        close();

        switch (options[selInt])
        {
            case 'restart song':
                PlayState.instance.restart();
            case 'exit to menu':
                PlayState.instance.exit();
            case 'resume':
                PlayState.instance.resume();
            default:
        }
    }
}

MobileAPI.toggleButtons(false, false);

MobileAPI.createButtons(FlxG.width - 100, FlxG.height - 100, [{label: 'A', keys: ClientPrefs.controls.ui.accept}], null, true);

MobileAPI.createButtons(100, FlxG.height - 200, [
    {label: 'D', keys: ClientPrefs.controls.ui.down},
    {label: 'U', keys: ClientPrefs.controls.ui.up},
], null, true);

function onDestroy()
{
    MobileAPI.destroyButtons(true);

    MobileAPI.toggleButtons(false, true);
}