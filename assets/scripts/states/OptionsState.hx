import funkin.visuals.objects.Alphabet;

import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
import flixel.FlxState;

@:typedef JsonOptions = {
    var directory:String;

    var bg:JsonSprite;
    var checkBox:JsonSprite;

    var optionsSpacing:Float;

    var cameraOffset:Point;
    var cameraSpeed:Float;

    var descriptionMargin:Point;

    var circlesSelectionScale:Float;
    var circlesSpacing:Float;
    var circlesOffset:Point;
    var circlesSpeed:Float;
};

final config:JsonOptions = Paths.json('data/menus/options');

var categories:FlxTypedGroup<FlxTypedSpriteGroup<FlxSpriteGroup>>;

var canSelect:Bool = true;

function extends(cls:Class<Dynamic>, par:Class<Dynamic>)
{
    while (cls != null)
    {
        if (cls == par)
            return true;

        cls = Type.getSuperClass(cls);
    }

    return false;
}

var descriptionText:FlxText;
var descriptionBG:FlxSprite;

var circles:FlxSpriteGroup;

function postCreate()
{
    final bg:FunkinSprite = CoolUtil.spriteFromJson(null, config.bg, 'menus/' + config.directory + '/');
    bg.y += FlxG.height / 2 - bg.height / 2;
    bg.x += FlxG.width / 2 - bg.width / 2;
    add(bg);

    add(categories = new FlxTypedGroup<FlxTypedSpriteGroup<FlxSpriteGroup>>());

    for (categoryIndex => category in optionsConfig)
    {
        final title:Alphabet = new Alphabet(categoryIndex * FlxG.width, 0, (categoryIndex <= 0 ? '' : '< ') + category.name + (categoryIndex >= optionsConfig.length - 1 ? '' : ' >'));
        title.x += FlxG.width / 2 - title.width / 2;
        add(title);

        final catGroup:FlxTypedSpriteGroup<FlxSpriteGroup> = new FlxTypedSpriteGroup<FlxSpriteGroup>(categoryIndex * FlxG.width);
        categories.add(catGroup);

        var categoryOffset:Float = config.optionsSpacing;

        for (index => option in category.options)
        {
            if (option.platform != null)
                if ((option.platform == 'desktop' && CoolVars.mobile) || (option.platform == 'mobile' && !CoolVars.mobile))
                    continue;

            final group:FlxSpriteGroup = new FlxSpriteGroup(0, categoryOffset);
            group.metadata.set('description', option.description);
            group.metadata.set('type', option.type);
            group.metadata.set('scroll', false);

            catGroup.add(group);

            /**
             * I NEED to Rewrite `Alphabet`
             */

            final text:Alphabet = new Alphabet(0, -25, option.name, false);
            text.scaleX = text.scaleY = 0.75;
            group.add(text);

            final value:Dynamic = option.variable == null ? null : ClientPrefs.getPreference(option.variable);

            if (value == null && option.variable != null)
                value = ClientPrefs.setPreference(option.variable, option.initial);

            option.type = option.type.toLowerCase();

            group.metadata.set('callback',
                switch (option.type)
                {
                    case 'bool':
                        final box:FunkinSprite = CoolUtil.spriteFromJson(null, config.checkBox, 'menus/' + config.directory + '/');
                        box.x += text.width;
                        box.y += text.height / 2 - box.height / 2;
                        box.animation.onFinish.add(name -> if (name == 'unCheck' || name == 'check') box.playAnim(name == 'check' ? 'idle' : 'unIdle'));
                        box.playAnim(value ? 'idle' : 'unIdle');

                        group.add(box);

                        () -> {
                            final value:Bool = !ClientPrefs.getPreference(option.variable);
                            
                            box.playAnim(value ? 'check' : 'unCheck');

                            ClientPrefs.setPreference(option.variable, value);
                        };

                    case 'int', 'float', 'string':
                        text.text += ':';

                        final subText:Alphabet = new Alphabet(text.width + 30, -25, value, false);
                        subText.scaleX = subText.scaleY = text.scaleX;

                        for (letter in subText)
                            CoolUtil.setProperties(letter.colorTransform, { redOffset: 255, greenOffset: 255, blueOffset: 255 });

                        group.add(subText);

                        group.metadata.set('scroll', true);

                        () -> {
                            if (option.type == 'string')
                            {
                                final index:Int = option.list.indexOf(ClientPrefs.getPreference(option.variable)) + (Controls.UI_LEFT ? -1 : 1);

                                if (index < 0)
                                    index = option.list.length - 1;

                                if (index > option.list.length - 1)
                                    index = 0;

                                subText.text = ClientPrefs.setPreference(option.variable, option.list[index]);
                            } else {
                                if (option.type == 'int')
                                    option.change = Std.int(option.change);
                                
                                final value:Float = FlxMath.bound(ClientPrefs.getPreference(option.variable) + option.change * (Controls.UI_LEFT ? -1 : 1), option.min, option.max);

                                if (option.type == 'int')
                                    value = Math.round(value);
                                else
                                    value = CoolUtil.floorDecimal(value, option.decimals);

                                subText.text = value;

                                ClientPrefs.setPreference(option.variable, value);
                            }

                            for (letter in subText)
                                CoolUtil.setProperties(letter.colorTransform, { redOffset: 255, greenOffset: 255, blueOffset: 255 });
                        };

                    case 'state', 'substate':
                        () -> {
                            final res = Type.resolveClass(option.path);

                            if (option.type == 'state')
                            {
                                canSelect = false;

                                if (res == null || !extends(res, FlxState) || extends(res, FlxSubState))
                                    res = new CustomState(option.path);
                                else
                                    res = Type.createInstance(res, []);


                                CoolUtil.switchState(res);
                            } else {
                                if (res == null || !extends(res, FlxSubState))
                                    res = new CustomSubState(option.path);
                                else
                                    res = Type.createInstance(res, []);

                                CoolUtil.openSubState(res);
                            }
                        };

                    default:
                        () -> {};
                }
            );

            for (letter in text)
                CoolUtil.setProperties(letter.colorTransform, { redOffset: 255, greenOffset: 255, blueOffset: 255 });

            group.x = categoryIndex * FlxG.width + FlxG.width / 2 - group.width / 2;
            
            categoryOffset += config.optionsSpacing;
        }
    }

    add(descriptionBG = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK));
    descriptionBG.scrollFactor.set();
    descriptionBG.alpha = 0.5;

    add(descriptionText = new FlxText(0, 0, FlxG.width - config.descriptionMargin.x, '', 25));
    descriptionText.x = FlxG.width / 2 - descriptionText.width / 2;
    descriptionText.font = Paths.font('vcr.ttf');
    descriptionText.alignment = 'center';
    descriptionText.scrollFactor.set();

    add(circles = new FlxSpriteGroup(config.circlesOffset.x, config.circlesOffset.y));
    circles.scrollFactor.set();

    for (i in 0...optionsConfig.length)
    {
        final circle:FlxShapeCircle = new FlxShapeCircle(i * config.circlesSpacing, 0, 5, {
            color: FlxColor.BLACK,
            thickness: 2
        }, FlxColor.WHITE);
        circle.antialiasing = false;

        circles.add(circle);
    }

    circles.x = FlxG.width / 2 - circles.width / 2;

    changeCategory();
}

