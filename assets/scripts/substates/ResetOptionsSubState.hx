import funkin.visuals.objects.Alphabet;

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

            CoolUtil.resetGame();
        }
    }
}

MobileAPI.toggleButtons(false, false);

MobileAPI.createButtons(FlxG.width - 100, FlxG.height - 100, [{label: 'A', keys: ClientPrefs.controls.ui.accept}], null, true);

MobileAPI.createButtons(100, FlxG.height - 200, [
    {label: 'L', keys: ClientPrefs.controls.ui.left},
    {label: 'R', keys: ClientPrefs.controls.ui.right},
], null, true);

function onDestroy()
{
    MobileAPI.destroyButtons(true);

    MobileAPI.toggleButtons(false, true);
}