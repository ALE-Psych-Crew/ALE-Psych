import funkin.visuals.objects.Alphabet;

import flixel.input.keyboard.FlxKey;

import options.BaseOption;
import options.StateOption;
import options.BoolOption;
import options.NumberOption;
import options.StringOption;

using StringTools;

var json:Dynamic = Paths.json('data/options');

var categories:Array<Dynamic> = json == null ? [] : json.categories;

var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
add(bg);
bg.color = FlxColor.fromRGB(55, 50, 70);
bg.scale.x = bg.scale.y = 1.125;
bg.scrollFactor.set();

var globalIndex:Float = 0;

var toSelect:Array<BaseOption> = [];

var offset:Int = 130;

var isPlayState:Bool;

function new(?isPlay:Bool)
{
    isPlayState = isPlay ?? false;
}

function createOption(index:Int, obj:BaseOption)
{
    obj.groupIndex = index;

    obj.x = FlxG.width / 2 - obj.width / 2;
    obj.y = globalIndex * offset;
    add(obj);
        
    toSelect.push(obj);
    
    globalIndex++;
}

for (index => category in categories)
{
    var title:Alphabet = new Alphabet(0, 0, category.name);
    add(title);
    title.x = FlxG.width / 2 - title.width / 2;
    title.y = globalIndex * offset + 20;

    globalIndex++;

    var obj:BaseOption;

    for (option in category.options)
        if ((option.platform == 'desktop' && !CoolVars.mobile) || (option.platform == 'mobile' && CoolVars.mobile) || option.platform == null)
            createOption(index,
                switch (option.type.toUpperCase())
                {
                    case 'BOOL':
                        new BoolOption(option);
                    case 'FLOAT', 'INTEGER':
                        new NumberOption(option);
                    case 'STRING':
                        new StringOption(option);
                    case 'STATE', 'SUBSTATE':
                        new StateOption(option);
                    default:
                        debugTrace('Invalid Option Type: ' + option.type.toUpperCase(), 'error');
                }
            );

    globalIndex += 0.5;
}

var descBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK);
add(descBG);
descBG.scrollFactor.set();
descBG.alpha = 0.75;

var desc:FlxText = new FlxText(0, 0, FlxG.width * 0.9, '', 30);
add(desc);
desc.scrollFactor.set();
desc.alignment = 'center';
desc.font = Paths.font('vcr.ttf');
desc.x = FlxG.width / 2 - desc.width / 2;

var selInt:Int = FlxMath.bound(CoolUtil.save.custom.data.optionsMenu, 0, toSelect.length - 1) ?? 0;

var curGroup:Int = 0;

function changeShit()
{
    for (index => obj in toSelect)
    {
        obj.selected = index == selInt;

        if (index == selInt)
        {
            curGroup = obj.groupIndex;

            desc.text = obj.data.description;
            desc.y = FlxG.height * 0.9 - desc.height / 2;

            descBG.scale.y = desc.height + 50;
            descBG.updateHitbox();
            descBG.y = desc.y + desc.height / 2 - descBG.height / 2;
        }
    }
}

changeShit();

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    game.camGame.scroll.y = CoolUtil.fpsLerp(game.camGame.scroll.y, selInt * offset + curGroup * offset * 1.5 - 200, 0.25);

    if (canSelect)
    {
        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState((isPlayState ?? false) ? new PlayState() : new CustomState(CoolVars.data.mainMenuState));

            FlxG.sound.play(Paths.sound('cancelMenu'));
        }

        if (Controls.UI_UP_P || Controls.UI_DOWN_P || Controls.MOUSE_WHEEL)
        {
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                if (selInt <= 0)
                    selInt = toSelect.length - 1;
                else
                    selInt--;

            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                if (selInt >= toSelect.length - 1)
                    selInt = 0;
                else
                    selInt++;

            changeShit();

            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
    }
}

function onDestroy()
{
    CoolUtil.save.custom.data.optionsMenu = selInt;

    CoolUtil.save.save();
    CoolUtil.save.load();
}

MobileAPI.createButtons(FlxG.width - 300, FlxG.height - 200, [
    {label: 'A', keys: ClientPrefs.controls.ui.accept},
    {label: 'B', keys: ClientPrefs.controls.ui.back},
]);

MobileAPI.createButtons(100, FlxG.height - 300, [
    {label: 'R', keys: ClientPrefs.controls.ui.right},
    {label: 'D', keys: ClientPrefs.controls.ui.down},
    {label: 'L', keys: ClientPrefs.controls.ui.left},
    {label: 'U', keys: ClientPrefs.controls.ui.up},
]);