HotReloading.add('data/options.json');

function onDestroy()
{
    Save.save();

    Save.load();
}

var catSelInt(default, set):Int = Save.custom.data.optionsCatSelInt ??= 0;
function set_catSelInt(value:Int):Int
    return catSelInt = Save.custom.data.optionsCatSelInt = value;

var selInt(default, set):Int = Save.custom.data.optionsSelInt ??= 0;
function set_selInt(value:Int):Int
    return selInt = Save.custom.data.optionsSelInt = value;

var options:FlxTypedSpriteGroup<FlxSpriteGroup>;

function changeCategory(?change:Int = 0)
{
    catSelInt = FlxMath.bound(catSelInt + change, 0, categories.members.length - 1);
    
    options = categories.members[catSelInt];

    selInt = FlxMath.bound(selInt, 0, options.members.length - 1);

    changeOption();
}

var current:FlxSpriteGroup;

function changeOption(?change:Int = 0)
{
    selInt += change;

    if (selInt < 0)
        selInt = options.members.length - 1;

    if (selInt > options.members.length - 1)
        selInt = 0;

    for (index => opt in options.members)
    {
        opt.alpha = index == selInt ? 1 : 0.5;

        if (selInt == index)
            current = opt;
    }

    descriptionText.text = current.metadata.get('description');
    descriptionText.y = FlxG.height - descriptionText.height - config.descriptionMargin.y;

    descriptionBG.scale.y = descriptionText.height + config.descriptionMargin.y * 2;
    descriptionBG.updateHitbox();
    descriptionBG.y = FlxG.height - descriptionBG.height;
}

