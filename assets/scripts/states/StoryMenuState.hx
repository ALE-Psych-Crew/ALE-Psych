import flixel.util.FlxColor;

import flixel.input.keyboard.FlxKey;

import utils.Score;

import utils.ALEFormatter;

using StringTools;

var weeks:Array<Dynamic> = [];

var sprites:FlxTypedGroup<FlxSprite>;
var lockers:FlxTypedGroup<FlxSprite>;

var bg:FlxSprite;

var tracksSprite:FlxSprite;
var tracks:FlxText;

var diffSprite:FlxSprite;

var leftButton:FlxSprite;
var rightButton:FlxSprite;

var scoreText:FlxText;
var weekText:FlxText;

var selInt:Int = CoolUtil.save.custom.data.storyMenu ?? 0;
var diffSelInt:Int = CoolUtil.save.custom.data.storyMenuDifficulty ?? 1;

if (FlxG.sound.music == null || !FlxG.sound.music.playing)
    FlxG.sound.playMusic(Paths.music('freakyMenu'));

function onCreate()
{
    sprites = new FlxTypedGroup<FlxSprite>();
    add(sprites);

    lockers = new FlxTypedGroup<FlxSprite>();
    add(lockers);

    var bgShit:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 45, FlxColor.BLACK);
    add(bgShit);
    bgShit.scrollFactor.set();

    bg = new FlxSprite(0, bgShit.height).makeGraphic(0, 0);
    add(bg);
    bg.scrollFactor.set();
    bg.antialiasing = ClientPrefs.data.antialiasing;

    diffSprite = new FlxSprite(0, 0);
    diffSprite.antialiasing = ClientPrefs.data.antialiasing;
    diffSprite.scrollFactor.set();
    add(diffSprite);

    leftButton = new FlxSprite();
    rightButton = new FlxSprite();
    
    for (obj in [leftButton, rightButton])
    {
        obj.frames = Paths.getSparrowAtlas('menus/story/ui');
        obj.animation.addByPrefix('idle', 'arrow ' + (obj == leftButton ? 'left' : 'right'), 1, false);
        obj.animation.addByPrefix('push', 'arrow push ' + (obj == leftButton ? 'left' : 'right'), 1, false);
        obj.animation.play('idle');
        obj.antialiasing = ClientPrefs.data.antialiasing;
        obj.scrollFactor.set();
        obj.scale.x = obj.scale.y = 0.8;
        obj.updateHitbox();
        add(obj);
        obj.animation.callback = (a, b, c) -> {  
            obj.centerOffsets();
            obj.centerOrigin();
        };
    }

    tracksSprite = new FlxSprite(110, 470).loadGraphic(Paths.image('menus/story/tracks'));
    tracksSprite.scrollFactor.set();
    add(tracksSprite);

    tracks = new FlxText(0, tracksSprite.y + tracksSprite.height + 20, 0, 'OSO\nDONDE', 40);
    tracks.scrollFactor.set();
    tracks.font = Paths.font('vcr.ttf');
    tracks.color = 0xFFE55777;
    tracks.alignment = 'center';
    add(tracks);

    scoreText = new FlxText(10, 0, FlxG.width - 20, 'WEEK SCORE: 0', 30);
    scoreText.font = Paths.font('vcr.ttf');
    scoreText.scrollFactor.set();
    scoreText.y = bgShit.height / 2 - scoreText.height / 2;
    add(scoreText);

    weekText = new FlxText(10, 0, FlxG.width - 20, 'ALE ENGINE SUPREMACY', 30);
    weekText.font = Paths.font('vcr.ttf');
    weekText.alignment = 'right';
    weekText.color = FlxColor.fromRGB(200, 200, 200);
    weekText.scrollFactor.set();
    weekText.y = bgShit.height / 2 - weekText.height / 2;
    add(weekText);

    for (week in Paths.readDirectory('data/weeks', CoolVars.data.loadDefaultWeeks ? 'multiple' : 'unique'))
        if (week.endsWith('.json'))
            weeks.push(ALEFormatter.getWeek(week.substring(0, week.length - 5)));

    for (week in weeks.copy())
        if (week.hideStoryMode)
            weeks.remove(week);

    for (index => week in weeks)
    {
        Paths.image('menus/story/backgrounds/' + week.background);

        var sprite:FlxSprite = new FlxSprite(0, index * 125).loadGraphic(Paths.image('menus/story/titles/' + week.image));
        sprites.add(sprite);
        sprite.scale.x = sprite.scale.y = 0.95;
        sprite.updateHitbox();
        sprite.x = FlxG.width / 2 - sprite.width / 2 - 25;
        sprite.antialiasing = ClientPrefs.data.antialiasing;

        var locker:FlxSprite = new FlxSprite();
        locker.frames = Paths.getAtlas('menus/story/ui');
        locker.animation.addByPrefix('lock', 'lock', 1, false);
        locker.animation.play('lock');
        locker.x = sprite.x + sprite.width / 2 - locker.width / 2;
        locker.y = sprite.y + sprite.height / 2 - locker.height / 2;
        locker.visible = weekIsLocked(week);
        locker.antialiasing = ClientPrefs.data.antialiasing;
        lockers.add(locker);
    }

    selInt = FlxMath.bound(selInt, 0, weeks.length - 1);

    changeShit();
}

