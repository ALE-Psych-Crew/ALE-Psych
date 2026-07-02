import funkin.config.Score;

import flixel.FlxObject;

using StringTools;

final weeks:Array<JsonWeek> = [];

function checkLocked(week:JsonWeek)
    return week.locked;

var sprites:FlxTypedGroup<FlxTypedSpriteGroup<FlxSprite>>;

var tracksSprite:FlxSprite;
var tracks:FlxText;

var bar:FlxSprite;
var bg:FlxSprite;

var scoreText:FlxText;
var phraseText:FlxText;

var difficultySprite:FlxSprite;
var leftArrow:FlxSprite;
var rightArrow:FlxSprite;

final weekNames:String = [];

function onCreate()
{
    if (Conductor.music == null)
        Conductor.play(Paths.music('freakyMenu'), CoolVars.meta.bpm, CoolVars.meta.stepsPerBeat, CoolVars.meta.beatsPerSection);

    sprites = new FlxTypedGroup<FlxTypedSpriteGroup<FlxSprite>>();
    add(sprites);

    tracksSprite = new FlxSprite(110, 470).loadGraphic(Paths.image('menus/story/tracks'));
    tracksSprite.scrollFactor.set();
    add(tracksSprite);

    tracks = new FlxText(0, tracksSprite.y + tracksSprite.height + 20, 0, '', 40);
    tracks.color = 0xFFE55777;
    tracks.alignment = 'center';
    add(tracks);

    difficultySprite = new FlxSprite();
    add(difficultySprite);

    leftArrow = CoolUtil.spriteFromJson(new FlxSprite(), {
        type: 'sheet',
        images: ['ui'],
        animations: [{name: 'left'}, {name: 'push left'}],
        initialAnimation: 'left',
        properties: {scale: {x: 0.9, y: 0.9}}
    }, 'menus/story/');
    add(leftArrow);

    rightArrow = CoolUtil.spriteFromJson(new FlxSprite(), {
        type: 'sheet',
        images: ['ui'],
        animations: [{name: 'right'}, {name: 'push right'}],
        initialAnimation: 'right',
        properties: {scale: {x: 0.9, y: 0.9}}
    }, 'menus/story/');
    add(rightArrow);
    
    bar = new FlxSprite().makeGraphic(FlxG.width, 45, FlxColor.BLACK);
    add(bar);

    bg = new FlxSprite(0, bar.height);
    add(bg);

    scoreText = new FlxText(10, 0, 0, '', 30);
    add(scoreText);

    phraseText = new FlxText(0, 0, 0, '', 30);
    add(phraseText);

    for (text in [tracks, scoreText, phraseText])
        text.font = Paths.font('vcr.ttf');

    for (obj in members)
        if (obj is FlxObject)
            obj.scrollFactor.set();

    for (week in Paths.readDirectory('data/weeks', CoolVars.data.loadDefaultWeeks ? 'multiple' : 'unique'))
    {
        if (!week.endsWith('.json'))
            continue;

        var name:String = week.substring(0, week.length - 5);

        if (weekNames.contains(name))
            continue;

        final data = Paths.json('data/weeks/' + name);

        if (!data.hideStoryMode)
        {
            weeks.push(data);
            
            weekNames.push(name);
        }
    }

    var weekIndex:Int = 0;

    for (week in weeks)
    {
        Paths.image('menus/story/backgrounds/' + week.background);

        final group:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup<FlxSprite>();
        sprites.add(group);

        final locked:Bool = checkLocked(week);

        final label:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/story/titles/' + week.image));
        label.scale.x = label.scale.y = 0.95;
        label.updateHitbox();
        label.x = FlxG.width / 2 - label.width / 2 - 50;
        label.y = weekIndex * 125 - label.height / 2;
        label.color = locked ? FlxColor.GRAY : FlxColor.WHITE;

        group.add(label);

        final locker:FlxSprite = new FlxSprite();
        locker.frames = Paths.getAtlas('menus/story/ui');
        locker.animation.addByPrefix('lock', 'lock');
        locker.animation.play('lock');
        locker.x = label.x + label.width / 2 - locker.width / 2;
        locker.y = label.y + label.height / 2 - locker.height / 2;
        locker.exists = locked;

        group.add(locker);

        weekIndex++;
    }

    changeOption();
}

