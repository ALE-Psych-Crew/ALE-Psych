package funkin.substates;

import funkin.visuals.objects.Alphabet;
import funkin.config.SaveFile;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

import flixel.math.FlxPoint;

import utils.cool.FileUtil;

import ale.ui.UIUtils;

import sys.FileSystem;

class ModsMenuSubState extends SubState
{
    var list:FlxTypedGroup<Alphabet>;

    var selInt:Int = 0;

    final NO_MODS:String = '- Disable Mods';

    override function create()
    {
        super.create();

        final bg:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0xFF141820, 0xFF1F232B));
        bg.scrollFactor.set();
        bg.alpha = 0;
        bg.cameras = [subCamera];
        bg.velocity.x = bg.velocity.y = 100;

        add(bg);
        
        FlxTween.tween(bg, {alpha: 0.6}, 0.25, {ease: FlxEase.cubeOut});

        list = new FlxTypedGroup<Alphabet>();
        add(list);

        for (index => folder in FileUtil.readDirectory(Paths.mods).concat([NO_MODS]))
        {
            if ((!FileSystem.isDirectory(Paths.mods + '/' + folder) || folder == '.git') && folder != NO_MODS)
                continue;

            final alphabet:Alphabet = new Alphabet(0, list.members.length * 100, folder);
            alphabet.cameras = [subCamera];

            if (folder == NO_MODS)
                alphabet.color = FlxColor.PINK;

            if (folder == Paths.mod)
                selInt = list.members.length;

            list.add(alphabet);
        }

        changeOption();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (Controls.UI_UP_P || Controls.UI_DOWN_P)
            changeOption(Controls.UI_UP_P ? -1 : 1);
        
        if (Controls.ACCEPT)
        {
            final curOption:String = list.members[selInt].text;

            final save:SaveFile = new SaveFile('data', true);
            save.data.mod = curOption == NO_MODS ? null : curOption;
            save.save();

            close();

            CoolUtil.resetGame();
        }

        for (index => obj in list)
            obj.x = CoolUtil.fpsLerp(obj.x, 200 + -Math.pow(Math.abs(index - selInt), 1.5) * 40, 0.2);

        subCamera.scroll.y = CoolUtil.fpsLerp(subCamera.scroll.y, 100 * selInt - 250, 0.2);
    }

    function changeOption(?change:Int = 0)
    {
        selInt += change;

        if (selInt < 0)
            selInt = list.members.length - 1;

        if (selInt > list.members.length - 1)
            selInt = 0;

        for (index => obj in list)
            obj.alpha = index == selInt ? 1 : 0.3;
    }

    override function destroy()
    {
        super.destroy();

        list = null;
    }
}