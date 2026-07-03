import funkin.visuals.objects.Alphabet;

import flixel.input.keyboard.FlxKey;
import flixel.group.FlxSpriteGroup;
import flixel.effects.FlxFlicker;

var options:FlxTypedGroup<FlxSpriteGroup>;

var selInt(default, set):Int = Save.custom.data.controlsSelInt ??= 0;
function set_selInt(value:Int):Int
    return selInt = Save.custom.data.controlsSelInt = value;

var sel(default, set):Bool = Save.custom.data.controlsSel ??= false;
function set_sel(value:Bool):Bool
    return sel = Save.custom.data.controlsSel = value;

function postCreate()
{
    subCamera.alpha = 0;

    FlxTween.tween(subCamera, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});

    final bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.scrollFactor.set();
    bg.alpha = 0.75;
    add(bg);

    add(options = new FlxTypedGroup<FlxSpriteGroup>());

    var offset:Float = 0;

    for (group in controlsConfig)
    {
        final title:Alphabet = new Alphabet(0, offset, group.name);
        title.x = FlxG.width / 2 - title.width / 2;
        add(title);

        offset += title.height + 20;

        for (ctrl in group.options)
        {
            final grp:FlxSpriteGroup = new FlxSpriteGroup(0, offset);
            options.add(grp);

            final name:Alphabet = new Alphabet(0, -25, ctrl.name + ':', false);
            name.scaleX = name.scaleY = 0.75;
            grp.add(name);

            for (let in name)
                CoolUtil.setProperties(let.colorTransform, {redOffset: 125, greenOffset: 50, blueOffset: 255});

            final left:Alphabet = new Alphabet(0, -25, '', false);
            left.scaleX = left.scaleY = name.scaleX;
            grp.add(left);

            final right:Alphabet = new Alphabet(0, -25, '', false);
            right.scaleX = right.scaleY = name.scaleX;
            grp.add(right);

            function regen()
            {
                final config = ClientPrefs.getControl(group.variable, ctrl.variable);

                for (i in 0...2)
                    config[i] ??= 0;

                left.text = (config[0] == 0 ? '...' : FlxKey.toStringMap.get(config[0]));
                left.x = name.x + name.width + FlxG.width * 0.125;

                right.text = (config[1] == 0 ? '...' : (FlxKey.toStringMap.get(config[1])));
                right.x = left.x + left.width + FlxG.width * 0.125;

                for (alpha in [left, right])
                    for (let in alpha)
                        CoolUtil.setProperties(let.colorTransform, {redOffset: 255, greenOffset: 255, blueOffset: 255});

                grp.x = FlxG.width / 2 - grp.width / 2;

            }

            regen();

            grp.metadata.set('selection', () -> {
                left.alpha = sel ? 0.5 : 1;
                right.alpha = sel ? 1 : 0.5;
            });

            grp.metadata.set('change', (changing) -> {
                if (changing)
                {
                    if (sel)
                        right.visible = false;
                    else
                        left.visible = false;

                    FlxFlicker.flicker(sel ? right : left, 0, 0.25);
                } else {
                    FlxFlicker.stopFlickering(sel ? right : left);

                    ClientPrefs.getControl(group.variable, ctrl.variable)[sel ? 1 : 0] = FlxG.keys.firstJustPressed();

                    regen();
                }
            });

            offset += 75;
        }

        offset += title.height;
    }

    changeSelInt();
}

var current:FlxSpriteGroup;

function changeSelInt(?change:Int)
{
    selInt = FlxMath.wrap(selInt + change, 0, options.length - 1);

    for (index => obj in options.members)
    {
        if (index == selInt)
            current = obj;
        
        for (text in obj)
            text.alpha = index == selInt ? 1 : 0.5;
    }

    changeSel(false);
}

function changeSel(?change:Bool = true)
{
    if (change)
        sel = !sel;

    current.metadata.get('selection')();
}

var changing:Bool = false;

function onUpdate(elapsed:Float)
{
    if (changing)
    {
        if (FlxG.keys.firstJustPressed() > 0)
        {
            current.metadata.get('change')(false);

            changing = false;
        }
    } else {
        if (Controls.BACK)
            close();

        if (Controls.UI_UP_P || Controls.UI_DOWN_P)
        {
            changeSelInt(Controls.UI_UP_P ? -1 : 1);

            CoolUtil.playSound('scroll');
        }

        if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
            changeSel();

        if (Controls.ACCEPT)
        {
            changing = true;

            current.metadata.get('change')(true);
        }
    }

    subCamera.scroll.y = CoolUtil.fpsLerp(subCamera.scroll.y, current.y - 250, 0.25);
}

function onDestroy()
    FlxTween.cancelTweensOf(subCamera);

static final controlsConfig:Array<{name:String, options:Array<JsonControl>}> = [
    {
        name: 'Notes',
        variable: 'notes',
        options: [
            {
                variable: 'left',
                name: 'Left',
                initial: ['A', 'LEFT']
            },
            {
                variable: 'down',
                name: 'Down',
                initial: ['S', 'DOWN']
            },
            {
                variable: 'up',
                name: 'Up',
                initial: ['W', 'UP']
            },
            {
                variable: 'right',
                name: 'Right',
                initial: ['D', 'RIGHT']
            }
        ]
    },
    {
        name: 'UI',
        variable: 'ui',
        options: [
            {
                variable: 'left',
                name: 'Left',
                initial: ['A', 'LEFT']
            },
            {
                variable: 'down',
                name: 'Down',
                initial: ['S', 'DOWN']
            },
            {
                variable: 'up',
                name: 'Up',
                initial: ['W', 'UP']
            },
            {
                variable: 'right',
                name: 'Right',
                initial: ['D', 'RIGHT']
            },
            {
                variable: 'accept',
                name: 'Accept',
                initial: ['ENTER', 'SPACE']
            },
            {
                variable: 'back',
                name: 'Back',
                initial: ['ESCAPE']
            },
            {
                variable: 'reset',
                name: 'Reset',
                initial: ['R', 'F5']
            },
            {
                variable: 'pause',
                name: 'Pause',
                initial: ['ENTER', 'ESCAPE']
            },
            {
                variable: 'mute',
                name: 'Mute',
                initial: ['ZERO']
            },
            {
                variable: 'volume_up',
                name: 'Volume Up',
                initial: ['PLUS', 'NUMPADPLUS']
            },
            {
                variable: 'volume_down',
                name: 'Volume Down',
                initial: ['MINUS', 'NUMPADMINUS']
            }
        ]
    },
    {
        name: 'Debug',
        variable: 'engine',
        options: [
            {
                variable: 'chart',
                name: 'Chart Editor',
                initial: ['SEVEN']
            },
            {
                variable: 'character',
                name: 'Character Editor',
                initial: ['EIGHT']
            },
            {
                variable: 'switch_mod',
                name: 'Switch Mod',
                initial: ['M']
            },
            {
                variable: 'reset_game',
                name: 'Reset Game',
                initial: ['N']
            },
            {
                variable: 'master_menu',
                name: 'Editors Menu',
                initial: ['SEVEN']
            },
            {
                variable: 'fps_counter',
                name: 'Toggle FPS Counter',
                initial: ['F3']
            }
        ]
    }
].concat(Paths.exists('data/controls.json') ? Paths.json('data/controls').groups : []);