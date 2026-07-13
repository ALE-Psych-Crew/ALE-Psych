import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;

using StringTools;

@:typedef JsonMain = {
    var directory:String;

    var cameraSpread:Float;

    var text:String;
    var textCorner:String;
    var textMargin:Point;
    
    var bg:JsonSprite;

    var options:Array<JsonSprite>;
    var optionsOffset:Point;
    var optionsSpacing:Float;
    var optionsAlignment:String;
    var optionsSelectedAnimation:String;
    var optionsIdleAnimation:String;
};

var config:JsonMain = Paths.json('data/menus/main');

var bg:FlxSprite;

var options:FlxTypedGroup<FlxSprite>;

var text:FlxText;

function onCreate()
{
    final path:String = 'menus/' + config.directory + '/';

    bg = CoolUtil.spriteFromJson(null, config.bg, path);
    bg.scrollFactor.y *= (0.5 / config.options.length);
    bg.y += FlxG.height / 2 - bg.height / 2;
    bg.x += FlxG.width / 2 - bg.width / 2;

    options = new FlxTypedGroup<FlxSprite>();

    for (index => data in config.options)
    {
        final spr = CoolUtil.spriteFromJson(null, data, path);

        spr.y += -spr.height / 2 + config.optionsSpacing * index + config.optionsOffset.y;

        switch (config.optionsAlignment.toLowerCase())
        {
            case 'center':
                spr.x += FlxG.width / 2 - spr.width / 2 + config.optionsOffset.x;

            case 'right':
                spr.x += FlxG.width - spr.width + spr.x + config.optionsOffset.x;

            default:
                spr.x += config.optionsOffset.x;
        }

        options.add(spr);
    }

    final splitCorner:String = config.textCorner.split('_');

    text = new FlxText(0, 0, FlxG.width - config.textMargin.x * 2, 'ALE Psych ' + CoolVars.engineVersion + '\n' + (CoolVars.mobileControls ? '' : 'Press [Ctrl + Shift + ${[for (key in ClientPrefs.controls.engine.switch_mod) if (key == null || key == 0) continue; else FlxKey.toStringMap.get(key)].join(' / ')}] to open the Mods Menu' + '\n') + config.text);
    text.setFormat(Paths.font('vcr.ttf'), 17, FlxColor.WHITE, splitCorner[1].toLowerCase(), FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    text.x = FlxG.width / 2 - text.width / 2;
    text.scrollFactor.set();
    text.borderSize = 1.25;

    if (splitCorner[0].toLowerCase() == 'top')
        text.y = config.textMargin.y;
    else
        text.y = FlxG.height - text.height - config.textMargin.y;

    for (obj in [bg, options, text])
        add(obj);

    changeOption();
}

var selInt(default, set):Int = Save.custom.data.mainMenuSelInt ??= 0;
function set_selInt(value:Int):Int
    return selInt = Save.custom.data.mainMenuSelInt = value;

function changeOption(?change:Int = 0)
{
    selInt = FlxMath.wrap(selInt + change, 0, options.members.length - 1);

    for (index => obj in options)
    {
        obj.playAnim(index == selInt ? config.optionsSelectedAnimation : config.optionsIdleAnimation);

        obj.centerOffsets();
    }
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    camGame.scroll.y = CoolUtil.fpsLerp(camGame.scroll.y, selInt * config.optionsSpacing - FlxG.height * ((1 - config.cameraSpread * 2) / 2 + config.cameraSpread * 2 * selInt / (config.options.length - 1)), 0.25);

    if (canSelect)
    {
        if (Controls.UI_DOWN_P || Controls.UI_UP_P)
        {
            changeOption(Controls.UI_DOWN_P ? 1 : -1);

            CoolUtil.playSound('scroll');
        }

        if (Controls.ACCEPT)
        {
            canSelect = false;

            for (index => option in options)
            {
                if (index == selInt)
                {
                    FlxFlicker.flicker(option, 0, ClientPrefs.data.flashing ? 0.075 : 0.125);

                    final nextState:String = option.config.state;

                    if (nextState.startsWith('meta:'))
                        nextState = Reflect.getProperty(CoolVars.meta, nextState.substr(5));

                    FlxTimer.wait(1, () -> CoolUtil.switchState(nextState));

                    CoolUtil.playSound('confirm');
                } else {
                    FlxTween.tween(option, {alpha: 0.5}, 1, {ease: FlxEase.cubeOut});
                }
            }
        }

        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(CoolVars.data.titleState);

            CoolUtil.playSound('cancel');
        }
    }
}

CoolUtil.createTouchButtons([
    { label: 'D', keys: ClientPrefs.controls.ui.down },
    { label: 'U', keys: ClientPrefs.controls.ui.up }
], 150, FlxG.height - 170, 90);

CoolUtil.createTouchButtons([
    { label: 'A', keys: ClientPrefs.controls.ui.accept },
    { label: 'B', keys: ClientPrefs.controls.ui.back }
], FlxG.width - 200, FlxG.height - 170);