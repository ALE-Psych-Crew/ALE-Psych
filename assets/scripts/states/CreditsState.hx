import funkin.visuals.objects.Alphabet;

import flixel.group.FlxSpriteGroup;

@:typedef JsonCredits = {
    var directory:String;

    var bg:JsonSprite;

    var descriptionMargin:Point;

    var groupsSpacing:Float;

    var developersSpacing:Float;

    var cameraOffset:Float;
    var cameraSpeed:Float;
}

final config:JsonCredits = Paths.json('data/menus/credits');

final jsonCredits:Array<JsonCreditsGroup> = Paths.json('data/credits');

var developers:FlxTypedGroup<FlxSpriteGroup>;

var bg:FunkinSprite;

var descriptionText:FlxText;
var descriptionBG:FlxSprite;

function postCreate()
{
    add(bg = CoolUtil.spriteFromJson(null, config.bg, 'menus/' + config.directory + '/'));
    bg.x += FlxG.width / 2 - bg.width / 2;
    bg.y += FlxG.height / 2 - bg.height / 2;

    add(developers = new FlxTypedGroup<FlxSpriteGroup>());

    var offset:Float = 0;

    for (group in jsonCredits.groups)
    {
        final title:Alphabet = new Alphabet(0, offset, group.name);
        title.x = FlxG.width / 2 - title.width / 2;
        add(title);

        offset += config.groupsSpacing;

        for (dev in group.developers)
        {
            final sprs:FlxSpriteGroup = new FlxSpriteGroup(0, offset);
            sprs.metadata.set('description', dev.description);
            sprs.metadata.set('url', dev.url);
            developers.add(sprs);

            final name:Alphabet = new Alphabet(0, -40, dev.name, false);
            name.scaleX = name.scaleY = 0.75;
            sprs.add(name);

            for (let in name)
                CoolUtil.setProperties(let.colorTransform, {redOffset: 255, greenOffset: 255, blueOffset: 255});

            final icon:FlxSprite = new FlxSprite(name.width + 30, 0, Paths.image('menus/credits/icons/' + dev.icon));
            icon.setGraphicSize(0, 75);
            icon.updateHitbox();
            icon.y = name.height / 2 - icon.height / 2;
            sprs.add(icon);

            sprs.x = FlxG.width / 2 - sprs.width / 2;

            offset += config.developersSpacing;
        }

        offset += config.groupsSpacing;
    }

    add(descriptionBG = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK));
    descriptionBG.scrollFactor.set();
    descriptionBG.alpha = 0.5;

    add(descriptionText = new FlxText(0, 0, FlxG.width - config.descriptionMargin.x, '', 25));
    descriptionText.x = FlxG.width / 2 - descriptionText.width / 2;
    descriptionText.font = Paths.font('vcr.ttf');
    descriptionText.alignment = 'center';
    descriptionText.scrollFactor.set();

    changeOption();
}

var selInt(default, set):Int = Save.custom.data.creditsSelInt ??= 0;
function set_selInt(value:Int):Int
    return selInt = Save.custom.data.creditsSelInt = value;

var current:FlxSpriteGroup;

function changeOption(?change:Int = 0)
{
    selInt = FlxMath.wrap(selInt + change, 0, developers.members.length - 1);

    for (index => opt in developers.members)
    {
        opt.alpha = index == selInt ? 1 : 0.5;

        if (index == selInt)
        {
            current = opt;

            descriptionText.text = opt.metadata.get('description');
            descriptionText.y = FlxG.height - descriptionText.height - config.descriptionMargin.y;

            descriptionBG.scale.y = descriptionText.height + config.descriptionMargin.y * 2;
            descriptionBG.updateHitbox();
            descriptionBG.y = FlxG.height - descriptionBG.height;
        }
    }
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    if (canSelect)
    {
        if (Controls.ACCEPT)
            FlxG.openURL(current.metadata.get('url'));

        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(CoolVars.data.mainMenuState);

            CoolUtil.playSound('cancel');
        }

        if (Controls.UI_UP_P || Controls.UI_DOWN_P)
        {
            changeOption(Controls.UI_UP_P ? -1 : 1);

            CoolUtil.playSound('scroll');
        }
    }

    camGame.scroll.y = CoolUtil.fpsLerp(camGame.scroll.y, current.y + config.cameraOffset, config.cameraSpeed);
}

CoolUtil.createTouchButtons([
    { label: 'D', keys: ClientPrefs.controls.ui.down },
    { label: 'U', keys: ClientPrefs.controls.ui.up }
], 150, FlxG.height - 170, 90);

CoolUtil.createTouchButtons([
    { label: 'A', keys: ClientPrefs.controls.ui.accept },
    { label: 'B', keys: ClientPrefs.controls.ui.back }
], FlxG.width - 200, FlxG.height - 170);