function onUpdate(elapsed:Float)
{
    if (canSelect)
    {
        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));

            CoolUtil.playSound('cancel');
        }

        if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
            if (Controls.SHIFT || !current.metadata.get('scroll'))
                changeCategory(Controls.UI_LEFT_P ? -1 : 1);

        if (Controls.UI_LEFT || Controls.UI_RIGHT)
            if (!Controls.SHIFT && current.metadata.get('scroll') && (Controls.CONTROL || (Controls.UI_RIGHT_P || Controls.UI_LEFT_P)))
                current.metadata.get('callback')();

        if (Controls.UI_DOWN_P || Controls.UI_UP_P || Controls.MOUSE_WHEEL)
        {
            changeOption(Controls.UI_DOWN_P || FlxG.mouse.wheel == -1 ? 1 : -1);

            CoolUtil.playSound('scroll');
        }

        if (Controls.ACCEPT)
            if (!current.metadata.get('scroll'))
                current.metadata.get('callback')();
    }

    for (index => circle in circles.members)
        circle.scale.x = circle.scale.y = CoolUtil.fpsLerp(circle.scale.x, index == catSelInt ? config.circlesSelectionScale : 1, config.circlesSpeed);

    camGame.scroll.x = CoolUtil.fpsLerp(camGame.scroll.x, catSelInt * FlxG.width + config.cameraOffset.x, config.cameraSpeed);
    camGame.scroll.y = CoolUtil.fpsLerp(camGame.scroll.y, selInt * config.optionsSpacing + config.cameraOffset.y, config.cameraSpeed);
}

static final optionsConfig:Array<{name:String, options:Array<JsonOption>}> = [
    {
        name: 'Miscellaneous',
        options: [
            {
                name: 'Controls',
                description: 'Adjust the delay for the game audio',
                type: 'substate',
                path: 'ControlsSubState',
                platform: 'desktop',
                scripted: true
            },
            {
                name: 'Reset Options',
                description: 'Restore Default Settings',
                type: 'substate',
                path: 'ResetOptionsSubState',
                scripted: true
            }
        ]
    },
    {
        name: 'Graphics',
        options: [
            {
                name: 'Low Quality',
                description: 'If checked, disables some background details, decreases loading times and improves performance',
                variable: 'lowQuality',
                type: 'bool',
                initial: false
            },
            {
                name: 'Anti-Aliasing',
                description: 'If unchecked, disables anti-aliasing, increases performance at the cost of sharper visuals',
                variable: 'antialiasing',
                type: 'bool',
                initial: true
            },
            {
                name: 'Shaders',
                description: 'If unchecked, disables shaders. It\'s used for some visual effects, and also CPU intensive for weaker PCs',
                variable: 'shaders',
                type: 'bool',
                initial: true
            },
            {
                name: 'GPU Caching',
                description: 'If checked, allows the GPU to be used for caching textures, decreasing RAM usage. Don\'t turn this on if you have a shitty Graphics Card',
                variable: 'cacheOnGPU',
                type: 'bool',
                initial: true
            },
            {
                name: 'Framerate',
                description: 'Pretty self explanatory, isn\'t it?',
                variable: 'framerate',
                type: 'int',
                min: 30,
                max: 240,
                change: 1,
                initial: 60
            }
        ]
    },
    {
        name: 'Visuals and UI',
        options: [
            {
                name: 'Flashing Lights',
                description: 'Uncheck this if you\'re sensitive to flashing lights!',
                variable: 'flashing',
                type: 'bool',
                initial: true
            },
            {
                name: 'Check for Updates',
                description: 'Turn this on to check for updates when you start the game',
                variable: 'checkForUpdates',
                type: 'bool',
                initial: true
            },
            {
                name: 'Discord Rich Presence',
                description: 'Uncheck this to prevent accidental leaks, it will hide the Application from your \'Playing\' box on Discord',
                variable: 'discordRPC',
                type: 'bool',
                platform: 'desktop',
                initial: true
            }
        ]
    },
    {
        name: 'Gameplay',
        options: [
            {
                name: 'Downscroll',
                description: 'If checked, notes go Down instead of Up, simple enough',
                variable: 'downScroll',
                type: 'bool',
                initial: false
            },
            {
                name: 'Ghost Tapping',
                description: 'If checked, you won\'t get misses from pressing keys while there are no notes able to hit',
                variable: 'ghostTapping',
                type: 'bool',
                initial: true
            },
            {
                name: 'Disable Reset Button',
                description: 'If checked, pressing Reset won\'t do anything',
                variable: 'noReset',
                type: 'bool',
                initial: false
            },
            {
                name: 'Botplay',
                description: 'If checked, the game will basically play itself (This will not prevent the player from dying and will not save the score)',
                variable: 'botplay',
                type: 'bool',
                initial: false
            },
            {
                name: 'Practice Mode',
                description: 'If checked, the game will disable the possibility of dying (This will not save your score)',
                variable: 'practice',
                type: 'bool',
                initial: false
            }
        ]
    }
].concat(Paths.exists('data/options.json') ? Paths.json('data/options').categories : []);