var selInt(default, set):Int = Save.custom.data.storyMenuSelInt ??= 0;
function set_selInt(value:Int):Int
    return selInt = Save.custom.data.storyMenuSelInt = value;

var diffSelInt(default, set):Int = Save.custom.data.storyMenuDiffSelInt ??= 1;
function set_diffSelInt(value:Int):Int
    return diffSelInt = Save.custom.data.storyMenuDiffSelInt = value;

function changeOption(?change:Int = 0)
{
    selInt = FlxMath.wrap(selInt + change, 0, weeks.length - 1);

    for (index => spr in sprites)
        spr.alpha = index == selInt ? 1 : 0.25;

    final curWeek = weeks[selInt];

    tracks.text = [for (song in curWeek.songs) song.name].join('\n');
    tracks.x = tracksSprite.x + tracksSprite.width / 2 - tracks.width / 2;

    bg.loadGraphic(Paths.image('menus/story/backgrounds/' + curWeek.background));

    phraseText.text = curWeek.phrase.toUpperCase();
    phraseText.x = FlxG.width - phraseText.width - 10;
    phraseText.y = bar.height / 2 - phraseText.height / 2;

    changeDifficulty();
}

function changeDifficulty(?change:Int = 0)
{
    final difficulties:Array<String> = weeks[selInt].difficulties;

    diffSelInt = FlxMath.wrap(diffSelInt + change, 0, difficulties.length - 1);

    difficultySprite.loadGraphic(Paths.image('menus/story/difficulties/' + CoolUtil.formatString(difficulties[diffSelInt])));
    difficultySprite.x = 1040 - difficultySprite.width / 2;
    difficultySprite.y = 520 - difficultySprite.height / 2;

    leftArrow.x = difficultySprite.x - leftArrow.width - 20;
    leftArrow.y = difficultySprite.y + difficultySprite.height / 2 - leftArrow.height / 2;
    leftArrow.visible = difficulties.length > 1;

    rightArrow.x = difficultySprite.x + difficultySprite.width + 20;
    rightArrow.y = difficultySprite.y + difficultySprite.height / 2 - rightArrow.height / 2;
    rightArrow.visible = difficulties.length > 1;

    scoreText.text = 'SCORE: ' + Score.getWeek(weekNames[selInt], difficulties[diffSelInt]);
    scoreText.y = bar.height / 2 - scoreText.height / 2;
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    camGame.scroll.y = CoolUtil.fpsLerp(camGame.scroll.y, selInt * 125 - 520, 0.2);

    if (canSelect)
    {
        if (Controls.ACCEPT)
        {
            try
            {
                final curWeek = weeks[selInt];

                CoolUtil.switchState(new PlayState('story', [for (song in curWeek.songs) song.name], curWeek.difficulties[diffSelInt], weekNames[selInt]));

                canSelect = false;
            } catch(e:Exception) {
                debugTrace(e, 'error');
            }
        }

        if (Controls.UI_UP_P || Controls.UI_DOWN_P)
        {
            changeOption(Controls.UI_UP_P ? -1 : 1);

            CoolUtil.playSound('scroll');
        }

        if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
        {
            if (Controls.UI_LEFT_P)
            {
                leftArrow.animation.play('push left');
                leftArrow.centerOffsets();
            }

            if (Controls.UI_RIGHT_P)
            {
                rightArrow.animation.play('push right');
                rightArrow.centerOffsets();
            }

            changeDifficulty(Controls.UI_LEFT_P ? -1 : 1);
        }

        if (Controls.UI_LEFT_R)
        {
            leftArrow.animation.play('left');
            leftArrow.centerOffsets();
        }

        if (Controls.UI_RIGHT_R)
        {
            rightArrow.animation.play('right');
            rightArrow.centerOffsets();
        }

        if (Controls.BACK)
        {
            canSelect = false;

            CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));

            CoolUtil.playSound('cancel');
        }
    }
}