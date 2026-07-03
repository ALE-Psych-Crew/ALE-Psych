import funkin.visuals.objects.Alphabet;

import flixel.group.FlxSpriteGroup;

var options:FlxSpriteGroup;

function postCreate()
{
    subCamera.alpha = 0;

    FlxTween.tween(subCamera, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});

    final bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.alpha = 0.75;
    add(bg);

    final title:Alphabet = new Alphabet(0, FlxG.height * 0.3, 'Reset Options?');
    title.x = FlxG.width / 2 - title.width / 2;
    add(title);

    add(options = new FlxSpriteGroup(0, title.y + title.height + 100));

    for (i in 0...2)
    {
        final text:Alphabet = new Alphabet(i * 200, -100, i == 0 ? 'Yes' : 'No', false);
        text.alpha = 0.5;

        for (letter in text)
            CoolUtil.setProperties(letter.colorTransform, {redOffset: 255, greenOffset: 255, blueOffset: 255});
     
        options.add(text);
    }

    options.x = FlxG.width / 2 - options.width / 2;

    alternOption();
}

var sel(default, set):Bool = Save.custom.data.resetOptionsSel ??= false;
function set_sel(value:Bool):Bool
{
    sel = value;

    Save.custom.data.resetOptionsSel = !sel;

    return sel;
}

function alternOption()
{
    sel = !sel;

    for (index => opt in options.members)
        opt.alpha = (index == 0) == sel ? 1 : 0.5;
}

function onUpdate(elapsed:Float)
{
    if (Controls.BACK)
        close();

    if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
        alternOption();

    if (Controls.ACCEPT)
    {
        if (sel)
        {
            Save.reset();

            CoolUtil.resetGame();
        }

        close();
    }
}

function onDestroy()
    FlxTween.cancelTweensOf(subCamera);