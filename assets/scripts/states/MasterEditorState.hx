import funkin.editors.ChartingState;
import funkin.editors.CharacterEditorState;
import funkin.editors.WeekEditorState;
import funkin.editors.MenuCharacterEditorState;
import funkin.editors.DialogueEditorState;
import funkin.editors.DialogueCharacterEditorState;
import funkin.editors.NoteSplashDebugState;

import funkin.visuals.objects.Alphabet;
import funkin.visuals.game.Character;

var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
add(bg);
bg.scrollFactor.set();
bg.color = FlxColor.fromRGB(50, 50, 50);
bg.scale.x = bg.scale.y = 1.125;

var options:Array<String> = ['Chart', 'Character', 'Week', 'Menu Character', 'Dialogue', 'Dialogue Portrait', 'Note Splash'];

var toSelect:Array<Alphabet> = [];

for (index => opt in options)
{
    var alpha:Alphabet = new Alphabet(0, index * 100, opt + ' Editor');
    add(alpha);
    alpha.x = FlxG.width / 2 - alpha.width / 2;
    alpha.alpha = 0.25;

    toSelect.push(alpha);
}

var selInt:Int = CoolUtil.save.custom.data.masterEditor ?? 0;

function changeShit()
{
    for (index => obj in toSelect)
    {
        obj.alpha = selInt == index ? 1 : 0.25;
    }
}

changeShit();

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    game.camGame.scroll.y = CoolUtil.fpsLerp(game.camGame.scroll.y, selInt * 100 - FlxG.height * (0.25 + 0.5 * selInt / options.length), 0.3);

    if (canSelect)
    {
        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));

            FlxG.sound.play(Paths.sound('cancelMenu'));
        }

        if (Controls.ACCEPT)
        {
            canSelect = false;

            switch (options[selInt])
            {
				case 'Chart':
					CoolUtil.switchState(new ChartingState());
				case 'Character':
					CoolUtil.switchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 'Week':
					CoolUtil.switchState(new WeekEditorState());
				case 'Menu Character':
					CoolUtil.switchState(new MenuCharacterEditorState());
				case 'Dialogue':
					CoolUtil.switchState(new DialogueEditorState());
				case 'Dialogue Portrait':
					CoolUtil.switchState(new DialogueCharacterEditorState());
				case 'Note Splash':
					CoolUtil.switchState(new NoteSplashDebugState());
            }
        }

        if (Controls.UI_UP_P || Controls.UI_DOWN_P || Controls.MOUSE_WHEEL)
        {
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                if (selInt <= 0)
                    selInt = options.length - 1;
                else
                    selInt--;

            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                if (selInt >= options.length - 1)
                    selInt = 0;
                else
                    selInt++;

            FlxG.sound.play(Paths.sound('scrollMenu'));

            changeShit();
        }
    }
}

function onDestroy()
{
    CoolUtil.save.custom.data.masterEditor = selInt;
    CoolUtil.save.custom.flush();
}