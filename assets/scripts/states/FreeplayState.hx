import funkin.visuals.objects.Alphabet;
import funkin.visuals.game.Icon;

import funkin.config.Score;

import utils.Formatter;

using StringTools;

@:typedef JsonFreeplay = {
    var directory:String;

    var bg:JsonSprite;

    var cameraOffset:Point;
    var songsSpacing:Point;

    var cameraSpeed:Float;
    var changeBGColor:Bool;

    var infoCorner:String;
};

final config:JsonFreeplay = Paths.json('data/menus/freeplay');

final songs:Array<Dynamic> = [];

var bg:FlxSprite;

var sprites:FlxTypedGroup<FlxTypedSpriteGroup<FlxSprite>>;

var selInt:Int = 0;
var diffSelInt:Int = 1;

var infoBG:FlxSprite;
var scoreText:FlxText;
var difficultyText:FlxText;

function checkLocked(week:JsonWeek)
    return week.locked;

function onCreate()
{
    if (Conductor.music == null)
        Conductor.play(Paths.music('freakyMenu'), CoolVars.meta.bpm);
        
    bg = CoolUtil.spriteFromJson(null, config.bg, 'menus/' + config.directory + '/');
    add(bg);

    final weekNames:String = [];

    final weeks:Array<JsonWeek> = [];

    for (week in Paths.readDirectory('data/weeks', CoolVars.data.loadDefaultWeeks ? 'multiple' : 'unique'))
    {
        if (!week.endsWith('.json'))
            continue;

        var name:String = week.substring(0, week.length - 5);

        if (weekNames.contains(name))
            continue;

        weeks.push(Formatter.getWeek(name));

        weekNames.push(name);
    }

    sprites = new FlxTypedGroup<FlxTypedSpriteGroup<FlxSprite>>();
    add(sprites);

    for (week in weeks)
    {
        if (week.hideFreeplay || checkLocked(week))
            continue;

        for (song in week.songs)
            songs.push({
                name: song.name,
                icon: song.icon,
                color: CoolUtil.colorFromString(song.color),
                difficulties: week.difficulties
            });
    }

    for (index => song in songs)
    {
        final group:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup<FlxSprite>(index * config.songsSpacing.x, index * config.songsSpacing.y);
        sprites.add(group);

        final text:Alphabet = new Alphabet(0, 0, song.name);
        group.add(text);

        final icon:Icon = new Icon(song.icon, 'opponent');
        icon.x = group.x + text.width + 10;
        icon.y = group.y + text.height / 2 - icon.height / 2;

        final beatHit:Int -> Void = icon.beatHit;
        
        icon.beatHit = null;
        
        add(icon);

        group.metadata.set('setBeatHit', (able) -> icon.beatHit = able ? beatHit : null );
    }

    if (config.changeBGColor)
        bg.color = songs[selInt].color;

    infoBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
    infoBG.scrollFactor.set();
    infoBG.alpha = 0.5;
    add(infoBG);

    scoreText = new FlxText(0, 5, 0, 'SCORE', 35);
    scoreText.font = Paths.font('vcr.ttf');
    scoreText.scrollFactor.set();
    add(scoreText);

    difficultyText = new FlxText(0, scoreText.y + scoreText.height + 2, 0, '< DIFF >', 25);
    difficultyText.font = Paths.font('vcr.ttf');
    difficultyText.scrollFactor.set();
    add(difficultyText);

    changeOption();
}

function changeOption(?change:Int = 0)
{
    selInt += change;

    if (selInt < 0)
        selInt = songs.length - 1;

    if (selInt > songs.length - 1)
        selInt = 0;

    for (index => obj in sprites.members)
    {
        obj.alpha = index == selInt ? 1 : 0.5;

        final beatHit = obj.metadata.get('setBeatHit');
        
        if (beatHit != null)
            beatHit(index == selInt);

        if (index == selInt && config.changeBGColor)
        {
            FlxTween.cancelTweensOf(bg);
            FlxTween.color(bg, 0.5, bg.color, songs[index].color, {ease: FlxEase.cubeOut});
        }
    }

    changeDifficulty();
}

function changeDifficulty(?change:Int = 0)
{
    final difficulties:Array<String> = songs[selInt].difficulties;

    diffSelInt += change;

    if (diffSelInt < 0)
        diffSelInt = difficulties.length - 1;

    if (diffSelInt > difficulties.length - 1)
        diffSelInt = 0;

    final score:SongScore = Score.getSong(songs[selInt].name, difficulties[diffSelInt]);

    scoreText.text = 'SCORE: ' + score.score + ' (' + CoolUtil.floorDecimal(score.accuracy, 2) + '%)';
    difficultyText.text = '< ' + difficulties[diffSelInt].trim().toUpperCase() + ' >';

    infoBG.scale.set(Math.max(scoreText.width, difficultyText.width) + 30, scoreText.height + difficultyText.height + 2 + 10);
    infoBG.updateHitbox();

    final splitTexture = config.infoCorner.split('_');

    final yCorner:String = splitTexture[0];
    final xCorner:String = splitTexture[1];

    infoBG.y = switch (yCorner)
    {
        case 'top':
            0;

        case 'bottom':
            FlxG.height - infoBG.height;

        default:
            0;
    }

    infoBG.x = switch (xCorner)
    {
        case 'left':
            0;

        case 'center':
            FlxG.width / 2 - infoBG.width / 2;

        case 'right':
            FlxG.width - infoBG.width;

        default:
            0;
    }

    if (scoreText.width >= difficultyText.width)
    {
        scoreText.x = infoBG.x + 15;
        difficultyText.x = scoreText.x + scoreText.width / 2 - difficultyText.width / 2;
    }
    
    if (difficultyText.width > scoreText.width)
    {
        difficultyText.x = infoBG.x + 15;
        scoreText.x = difficultyText.x + difficultyText.width / 2 - scoreText.width / 2;
    }
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    camGame.scroll.x = CoolUtil.fpsLerp(camGame.scroll.x, selInt * config.songsSpacing.x + config.cameraOffset.x, config.cameraSpeed);
    camGame.scroll.y = CoolUtil.fpsLerp(camGame.scroll.y, selInt * config.songsSpacing.y + config.cameraOffset.y, config.cameraSpeed);

    if (canSelect)
    {
        if (Controls.UI_DOWN_P || Controls.UI_UP_P)
        {
            changeOption(Controls.UI_DOWN_P ? 1 : -1);

            CoolUtil.playSound('scroll');
        }

        if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
            changeDifficulty(Controls.UI_LEFT_P ? -1 : 1);

        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(new CustomState(CoolVars.meta.mainMenuState));

            CoolUtil.playSound('cancel');
        }

        if (Controls.ACCEPT)
        {
            try
            {
                final curSong = songs[selInt];

                CoolUtil.switchState(new PlayState('freeplay', [curSong.name], curSong.difficulties[diffSelInt]));

                canSelect = false;
            } catch(e:Exception) {
                debugTrace(e, 'error');
            }
        }
    }
}