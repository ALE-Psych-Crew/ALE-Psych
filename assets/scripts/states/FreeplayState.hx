import funkin.visuals.objects.Alphabet;
import funkin.visuals.objects.HealthIcon;

import flixel.input.keyboard.FlxKey;

import flixel.util.FlxColor;

import utils.Score;

import ALEParserHelper;

using StringTools;

var weeks:Array<ALEWeek> = [];

var songs:Array<Dynamic> = [];

var bg:FlxSprite;

var sprites:FlxTypedGroup<Alphabet>;

var icons:FlxTypedGroup<HealthIcon>;

var textsBG:FlxSprite;
var scoreText:FlxText;
var diffText:FlxText;

var selInt:Int = CoolUtil.save.custom.data.freeplay ?? 0;

var diffSelInt:Int = CoolUtil.save.custom.data.freeplayDifficulty ?? 2;

function onCreate()
{
    bg = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
    add(bg);
    bg.scale.x = bg.scale.y = 1.25;
    bg.scrollFactor.set();

    sprites = new FlxTypedGroup<Alphabet>();
    add(sprites);

    icons = new FlxTypedGroup<HealthIcon>();
    add(icons);

    textsBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
    textsBG.alpha = 0.5;
    add(textsBG);
    textsBG.scrollFactor.set();

    scoreText = new FlxText(0, 0, 0, 'SCORE TEXT', 35);
    scoreText.font = Paths.font('vcr.ttf');
    add(scoreText);
    scoreText.scrollFactor.set();
    
    diffText = new FlxText(0, 0, 0, 'DIFFICULTY TEXT', 25);
    diffText.font = Paths.font('vcr.ttf');
    add(diffText);
    diffText.scrollFactor.set();
    diffText.y = scoreText.y + scoreText.height + 2;

    var tipBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK);
    tipBG.alpha = 0.5;
    add(tipBG);
    tipBG.scrollFactor.set();

    var tipText:FlxText = new FlxText(0, 0, 0, 'Press the [CONTROL] key to access the Gameplay Changers menu', 20);
    tipText.font = Paths.font('vcr.ttf');
    add(tipText);
    tipText.scrollFactor.set();
    tipText.x = FlxG.width / 2 - tipText.width / 2;

    tipBG.scale.y = tipText.height + 10;
    tipBG.updateHitbox();
    tipBG.y = FlxG.height - tipBG.height;

    tipText.y = tipBG.y + tipBG.height / 2 - tipText.height / 2;

    var ignoreFiles:Array<String> = [];

    var directories:Array<String> = [Paths.modFolder() + '/weeks'];

    if (CoolVars.data.loadDefaultWeeks)
        directories.push('assets/weeks');

    for (path in directories)
        if (FileSystem.exists(path) && FileSystem.isDirectory(path))
            for (week in FileSystem.readDirectory(path))
                if (week.endsWith('.json') && !ignoreFiles.contains(week))
                {
                    weeks.push(ALEParserHelper.getALEWeek(week.substring(0, week.length - 5)));

                    ignoreFiles.push(week);
                }

    for (week in weeks)
        if (!weekIsLocked(week))
            for (song in week.songs)
                songs.push(
                    {
                        name: song.name,
                        icon: song.icon,
                        color: CoolUtil.colorFromArray(song.color),
                        difficulties: week.difficulties
                    }
                );

    for (index => song in songs)
    {
        var alpha:Alphabet = new Alphabet(30 * index + 150, 175 * index + 300, song.name);
        sprites.add(alpha);

        var icon:HealthIcon = new HealthIcon(song.icon);
        icons.add(icon);
        icon.scrollFactor.set(1, 1);
        icon.x = alpha.x + alpha.width + 15;
        icon.y = alpha.y + alpha.height / 2 - icon.height / 2;
    }

    selInt = FlxMath.bound(selInt, 0, songs.length - 1);

    bg.color = songs[selInt].color;

    changeShit();
}

function changeShit()
{
    for (index => sprite in sprites)
    {
        sprite.alpha = icons.members[index].alpha = index == selInt ? 1 : 0.5;
    }

    FlxTween.cancelTweensOf(bg);
    FlxTween.color(bg, 1, bg.color, songs[selInt].color, {ease: FlxEase.cubeOut});

    changeDiff();
}

