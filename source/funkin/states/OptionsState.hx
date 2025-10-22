package funkin.states;

import core.structures.OptionsCategory;
import core.structures.OptionsOption;

import core.enums.OptionsBasicType;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

import funkin.visuals.objects.Alphabet;
import funkin.visuals.objects.OptionText;

typedef SelInt =
{
    var menus:Int;
    var options:Int;
}

class OptionsState extends MusicBeatState
{
    var catSprites:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
    
    var optSprites:FlxTypedGroup<OptionText> = new FlxTypedGroup<OptionText>();
    
    var canSelect:Dynamic = {menus: true, options: true};
    
    static var selInt:SelInt = {menus: 0, options: 0};
    
    var categories:Array<OptionsCategory>;
    
    var descriptions:FlxText;
    var descriptionsBG:FlxSprite;

    var inPlayState:Bool = false;

    override public function new(inPlayState:Bool = false)
    {
        super();

        this.inPlayState = inPlayState;
    }

    var mobileCamera:FlxCamera;

    function createPost()
    {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
        add(bg);
        bg.scrollFactor.set();
        bg.scale.x = bg.scale.y = 1.125;
        bg.color = FlxColor.fromRGB(50, 60, 80);
    
        add(catSprites);
    
        add(optSprites);
    
        descriptions = new FlxText(0, 0, FlxG.width - 100, '');
        descriptions.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, 'center');
        descriptions.scrollFactor.set();
        descriptions.antialiasing = ClientPrefs.data.antialiasing;
        descriptions.x = FlxG.width / 2 - descriptions.width / 2;
        descriptions.y = FlxG.height - descriptions.height - 50;
        descriptions.visible = false;
    
        descriptionsBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        descriptionsBG.scrollFactor.set();
        descriptionsBG.alpha = 0.5;
        descriptionsBG.scale.x = descriptions.width + 20;
        descriptionsBG.scale.y = descriptions.height + 20;
        descriptionsBG.updateHitbox();
        descriptionsBG.x = descriptions.x - 10;
        descriptionsBG.y = descriptions.y - 10;
        descriptionsBG.visible = false;
    
        add(descriptionsBG);
        add(descriptions);
    
