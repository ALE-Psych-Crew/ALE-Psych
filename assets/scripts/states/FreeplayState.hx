import funkin.visuals.objects.Alphabet;

import funkin.visuals.game.Icon;

import utils.Score;

import flixel.math.FlxPoint;

import utils.ALEFormatter;

using StringTools;

final weeks:Array<ALEWeek> = [];

final weekNames:Array<ALEWeek> = [];

if (FlxG.sound.music == null || !FlxG.sound.music.playing)
    FlxG.sound.playMusic(Paths.music('freakyMenu'));

for (week in Paths.readDirectory('data/weeks', CoolVars.data.loadDefaultWeeks ? 'multiple' : 'unique'))
    if (week.endsWith('.json'))
    {
        var name:String = week.substring(0, week.length - 5);

        if (weekNames.contains(name))
            continue;

        weeks.push(ALEFormatter.getWeek(name));

        weekNames.push(name);
    }

function weekIsLocked(week:ALEWeek):Bool
{
    return week.locked && week.weekBefore.length > 0 && !Score.completed.exists(week.weekBackground);
}

final songs:Array<ALEWeekSong> = [];

for (week in weeks)
    if (!weekIsLocked(week) && !week.hideFreeplay)
        for (song in week.songs)
            songs.push(
                {
                    name: song.name,
                    icon: song.icon,
                    color: CoolUtil.colorFromArray(song.color),
                    difficulties: week.difficulties
                }
            );

var sprites:Array<FlxTypedSpriteGroup<FlxSprite>> = [];

final SONG_SPACE:FlxPoint = FlxPoint.get(50, 150);

function createSongSprites(song:ALEWeekSong, index:Int)
{
    var group:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup<FlxSprite>();
    add(group);

    var text:Alphabet = new Alphabet(0, 0, song.name);
    group.add(text);
    
    var icon:Icon = new Icon('opponent', song.icon);
    icon.x = text.width + 20;
    icon.y = text.height / 2 - icon.height / 2;
    group.add(icon);

    group.x = SONG_SPACE.x * index;
    group.y = SONG_SPACE.y * index;

    sprites.push(group);
}

var selInt:Int = CoolUtil.save.custom.data.freeplaySelection ?? 0;

selInt = FlxMath.bound(selInt, 0, songs.length - 1);

var diffSelInt:Int = CoolUtil.save.custom.data.freeplayDifficultySelection ?? 1;

var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menuBG'));
add(bg);
bg.scrollFactor.set();
bg.color = songs[selInt].color;

for (index => song in songs)
    createSongSprites(song, index);

var scoreBG:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
scoreBG.scrollFactor.set();
scoreBG.alpha = 0.5;
add(scoreBG);

var scoreText:FlxText = new FlxText(0, 0, 0, '', 35);
scoreText.font = Paths.font('vcr.ttf');
scoreText.scrollFactor.set();
add(scoreText);

var difficultyText:FlxText = new FlxText(0, 0, 0, '', 25);
difficultyText.font = Paths.font('vcr.ttf');
difficultyText.scrollFactor.set();
add(difficultyText);

function changeDifficulty()
{
    var curDiffs:Array<String> = songs[selInt].difficulties;

    if (diffSelInt < 0)
        diffSelInt = curDiffs.length - 1;

    if (diffSelInt > curDiffs.length - 1)
        diffSelInt = 0;

    var formattedSong:String = CoolUtil.formatToSongPath(songs[selInt].name.trim() + '-' + curDiffs[diffSelInt].trim());
    
    scoreText.text = 'SCORE: ' + (Score.song.get(formattedSong) ?? 0) + ' (' + CoolUtil.floorDecimal(Score.rating.get(formattedSong) ?? 0, 2) + '%)';

    var severalDifficulties:Bool = curDiffs.length > 1;

    difficultyText.text = (severalDifficulties ? '< ' : '') + curDiffs[diffSelInt].toUpperCase() + (severalDifficulties ? ' >' : '');
    
    scoreBG.scale.x = Math.max(scoreText.width, difficultyText.width) + 20;
    scoreBG.scale.y = scoreText.height + 2 + difficultyText.height + 10;
    scoreBG.updateHitbox();
    scoreBG.x = FlxG.width - scoreBG.width;

    scoreText.x = scoreBG.x + scoreBG.width / 2 - scoreText.width / 2;
    scoreText.y = scoreBG.height / 2 - (scoreText.height + 2 + difficultyText.height) / 2;

    difficultyText.x = scoreBG.x + scoreBG.width / 2 - difficultyText.width / 2;
    difficultyText.y = scoreText.y + scoreText.height + 2;
}

function changeSelection()
{
    if (selInt < 0)
        selInt = sprites.length - 1;

    if (selInt > sprites.length - 1)
        selInt = 0;

    for (index => group in sprites)
    {
        group.alpha = index == selInt ? 1 : 0.5;

        if (index == selInt)
        {
            FlxTween.cancelTweensOf(bg);

            FlxTween.color(bg, 0.5, bg.color, songs[index].color, {ase: FlxEase.cubeOut});
        }
    }

    changeDifficulty();
}

changeSelection();

var canSelect:Bool = true;

final CAMERA_OFFSET:FlxPoint = FlxPoint.get(150, 300);
final CAMERA_SPEED:FlxPoint = FlxPoint.get(0.25, 0.25);

function onUpdate(elapsed:Float)
{
    camGame.scroll.x = CoolUtil.fpsLerp(camGame.scroll.x, selInt * SONG_SPACE.x - CAMERA_OFFSET.x, CAMERA_SPEED.x);
    camGame.scroll.y = CoolUtil.fpsLerp(camGame.scroll.y, selInt * SONG_SPACE.y - CAMERA_OFFSET.y, CAMERA_SPEED.y);

    if (canSelect)
    {
        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));

            FlxG.sound.play(Paths.sound('cancelMenu', true));
        }

        if (Controls.ACCEPT)
        {
            canSelect = false;

            CoolUtil.switchState(new PlayState('freeplay', [songs[selInt].name], songs[selInt].difficulties[diffSelInt]));

            FlxG.sound.music?.pause();
        }

        if (Controls.UI_DOWN_P || Controls.UI_UP_P || (Controls.MOUSE_WHEEL && !FlxG.keys.pressed.SHIFT))
        {
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                selInt--;

            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                selInt++;

            changeSelection();

            FlxG.sound.play(Paths.sound('scrollMenu', true));
        }

        if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P || (Controls.MOUSE_WHEEL && FlxG.keys.pressed.SHIFT))
        {
            if (Controls.UI_LEFT_P || Controls.MOUSE_WHEEL_UP)
                diffSelInt--;

            if (Controls.UI_RIGHT_P || Controls.MOUSE_WHEEL_DOWN)
                diffSelInt++;

            changeDifficulty();
        }
    }
}

function onDestroy()
{
    CoolUtil.save.custom.data.freeplaySelection = selInt;
    CoolUtil.save.custom.data.freeplayDifficultySelection = diffSelInt;
}