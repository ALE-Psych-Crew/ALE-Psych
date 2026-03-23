package funkin.states;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.text.FlxText;
import core.assets.Paths;
import flixel.FlxState;
import api.DesktopAPI;
import utils.CoolUtil;
import flixel.FlxG;
import openfl.Lib;
import String;
import Array;

@:unreflective class AdminState extends FlxState
{
    /**
     * Text displayed on the screen
     */
    var text:FlxText;

    /**
     * qué tai hacien hijo e puta?
     */
    final finalPhrases:Array<String> = [
        'ALE Psych Supremacy',
        'la teoría del ale engine',
        'NOSOTROS SOMOS LOS CALVIN\'',
        'que andai mandando weas de robux hermano',
        'pitos cada viernes',
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'ADRIANA SALTE',
        'ENRIQUE',
        'lime test nokia',
        'La-bu-bu\nLa-bu, la-bu, la-bu-bu\nLa-bu-bu\nLa-bu, la-bu, la-bu-bu\nLa-bu-bu\nLa-bu, la-bu, la-bu-bu',
        '"Me dices obseno?\nBro, como si tú no te tocaras ese güevo\nMis ideas las eyaculo\nNo evito tocarme en ayuno"\n - MarcoPiedra',
        'Translated with DeepL',
        'Si quieres, te puedo hacer unas versiones más estilo programador como tú usas en Haxe.',
        'imaginate si el source code fuera puro json ay sisisisisi',
        'imaginate si el source code fuera puro xml ay nonononono',
        'Psych Engine HUD Lua Script (New 2027)',
        '67',
        FlxG.state.toString(),
        'Polymod Script Exception',
        'hxSehException'
    ];

    /**
     * Phrases found in the text
     */
    final phrases:Array<String> = [
        'Did you need to run the Engine as an administrator...?',
        'Maybe you can complain about this later... (?)',
        'I just hope you\'re not part of a certain community on a certain FNF Engine',
        'You might get me in trouble with them!\n\n(>n<)'
    ];

    /**
     * This happens when the state is created
     */
    override function create()
    {
        super.create();

        phrases.push(finalPhrases[FlxG.random.int(0, finalPhrases.length - 1)]);

        CoolUtil.resizeGame(1500, 500);

        final window = Lib.application.window;

        window.title = 'Friday Night Funkin\' - ALE Psych Engine | New Window*';

        window.resizable = window.maximized = false;

        DesktopAPI.setWindowTitle();
        DesktopAPI.setWindowBorderColor(0, 0, 0);
        DesktopAPI.setWindowTextColor(200, 150, 255);
        DesktopAPI.hideDesktopIcons(true);
        DesktopAPI.hideTaskbar(true);
        DesktopAPI.setWindowRound(1);

        text = new FlxText(0, 0, FlxG.width * 0.9, '', 60);
        text.font = Paths.font('poppins.ttf');
        text.alignment = 'center';

        add(text);

        optimizedText();
    }

    /**
     * Index of the phrase being displayed
     */
    var curPhrase:Int = 0;

    /**
     * This displays the text you want to show on the screen
     */
    function optimizedText()
    {
        if (curPhrase >= phrases.length)
        {
            DesktopAPI.showMessageBox('Polymod Script Exception', 'RuleScript Supermacy', 0x00000010);

            CoolUtil.showPopUp('Polymod Script Exception', 'hxSehException');

            Application.current.window.close();

            return;
        }

        if (curPhrase == phrases.length - 1)
            text.color = FlxColor.CYAN;

        final str:String = phrases[curPhrase];
        
        text.text = str;
        text.screenCenter();

        FlxTween.cancelTweensOf(text);
        FlxTween.cancelTweensOf(text.scale);

        text.alpha = 0;
        text.scale.x = text.scale.y = 0.5;

        final speed:Float = 4;

        FlxTween.tween(text, {alpha: 1}, speed / 2, {
            onComplete: (_) -> {
                FlxTween.tween(text, {alpha: 0}, speed / 2);
            }
        });

        FlxTween.tween(text.scale, {x: 1, y: 1}, speed, {
            onComplete: (_) -> {
                curPhrase++;
                
                optimizedText();
            }
        });
    }
}