function changeDiff()
{
    diffSelInt = FlxMath.bound(diffSelInt, 0, songs[selInt].difficulties.length - 1);

    var formmatedSong:String = CoolUtil.formatToSongPath(songs[selInt].name.trim() + '-' + songs[selInt].difficulties[diffSelInt].trim());

    scoreText.text = 'SCORE: ' + (Score.song.get(formmatedSong) ?? 0) + ' (' + CoolUtil.floorDecimal(Score.rating.get(formmatedSong) * 100 ?? 0, 2) + '%)';

    var several:Bool = songs[selInt].difficulties.length > 1;
    
    diffText.text = (several ? '< ' : '') + songs[selInt].difficulties[diffSelInt].toUpperCase() + (several ? ' >' : '');

    textsBG.scale.x = Math.max(scoreText.width, diffText.width) + 20;
    textsBG.scale.y = scoreText.height + 2 + diffText.height + 10;
    textsBG.updateHitbox();
    textsBG.x = FlxG.width - textsBG.width;

    scoreText.x = textsBG.x + textsBG.width / 2 - scoreText.width / 2;
    scoreText.y = textsBG.height / 2 - (scoreText.height + 2 + diffText.height) / 2;

    diffText.x = textsBG.x + textsBG.width / 2 - diffText.width / 2;
    diffText.y = diffText.y = scoreText.y + scoreText.height + 2;
}

function weekIsLocked(week:ALEWeek):Bool
{
    return week.locked && week.weekBefore.length > 0 && !utils.Score.completed.exists(week.weekBefore);
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    if (canSelect)
    {
        if (Controls.UI_UP_P || Controls.UI_DOWN_P || Controls.MOUSE_WHEEL)
        {
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                if (selInt <= 0)
                    selInt = sprites.members.length - 1;
                else
                    selInt--;

            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                if (selInt >= sprites.members.length - 1)
                    selInt = 0;
                else
                    selInt++;

            changeShit();

            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
        {
            if (Controls.UI_LEFT_P)
                if (diffSelInt <= 0)
                    diffSelInt = songs[selInt].difficulties.length - 1;
                else
                    diffSelInt--;

            if (Controls.UI_RIGHT_P)
                if (diffSelInt >= songs[selInt].difficulties.length - 1)
                    diffSelInt = 0;
                else
                    diffSelInt++;

            changeDiff();
        }

        if (Controls.ACCEPT)
        {
            PlayState.isStoryMode = false;
            
            CoolUtil.loadSong(songs[selInt].name, CoolUtil.formatToSongPath(songs[selInt].difficulties[diffSelInt]));
        }

        if (Controls.BACK)
        {
            canSelect = false;

            FlxG.sound.play(Paths.sound('cancelMenu'));

            CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));
        }

        if (FlxG.keys.justPressed.CONTROL || (CoolVars.mobileControls && MobileControls.anyJustPressed([FlxKey.CONTROL])))
            CoolUtil.openSubState(new CustomSubState('GameplayChangersSubState'));
    }

    game.camGame.scroll.x = CoolUtil.fpsLerp(game.camGame.scroll.x, selInt * 30, 0.25);
    game.camGame.scroll.y = CoolUtil.fpsLerp(game.camGame.scroll.y, selInt * 175, 0.25);
}

var mobileCamera:FlxCamera;

function postCreate()
{
    if (CoolVars.mobileControls)
    {
        mobileCamera = new ALECamera();
        
        FlxG.cameras.add(mobileCamera, false);

        var buttonMap:Array<Dynamic> = [
            [50, 485, ClientPrefs.controls.ui.left, '< normal'],
            [360, 485, ClientPrefs.controls.ui.right, '> normal'],
            [205, 395, ClientPrefs.controls.ui.up, '< normal', 90],
            [205, 550, ClientPrefs.controls.ui.down, '> normal', 90],
            [1105, 485, ClientPrefs.controls.ui.accept, 'a uppercase'],
            [950, 485, ClientPrefs.controls.ui.back, 'b uppercase'],
            [795, 485, [FlxKey.CONTROL], 'c uppercase']
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

    CoolUtil.save.custom.data.freeplay = selInt;
    CoolUtil.save.custom.data.freeplayDifficulty = diffSelInt;
    CoolUtil.save.custom.flush();
}