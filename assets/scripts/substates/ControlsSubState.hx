import options.ControlsOption;

import funkin.visuals.objects.Alphabet;

using StringTools;

inline function multiProp(obj:Dynamic, path:String)
{
    for (field in path.split('.'))
        if (field != '')
            obj = Reflect.field(obj, field);

    return obj;
}


function priorSort(priorities:Array<String>, ?field:String)
{
    return function(a, b)
    {
        var an = multiProp(a, field ?? '');
        var bn = multiProp(b, field ?? '');

        var ai = priorities.indexOf(an);
        var bi = priorities.indexOf(bn);

        if (ai == -1 && bi == -1)
            return Reflect.compare(an, bn);

        if (ai == -1)
            return 1;

        if (bi == -1)
            return -1;

        return Reflect.compare(ai, bi);
    }
}

var options:Array<Dynamic> = [
    for (group in Reflect.fields(ClientPrefs.controls))
    {
        {
            name: group,
            options: [
                for (id in Reflect.fields(Reflect.field(ClientPrefs.controls, group)))
                    id
            ]
        }
    }
];

options.sort(priorSort(['notes', 'ui'], 'name'));

for (group in options)
    group.options.sort(priorSort(['left', 'down', 'up', 'right']));

FlxG.camera.bgColor = FlxColor.WHITE;

var subCamera:FlxCamera = new FlxCamera();
subCamera.bgColor = FlxColor.TRANSPARENT;

FlxG.cameras.add(subCamera, false);

var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
add(bg);
bg.cameras = [subCamera];
bg.scrollFactor.set();
bg.alpha = 0;

FlxTween.tween(bg, {alpha: 0.75}, 0.5, {ease: FlxEase.cubeOut});

var globalIndex:Int = 0;

var totalOptions:Int = 0;

var ctrlOpts:Array<ControlsOption> = [];

var canSelect:Bool = true;

for (groupIndex => group in options)
{
    globalIndex += 1;

    var title:Alphabet = new Alphabet(0, 0, group.name.toUpperCase(), false);
    add(title);
    title.x = FlxG.width / 2 - title.width / 2;
    title.y = 50 * globalIndex - 40;
    title.cameras = [subCamera];

    for (let in title)
        let.colorTransform.redOffset = let.colorTransform.greenOffset = let.colorTransform.blueOffset = 255;

    globalIndex += 2;

    for (option in group.options)
    {
        var ctrlOpt:ControlsOption = new ControlsOption(group.name, option, groupIndex);
        add(ctrlOpt);
        ctrlOpt.x = FlxG.width / 2 - ctrlOpt.bg.width / 2;
        ctrlOpt.y = globalIndex * ctrlOpt.bg.height;

        ctrlOpts.push(ctrlOpt);
        
        for (obj in ctrlOpt)
            obj.cameras = [subCamera];

        totalOptions++;

        globalIndex++;
    }
}

var selInt:Int = 0;

var groupInt:Int = 0;

var isLeft:Bool = true;

function onUpdate(elapsed:Float)
{
    subCamera.scroll.y = CoolUtil.fpsLerp(subCamera.scroll.y, (selInt + groupInt * 3) * 50 - 100, 0.25);

    if (canSelect)
    {
        var curOpt = ctrlOpts[selInt];

        if (FlxG.keys.justPressed.ANY)
            if (curOpt.onConfig)
            {
                curOpt.endConfig(FlxG.keys.firstJustPressed());

                return;
            }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            canSelect = false;

            FlxG.sound.play(Paths.sound('cancelMenu'));

            close();
        }

        if (FlxG.keys.justPressed.ENTER)
            if (!curOpt.onConfig)
                curOpt.initConfig();

        if (FlxG.keys.justPressed.BACKSPACE)
            if (!curOpt.onConfig)
                curOpt.clearConfig();

        if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
        {
            if (curOpt.onConfig)
                return;

            if (FlxG.keys.justPressed.UP)
                if (selInt <= 0)
                    selInt = totalOptions - 1;
                else
                    selInt--;

            if (FlxG.keys.justPressed.DOWN)
                if (selInt >= totalOptions - 1)
                    selInt = 0;
                else
                    selInt++;

            if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
                isLeft = !isLeft;

            changeShit();

            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
    }
}

function changeShit()
{
    for (index => opt in ctrlOpts)
    {
        opt.isSelected = index == selInt;
        opt.isFirst = isLeft;

        if (index == selInt)
            groupInt = opt.groupIndex;
    }
}

changeShit();

function onDestroy()
{
    FlxG.cameras.remove(subCamera);
}