function changeShit()
{
    for (index => sprite in sprites)
    {
        sprite.alpha = selInt == index ? (weekIsLocked(weeks[selInt]) ? 0.75 : 1) : 0.5;

        lockers.members[index].alpha = selInt == index ? 1 : 0.75;
    }

    bg.loadGraphic(Paths.image('menus/story/backgrounds/' + weeks[selInt].background));

    weekText.text = weeks[selInt].phrase.toUpperCase();

    tracks.text = [for (song in weeks[selInt].songs) song.name].join('\n');
    tracks.x = tracksSprite.x + tracksSprite.width / 2 - tracks.width / 2;

    changeDiff();
}

function changeDiff()
{
    var newImage:FlxGraphic = Paths.image('menus/story/difficulties/' + CoolUtil.formatToSongPath(weeks[selInt].difficulties[diffSelInt]));

    if (diffSprite.graphic != newImage)
    {
        diffSprite.loadGraphic(newImage);
        diffSprite.x = FlxG.width - diffSprite.width / 2 - 240;
        diffSprite.y = 520 - diffSprite.height / 2;
        
        for (obj in [leftButton, rightButton])
        {
            obj.x = obj == leftButton ? diffSprite.x - obj.width - 15 : diffSprite.x + diffSprite.width + 15;
            obj.y = 520 - obj.height / 2;
            obj.visible = weeks[selInt].difficulties.length > 1;
        }
    }

    scoreText.text = 'WEEK SCORE: ' + (Score.week.get(CoolUtil.formatToSongPath(weeks[selInt].image.trim() + '-' + weeks[selInt].difficulties[diffSelInt].trim())) ?? 0);
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    if (canSelect)
    {
        if (!FlxG.keys.pressed.SHIFT && (Controls.UI_UP_P || Controls.UI_DOWN_P || Controls.MOUSE_WHEEL))
        {
            if (Controls.UI_UP_P || Controls.MOUSE_WHEEL_UP)
                if (selInt <= 0)
                    selInt = weeks.length - 1;
                else
                    selInt--;

            if (Controls.UI_DOWN_P || Controls.MOUSE_WHEEL_DOWN)
                if (selInt >= weeks.length - 1)
                    selInt = 0;
                else
                    selInt++;

            changeShit();

            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
    
        if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P || (FlxG.keys.pressed.SHIFT && Controls.MOUSE_WHEEL))
        {
            if (Controls.UI_LEFT_P || Controls.MOUSE_WHEEL_DOWN)
            {
                if (diffSelInt <= 0)
                    diffSelInt = weeks[selInt].difficulties.length - 1;
                else
                    diffSelInt--;
                
                if (!Controls.MOUSE_WHEEL)
                    leftButton.animation.play('push', true);
            }
    
            if (Controls.UI_RIGHT_P || Controls.MOUSE_WHEEL_UP)
            {
                if (diffSelInt >= weeks[selInt].difficulties.length - 1)
                    diffSelInt = 0;
                else
                    diffSelInt++;
                
                if (!Controls.MOUSE_WHEEL)
                    rightButton.animation.play('push', true);
            }
    
            changeDiff();
        }

        if (Controls.UI_LEFT_R)
            leftButton.animation.play('idle', true);

        if (Controls.UI_RIGHT_R)
            rightButton.animation.play('idle', true);

        if (Controls.ACCEPT)
        {
            if (weekIsLocked(weeks[selInt]))
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
            } else {
                canSelect = false;

                FlxG.sound.play(Paths.sound('confirmMenu'));

                flixel.effects.FlxFlicker.flicker(sprites.members[selInt]);

                sprites.members[selInt].color = FlxColor.CYAN;

                for (obj in [leftButton, rightButton])
                    FlxTween.tween(obj, {alpha: 0}, 0.5, {ease: FlxEase.cubeIn});

                new FlxTimer().start(1, (_) -> {
                    CoolUtil.switchState(new PlayState('story', [for (song in weeks[selInt].songs) song.name], CoolUtil.formatToSongPath(weeks[selInt].difficulties[diffSelInt]), weeks[selInt].image));
                            
                    FlxG.sound.music?.pause();
                });
            }
        }

        if (Controls.BACK)
        {
            canSelect = false;

            FlxG.sound.play(Paths.sound('cancelMenu'));

            CoolUtil.switchState(new CustomState(CoolVars.data.mainMenuState));
        }
    }

    game.camGame.scroll.y = CoolUtil.fpsLerp(game.camGame.scroll.y, selInt * 125 - 475, 0.25);
}

function weekIsLocked(week:ALEWeek):Bool
{
    return week.locked && week.weekBefore.length > 0 && !utils.Score.completed.exists(week.weekBefore);
}

function onDestroy()
{
    CoolUtil.save.custom.data.storyMenu = selInt;
    CoolUtil.save.custom.data.storyMenuDifficulty = diffSelInt;
}