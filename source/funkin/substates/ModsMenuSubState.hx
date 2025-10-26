package funkin.substates;

import funkin.visuals.objects.Alphabet;

import core.backend.Mods;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import flixel.util.FlxSave;

import sys.FileSystem;

class ModsMenuSubState extends MusicBeatSubState
{
    var sprites:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

    var selInt:Int = 0;

    var modCamera:FlxCamera;

    var camPos = {x: 0.0, y: 0.0};

    var ignoreFolders:Array<String> = [
        '.git',
        'characters',
        'custom_events',
        'custom_notetypes',
        'data',
        'songs',
        'music',
        'sounds',
        'shaders',
        'videos',
        'images',
        'stages',
        'weeks',
        'fonts',
        'scripts',
        'Disable Mods'
    ];

    var options:Array<String> = [];

    var mobileCamera:FlxCamera;

    override function create()
    {
        super.create();

        if (CoolVars.mobileControls)
        {
            mobileCamera = new ALECamera();
            
            FlxG.cameras.add(mobileCamera, false);

            var buttonMap:Array<Dynamic> = [
                [50, 395, ClientPrefs.controls.ui.up, '< normal', 90],
                [50, 550, ClientPrefs.controls.ui.down, '> normal', 90],
                [1105, 485, ClientPrefs.controls.ui.accept, 'a uppercase']
            ];

            for (button in buttonMap)
            {
                var obj:MobileButton = new MobileButton(button[0], button[1], button[2], button[3]);
                add(obj);
                obj.label.angle = button[4] ?? 0;
                obj.cameras = [mobileCamera];
            }
        }

        if (FileSystem.exists('mods'))
            if (FileSystem.isDirectory('mods'))
                for (folder in FileSystem.readDirectory('mods'))
                    if (FileSystem.isDirectory('mods/' + folder) && !ignoreFolders.contains(folder))
                        options.push(folder);

        options.push('Disable Mods');

        modCamera = new ALECamera();

        FlxG.cameras.add(modCamera, false);
        var bg:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFF141820, 0xFF1F232B));
        add(bg);
        bg.scrollFactor.set();
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.6}, 0.25, {ease: FlxEase.cubeOut});
        bg.cameras = [modCamera];
        bg.velocity.x = bg.velocity.y = 100;

        add(sprites);

        for (option in options)
        {
            var sprite = new Alphabet(0, 0, option);
            sprites.add(sprite);
            sprite.cameras = [modCamera];

            FlxTween.tween(sprite, {x: 20 * options.indexOf(option), y: 125 * options.indexOf(option)}, 0.2, {ease: FlxEase.cubeOut});
        }

        changeShit();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        modCamera.scroll.x = CoolUtil.fpsLerp(modCamera.scroll.x, camPos.x, 0.2);
        modCamera.scroll.y = CoolUtil.fpsLerp(modCamera.scroll.y, camPos.y, 0.2);

        if (Controls.ACCEPT)
        { 
            var save:FlxSave = new FlxSave();
            save.bind('ALEEngineData', CoolUtil.getSavePath(false));
            save.data.currentMod = options[selInt] == 'Disable Mods' ? '' : options[selInt];
            save.flush();

            close();

            CoolUtil.save?.save();
        
            CoolUtil.resetEngine();
        }

        if (Controls.UI_DOWN_P || Controls.UI_UP_P || Controls.MOUSE_WHEEL)
        {
            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
            {
                if (selInt >= sprites.members.length - 1)
                    selInt = 0;
                else
                    selInt++;
            }
        
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
            {
                if (selInt == 0)
                    selInt = sprites.members.length - 1;
                else
                    selInt--;
            }
            
            changeShit();

            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
    }

    override function destroy()
    {
        FlxG.cameras.remove(modCamera);

        FlxG.cameras.remove(mobileCamera);

        super.destroy();
    }

    function changeShit()
    {
        for (sprite in sprites)
        {
            if (sprites.members.indexOf(sprite) == selInt)
            {
                sprite.alpha = 1;

                camPos.x = sprite.x - 100;
                camPos.y = sprite.y - 300;
            } else {
                sprite.alpha = 0.4;
            }
        }
    }
}