import funkin.visuals.objects.Alphabet;

import flixel.util.FlxColor;

var data = Json.parse(File.getContent(Paths.getPath('credits.json'))).categories;

var dataDevs:Array = [];

var bg:FlxSprite;

var categories:FlxTypedGroup;
var developers:FlxTypedGroup;
var icons:FlxTypedGroup;

var descBG:FlxSprite;
var description:FlxText;

var selInt:Int = CoolUtil.save.custom.data.credits ?? 0;

var theY:Float = 0;

function onCreate()
{
    bg = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
    bg.scrollFactor.set();
    add(bg);
    bg.scale.x = bg.scale.y = 1.25;
    bg.antialiasing = ClientPrefs.data.antialiasing;

    add(categories = new FlxTypedGroup());
    add(developers = new FlxTypedGroup());
    add(icons = new FlxTypedGroup());

    var catOffset:Float = 0;

    for (category in data)
    {
        var catIndex:Int = data.indexOf(category);

        var title:Alphabet = new Alphabet(0, catIndex + catOffset, category.name);
        title.x = FlxG.width / 2 - title.width / 2;
        categories.add(title);
        title.antialiasing = ClientPrefs.data.antialiasing;

        catOffset += title.height + 60;

        for (dev in category.developers)
        {
            dataDevs.push(dev);

            var devIndex:Int = category.developers.indexOf(dev);

            var alpha:Alphabet = new Alphabet(0, title.y + title.height + 60 + 100 * devIndex, dev.name, false);
            developers.add(alpha);
            alpha.scaleX = alpha.scaleY = 0.75;
            alpha.x = FlxG.width / 2 - alpha.width / 2;
            alpha.antialiasing = ClientPrefs.data.antialiasing;

            for (let in alpha)
            {
                let.colorTransform.redOffset = 255;
                let.colorTransform.greenOffset = 255;
                let.colorTransform.blueOffset = 255;
            }

            var icon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/' + dev.icon, false) ?? Paths.image('credits/placeholder'));
            icons.add(icon);
            icon.scale.x = icon.scale.y = 0.8;
            icon.updateHitbox();
            icon.antialiasing = ClientPrefs.data.antialiasing;

            alpha.x -= icon.width / 2 - 10;

            icon.x = alpha.x + alpha.width + 20;
            icon.y = alpha.y + alpha.height / 2 - icon.height / 2;

            alpha.y -= 40;

            catOffset += 100;
        }

        catOffset += 75;
    }
    
    if (selInt >= developers.length)
        selInt = 0;

    descBG = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK); 
    descBG.alpha = 0.5;
    descBG.scrollFactor.set();
    add(descBG);

    description = new FlxText(20, 0, FlxG.width - 40, '', 30);
    description.font = Paths.font('vcr.ttf');
    description.alignment = 'center';
    add(description);
    description.scrollFactor.set();
    description.x = FlxG.width - description.width;
    description.y = FlxG.height - 100 - description.height / 2;

    descBG.scale.y = description.height + 40;
    descBG.updateHitbox();
    descBG.y = description.y - 20;
    
    bg.color = CoolUtil.colorFromString(dataDevs[selInt].color);

    changeShit();
}

var canSelect:Bool = true;

function onUpdate()
{
    if (canSelect)
    {
        if (Controls.BACK)
        {
            CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));

            FlxG.sound.play(Paths.sound('cancelMenu'));

            canSelect = false;
        }
    
        if (Controls.UI_DOWN_P || Controls.UI_UP_P || Controls.MOUSE_WHEEL)
        {
            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                if (selInt >= developers.length - 1)
                    selInt = 0;
                else
                    selInt++;
    
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                if (selInt <= 0)
                    selInt = developers.length - 1;
                else
                    selInt--;
    
            FlxG.sound.play(Paths.sound('scrollMenu'));
    
            changeShit();
        }

        if (Controls.ACCEPT)
            CoolUtil.browserLoad(dataDevs[selInt].link);
    }

    game.camGame.scroll.y = CoolUtil.fpsLerp(game.camGame.scroll.y, theY - 300, 0.2);
}

function changeShit()
{
    FlxTween.cancelTweensOf(bg);
    FlxTween.color(bg, 2, bg.color ?? FlxColor.WHITE, CoolUtil.colorFromString(dataDevs[selInt].color), {ease: FlxEase.cubeOut});

    for (grp in [developers, icons])
        for (mem in grp)
            mem.alpha = grp.members.indexOf(mem) == selInt ? 1 : 0.5;
    
    for (dev in developers)
        if (developers.members.indexOf(dev) == selInt)
            theY = dev.y;
    
    description.text = dataDevs[selInt].description;
    description.y = FlxG.height - 100 - description.height / 2;

    descBG.scale.y = description.height + 40;
    descBG.updateHitbox();
    descBG.y = description.y - 20;
}

var mobileCamera:FlxCamera;

function postCreate()
{
    if (CoolVars.mobileControls)
    {
        mobileCamera = new ALECamera();
        
        FlxG.cameras.add(mobileCamera, false);

        var buttonMap:Array<Dynamic> = [
            [50, 395, ClientPrefs.controls.ui.up, '< normal', 90],
            [50, 550, ClientPrefs.controls.ui.down, '> normal', 90],
            [1105, 485, ClientPrefs.controls.ui.back, 'b uppercase'],
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

    CoolUtil.save.custom.data.credits = selInt;
    CoolUtil.save.custom.flush();
}