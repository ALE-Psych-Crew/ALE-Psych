import funkin.visuals.objects.Alphabet;

var subCamera:FlxCamera = new ALECamera();

FlxG.cameras.add(subCamera);

var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
add(bg);
bg.alpha = 0;
bg.cameras = [subCamera];

FlxTween.tween(bg, {alpha: 0.75}, 0.5, {ease: FlxEase.cubeOut});

var title:Alphabet = new Alphabet(0, 0, 'Would you like to\nreset your settings?');
add(title);
title.cameras = [subCamera];
title.x = FlxG.width / 2;
title.y = FlxG.height / 2 - title.height - 50;
title.alignment = 'centered';

var toSelect:Array<Alphabet> = [];

for (i in 0...2)
{
    var alpha:Alphabet = new Alphabet(FlxG.width / 2 + (i == 0 ? -200 : 200), FlxG.height / 2 + 50, i == 0 ? 'No' : 'Yes');
    add(alpha);
    alpha.cameras = [subCamera];
    alpha.alignment = 'centered';
    alpha.color = i == 0 ? FlxColor.WHITE : FlxColor.GRAY;

    toSelect.push(alpha);
}

var selected:Bool = false;

function onUpdate(elapsed:Float)
{
    if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
    {
        selected = !selected;

        for (i in 0...2)
            toSelect[i].color = i == (selected ? 1 : 0) ? FlxColor.WHITE : FlxColor.GRAY;

        FlxG.sound.play(Paths.sound('scrollMenu'));
    }

    if (Controls.ACCEPT)
    {
        close();

        if (selected)
        {
            CoolUtil.save.reset();

            CoolUtil.resetEngine();
        }
    }
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
            [FlxG.width - 175, 485, ClientPrefs.controls.ui.accept, 'a uppercase'],
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

    FlxG.cameras.remove(subCamera);
}