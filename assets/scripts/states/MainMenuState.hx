import funkin.visuals.objects.Alphabet;

import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText.FlxTextBorderStyle;

import sys.Http;

using StringTools;

@typedef OptionData = {
    @:optional var state:String;
    @:optional var variables:StringMap<Dynamic>;
    @:optional var behavior:Void -> Void;
    @:optional var overrideDefaultBehavior:Bool;
};

var selInt:Int = CoolUtil.save.custom.data.mainMenuSelection ?? 0;

var sprites:Array<FlxSprite> = [];

final OPTION_SPACE:Int = 175;

final CAMERA_SPEED:Float = 0.25;

var canSelect:Bool = true;

var options:StringMap<OptionData> = [
    {
        id: 'storyMode',
        state: CoolVars.data.storyMenuState
    },
    {
        id: 'freeplay',
        state: CoolVars.data.freeplayState
    },
    {
        id: 'credits',
        state: 'CreditsState'
    },
    {
        id: 'options',
        state: CoolVars.data.optionsState,
        arguments: [false]
    }
];

function createOption(id:String, index:Int)
{
    var spr:FlxSprite = new FlxSprite(0, index * OPTION_SPACE);
    spr.frames = Paths.getSparrowAtlas('mainMenuState/' + id);
    spr.animation.addByPrefix('basic', 'basic', 24, true);
    spr.animation.addByPrefix('white', 'white', 24, true);
    spr.animation.play('basic');
    spr.x = FlxG.width / 2 - spr.width / 2;

    add(spr);

    sprites.push(spr);
}

function changeSelection()
{
    if (selInt < 0)
        selInt = options.length - 1;

    if (selInt > options.length - 1)
        selInt = 0;

    for (index => spr in sprites)
    {
        spr.animation.play(index == selInt ? 'white' : 'basic', true);
        spr.centerOffsets();
    }
}

function selectMenu(data:OptionData)
{
    canSelect = false;

    if (ClientPrefs.data.flashing)
        FlxFlicker.flicker(sprites[selInt], 0, 0.075);
    
    for (index => spr in sprites)
        if (index != selInt)
            FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.cubeIn});

    FlxG.sound.play(Paths.sound('confirmMenu', true));

    FlxTimer.wait(1, () -> {
        CoolUtil.switchState(new CustomState(data.state, data.arguments, data.arguments));
    });
}

var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuBGYellow'));
add(bg);
bg.scale.set(1.25, 1.25);
bg.scrollFactor.set(0, 0.5 / options.length);
bg.x = FlxG.width / 2 - bg.width / 2;

for (index => option in options)
    createOption(option.id, index);

var versionText:Array<String> = [
    'ALE Psych ' + CoolVars.engineVersion,
    (CoolVars.mobileControls ? '' : 'Press [Ctrl + Shift + ${[for (key in ClientPrefs.controls.engine.switch_mod) if (key == null || key == 0) continue; else FlxKey.toStringMap.get(key)].join(' / ')}] to open the Mods Menu'),
    'Friday Night Funkin\' v0.2.8'
];

var version = new FlxText(10, 0, 0, versionText.join('\n'));
version.setFormat(Paths.font('vcr.ttf'), 17.5, FlxColor.WHITE, 'left', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
version.scrollFactor.set();
version.y = FlxG.height - version.height - 10;
version.borderSize = 1.125;
add(version);

if (ClientPrefs.data.checkForUpdates)
{
    var http = new Http('https://raw.githubusercontent.com/ALE-Psych-Crew/ALE-Psych/main/githubVersion.txt');

    http.onData = function (data:String)
    {
        var onlineVersion:String = data.split('\n')[0].trim();
        
        if (onlineVersion != CoolVars.engineVersion.trim())
        {
            var prefix:String = 'ALE Psych ';

            versionText[0] = prefix + CoolVars.engineVersion + ' [Current Version: ' + onlineVersion + ']';

            version.text = versionText.join('\n');

            version.addFormat(new flixel.text.FlxTextFormat(FlxColor.RED), prefix.length, prefix.length + CoolVars.engineVersion.length);
        }
    }
    
    http.onError = (error) -> {
        debugTrace('During the game version check: $error', 'error');
    }

    http.request();
}

changeSelection();

function onUpdate(elapsed:Float)
{
    game.camGame.scroll.y = CoolUtil.fpsLerp(game.camGame.scroll.y, selInt * OPTION_SPACE - FlxG.height * (0.25 + 0.5 * selInt / options.length), CAMERA_SPEED);

    if (canSelect)
    {
        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(new CustomState(CoolVars.data.initialState));

            FlxG.sound.play(Paths.sound('cancelMenu', true));
        }

        if (Controls.UI_UP_P || Controls.UI_DOWN_P || Controls.MOUSE_WHEEL)
        {
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                selInt--;

            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                selInt++;

            changeSelection();

            FlxG.sound.play(Paths.sound('scrollMenu', true));
        }

        if (Controls.ACCEPT)
        {
            var data:OptionData = options[selInt];

            if (data.behavior != null)
                data.behavior();

            if (!data.overrideDefaultBehavior)
                selectMenu(data);
        }

        if (Controls.ENGINE_CHART)
        {
            canSelect = false;

            CoolUtil.switchState(new CustomState('MasterEditorState'));
        }
    }
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

function onDestroy()
{
    if (CoolVars.mobileControls)
        FlxG.cameras.remove(mobileCamera);

    CoolUtil.save.custom.data.mainMenuSelection = selInt;
}