        spawnCategories();
    }

    var pressTimer:Dynamic = {left: 0, right: 0};

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (canSelect.menus)
        {
            if (Controls.UI_DOWN_P || Controls.UI_UP_P || Controls.MOUSE_WHEEL)
            {
                if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                {
                    if (selInt.menus >= catSprites.length - 1)
                        selInt.menus = 0;
                    else
                        selInt.menus++;
                }
                
                if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                {
                    if (selInt.menus <= 0)
                        selInt.menus = catSprites.length - 1;
                    else
                        selInt.menus--;
                }
    
                changeCategory();
    
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }
    
            if (Controls.ACCEPT)
            {
                var curMenu = categories[selInt.menus];
    
                if (curMenu.stateData == null)
                {
                    spawnOptions();
    
                    canSelect.menus = false;
                    canSelect.options = true;
                    
                    FlxTween.cancelTweensOf(FlxG.camera.scroll);
                    FlxTween.tween(FlxG.camera.scroll, {x: FlxG.width}, 0.5, {ease: FlxEase.circInOut});
    
                    FlxG.sound.play(Paths.sound('confirmMenu'), 0.5);
                } else {
                    if (curMenu.stateData.subState != null)
                    {
                        if (curMenu.stateData.script)
                            CoolUtil.openSubState(new CustomSubState(curMenu.stateData.subState));
                        else
                            CoolUtil.openSubState(Type.createInstance(Type.resolveClass(curMenu.stateData.subState), []));
                    } else if (curMenu.stateData.state != null) {
                        if (curMenu.stateData.script)
                            CoolUtil.switchState(new CustomState(curMenu.stateData.state));
                        else
                            CoolUtil.switchState(Type.createInstance(Type.resolveClass(curMenu.stateData.state), []));
                    }
                }
            }

            if (Controls.BACK)
            {
                if (inPlayState)
                {
                    CoolUtil.switchState(new funkin.states.PlayState());

                    shouldClearMemory = false;
                } else {
                    CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));
                }

                FlxG.sound.play(Paths.sound('cancelMenu'));

                canSelect.menus = false;
            }
        } else if (canSelect.options) {
            if ((Controls.UI_DOWN_P || Controls.UI_UP_P || Controls.MOUSE_WHEEL) && !FlxG.keys.pressed.SHIFT)
            {
                if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_UP)
                {
                    if (selInt.options >= optSprites.members.length - 1)
                        selInt.options = 0;
                    else
                        selInt.options++;
                }
                
                if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_DOWN)
                {
                    if (selInt.options <= 0)
                        selInt.options = optSprites.members.length - 1;
                    else
                        selInt.options--;
                }
    
                changeOption();
    
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }

            if (Controls.UI_RIGHT || Controls.UI_LEFT || (FlxG.keys.pressed.SHIFT && Controls.MOUSE_WHEEL))
            {
                var option:OptionText = optSprites.members[selInt.options];

                if (option.type != BOOL)
                {
                    if (Controls.UI_RIGHT_P || pressTimer.right >= 0.75 || Controls.MOUSE_WHEEL_DOWN)
                        option.moveRight();
                    
                    if (Controls.UI_LEFT_P || pressTimer.left >= 0.75 || Controls.MOUSE_WHEEL_UP)
                        option.moveLeft();
                }
            }

            if (Controls.UI_LEFT)
                pressTimer.left += elapsed;

            if (Controls.UI_RIGHT)
                pressTimer.right += elapsed;

            if (Controls.UI_RIGHT_R)
                pressTimer.right = 0;

            if (Controls.UI_LEFT_R)
                pressTimer.left = 0;
    
            if (Controls.ACCEPT)
            {
                var option:OptionText = optSprites.members[selInt.options];

                if (option.type == BOOL)
                    option.value = !option.value;
            }
    
            if (Controls.BACK)
            {
                CoolUtil.save.savePreferences();
                
                CoolUtil.save.loadPreferences();

                spawnCategories();
    
                canSelect.menus = true;
                canSelect.options = false;
    
                FlxTween.cancelTweensOf(FlxG.camera.scroll);
                FlxTween.tween(FlxG.camera.scroll, {x: 0}, 0.5, {ease: FlxEase.circInOut});

                FlxG.sound.play(Paths.sound('cancelMenu'));
            }
        }
    }

    function spawnCategories()
    {
        for (sprite in optSprites)
        {
            FlxTween.cancelTweensOf(sprite);
    
            FlxTween.tween(sprite, {alpha: 0}, 0.5, {ease: FlxEase.circInOut});
        }
    
        catSprites.clear();
    
        for (category in categories)
        {
            var index:Int = categories.indexOf(category);
            var offIndex:Int = index - selInt.menus;
    
            var alpha:Alphabet = new Alphabet(165 - Math.pow(1.75, Math.abs(offIndex)) * 25, 300 + 100 * offIndex, category.name + (category.stateData == null ? ' >' : ''));
            alpha.scaleY = alpha.scaleX = 0.85;
            catSprites.add(alpha);
            alpha.alpha = 0;
            FlxTween.tween(alpha, {alpha: index == selInt.menus ? 1 : 0.5}, 0.5, {ease: FlxEase.circInOut});
        }
    
        changeCategory();
    }

    function spawnOptions()
    {
        for (sprite in catSprites)
        {
            FlxTween.cancelTweensOf(sprite);
            
            FlxTween.tween(sprite, {alpha: 0}, 0.5, {ease: FlxEase.circInOut});
        }
    
        selInt.options = 0;
        
        optSprites.clear();
    
        for (option in categories[selInt.menus].options)
        {
            var index:Int = categories[selInt.menus].options.indexOf(option);
            var offIndex:Int = index - selInt.options;
    
            var sprite:OptionText = new OptionText(option);
            optSprites.add(sprite);
            sprite.x = FlxG.width + 175 - Math.pow(1.75, Math.abs(offIndex)) * 25;
            sprite.y = 300 + 75 * offIndex;
        }
    
        changeOption();
    }

    function changeCategory()
    {
        for (sprite in catSprites)
        {
            FlxTween.cancelTweensOf(sprite);
    
            var index:Int = catSprites.members.indexOf(sprite);
            var offIndex:Int = index - selInt.menus;
    
            if (index == selInt.menus)
            {   
                FlxTween.cancelTweensOf(catSprites);
    
                sprite.alpha = 1;
            } else {
                sprite.alpha = 0.5;
            }
    
            FlxTween.tween(sprite, {x: 165 - Math.pow(1.75, Math.abs(offIndex)) * 25, y: 300 + 100 * offIndex}, 0.25, {ease: FlxEase.cubeOut});
        }
    }

    function changeOption()
    {
        for (sprite in optSprites)
        {
            FlxTween.cancelTweensOf(sprite);
    
            var index:Int = optSprites.members.indexOf(sprite);
            var offIndex:Int = index - selInt.options;
    
            if (index == selInt.options)
            {
                sprite.alpha = 1;
            } else {
                sprite.alpha = 0.5;
            }
    
            FlxTween.tween(sprite, {x: FlxG.width + 175 - Math.pow(1.75, Math.abs(offIndex)) * 25, y: 300 + 75 * offIndex}, 0.25, {ease: FlxEase.cubeOut});
        }
    }

    override public function create()
    {
        categories = [
            #if !mobile
            {
                name: 'Controls',
                stateData: {
                    script: true,
                    subState: 'ControlsSubState'
                }
            },
            #end
            {
                name: 'Note Offset',
                stateData: {
                    script: true,
                    state: 'NoteOffsetState'
                }
            },
            {
                name: 'Graphics',
                options: [
                    {
                        name: 'Low Quality',
                        description: 'If checked, disables some background details, decreases loading times and improves performance.',
                        variable: 'lowQuality',
                        type: BOOL,
                        initialValue: false
                    },
                    {
                        name: 'Anti-Aliasing',
                        description: 'If unchecked, disables anti-aliasing, increases performance at the cost of sharper visuals.',
                        variable: 'antialiasing',
                        type: BOOL,
                        initialValue: true
                    },
                    {
                        name: 'Shaders',
                        description: 'If unchecked, disables shaders. It\'s used for some visual effects, and also CPU intensive for weaker PCs.',
                        variable: 'shaders',
                        type: BOOL,
                        initialValue: true
                    },
                    {
                        name: 'GPU Caching',
                        description: 'If checked, allows the GPU to be used for caching textures, decreasing RAM usage. Don\'t turn this on if you have a shitty Graphics Card.',
                        variable: 'cacheOnGPU',
                        type: BOOL,
                        initialValue: true
                    },
                    {
                        name: 'Framerate',
                        description: 'Pretty self explanatory, isn\'t it?',
                        variable: 'framerate',
                        type: INTEGER,
                        min: 30,
                        max: 240,
                        change: 1,
                        initialValue: 60
                    }
                ]
            },
            {
                name: 'Visuals and UI',
                options: [
                    {
                        name: 'Note Splash Opacity',
                        description: 'How much transparent should the Note Splashes be.',
                        variable: 'splashAlpha',
                        type: INTEGER,
                        min: 0,
                        max: 100,
                        change: 1,
                        initialValue: 60
                    },
                    {
                        name: 'Flashing Lights',
                        description: 'Uncheck this if you\'re sensitive to flashing lights!',
                        variable: 'flashing',
                        type: BOOL,
                        initialValue: true
                    },
                    {
                        name: 'Pause Music',
                        description: '',
                        variable: 'pauseMusic',
                        type: STRING,
                        strings: [
                            'None',
                            'Breakfast',
                            'Tea Time'
                        ],
                        initialValue: 'Tea Time'
                    },
                    {
                        name: 'Check for Updates',
                        description: 'Turn this on to check for updates when you start the game.',
                        variable: 'checkForUpdates',
                        type: BOOL,
                        initialValue: true
                    },
                    {
                        name: 'Discord Rich Presence',
                        description: 'Uncheck this to prevent accidental leaks, it will hide the Application from your "Playing" box on Discord.',
                        variable: 'discordRPC',
                        type: BOOL,
                        initialValue: true
                    }
                ]
            },
            {
                name: 'Gameplay',
                options: [
                    {
                        name: 'Downscroll',
                        description: 'If checked, notes go Down instead of Up, simple enough.',
                        variable: 'downScroll',
                        type: BOOL,
                        initialValue: false
                    },
                    {
                        name: 'Ghost Tapping',
                        description: 'If checked, you won\'t get misses from pressing keys while there are no notes able to hit.',
                        variable: 'ghostTapping',
                        type: BOOL,
                        initialValue: true
                    },
                    {
                        name: 'Disable Reset Button',
                        description: 'If checked, pressing Reset won\'t do anything.',
                        variable: 'noReset',
                        type: BOOL,
                        initialValue: false
                    }
                ]
            }
        ];

        if (Paths.exists('options.json'))
        {
            var jsonData:Dynamic = Paths.json('options');

            if (jsonData.categories is Array)
                for (cat in cast(jsonData.categories, Array<Dynamic>))
                {
                    var i:Int = -1;
                    for (index => category in categories)
                    {
                        if (category.name == cast(cat.name, String))
                        {
                            i = index;
                            break;
                        }
                    }

                    if (cat.stateData != null)
                    {
                        if (i >= 0)
                            categories[i].stateData = cat.stateData;
                        else
                            categories.push(cast cat);
                    }
                    else
                    {
                        for (option in cast(cat.options, Array<Dynamic>))
                        {
                            if (Reflect.fields(ClientPrefs.custom).contains(option.variable))
                                Reflect.setField(option, 'initialValue', Reflect.field(ClientPrefs.custom, option.variable));
                        }

                        if (i >= 0)
                            for (option in cast(cat.options, Array<Dynamic>))
                                categories[i].options.push(option);
                        else
                            categories.push(cast cat);
                    }
                }
        }

        createPost();
        
        super.create();
        
        if (CoolVars.mobileControls)
        {
            mobileCamera = new FlxCamera();
            mobileCamera.bgColor = FlxColor.TRANSPARENT;
            FlxG.cameras.add(mobileCamera, false);

            var buttonMap:Array<Dynamic> = [
                [50, 485, ClientPrefs.controls.ui.left, '< normal'],
                [360, 485, ClientPrefs.controls.ui.right, '> normal'],
                [205, 395, ClientPrefs.controls.ui.up, '< normal', 90],
                [205, 550, ClientPrefs.controls.ui.down, '> normal', 90],
                [1105, 485, ClientPrefs.controls.ui.accept, 'a uppercase'],
                [950, 485, ClientPrefs.controls.ui.back, 'b uppercase']
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

    override function destroy()
    {
        if (CoolVars.mobileControls)
            FlxG.cameras.remove(mobileCamera);

        super.destroy();
    }
}