import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxStringUtil;
import flixel.util.FlxColor;

import funkin.visuals.objects.Alphabet;

import utils.cool.PlayStateUtil;

var subCamera:FlxCamera;

var sprites:FlxTypedGroup<Alphabet>;

var selInt:Int = 0;

var options:Array<String> = ['resume', 'restart song', 'options', 'exit to menu'];

var runningTimer:Bool = false;

var isBack:Bool = false;

var timer:Float = 0;

var changeTimer:Float = 0;

var theTime:Float = FlxG.sound.music == null ? 0 : FlxG.sound.music.time;

var timeText:FlxText;

var metaText:FlxText;

function onCreate()
{
	if (PlayState.chartingMode)
	{
		if (!PlayState.instance.startingSong)
			options.insert(2, 'skip time');

		options.insert(3, 'leave charting mode');
	}

	subCamera = new ALECamera();
	
    FlxG.cameras.add(subCamera, false);

	var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	add(bg);
	bg.scrollFactor.set();
	bg.cameras = [subCamera];
	bg.alpha = 0;

	FlxTween.tween(bg, {alpha: 0.5}, 0.5, {ease: FlxEase.cubeOut});

	metaText = new FlxText(0, 0, 0, PlayState.SONG.song + '\n' + PlayState.difficulty.toUpperCase() + '\nBlueballed: ' + PlayState.deathCounter + (ClientPrefs.data.practice ? '\n\nPractice Mode' : '') + (PlayState.chartingMode ? '\n\nCharting Mode' : ''), 30);
	metaText.font = Paths.font('vcr.ttf');
	metaText.cameras = [subCamera];
	metaText.alignment = 'right';
	metaText.scrollFactor.set();
	metaText.x = FlxG.width - metaText.width - 10;
	metaText.alpha = 0;
	add(metaText);

	FlxTween.tween(metaText, {alpha: 1, y: 10}, 0.5, {ease: FlxEase.cubeOut});

	sprites = new FlxTypedGroup<Alphabet>();
	add(sprites);
	sprites.cameras = [subCamera];

	for (index => option in options)
	{
		var alpha:Alphabet = new Alphabet(0, 0, option);
		sprites.add(alpha);
		alpha.cameras = [subCamera];
		alpha.alpha = 0.5;

		if (option == 'skip time')
		{
			timeText = new FlxText(0, 0, 0, '', 60);
			add(timeText);
			timeText.font = Paths.font('vcr.ttf');
			timeText.alpha = 0.5;
			timeText.cameras = [subCamera];
			timeText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
			
			FlxTween.tween(timeText, {x: index * 30 + alpha.width + 40, y: index * 125 + alpha.height / 2 - timeText.height / 2}, 0.3, {ease: FlxEase.cubeOut});

			updateTime();
		}

		FlxTween.tween(alpha, {x: index * 30, y: index * 125}, 0.3, {ease: FlxEase.cubeOut});
	}

	changeShit();
}

function onUpdate(elapsed:Float)
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

	if (runningTimer)
		timer += elapsed;

	if (timer > 0.5)
	{
		changeTimer += elapsed;

		if (changeTimer > 0.025)
		{
			changeTimer = 0;

			updateTime();
		}
	}

	if (Controls.UI_LEFT_P != Controls.UI_RIGHT_P)
	{
		isBack = Controls.UI_LEFT_P;

		updateTime();

		runningTimer = true;
	}

	if ((Controls.UI_LEFT_R && isBack) || (Controls.UI_RIGHT_R && !isBack))
	{
		runningTimer = false;

		changeTimer = 0;

		timer = 0;
	}

	if (Controls.ACCEPT)
	{
		switch (options[selInt])
		{
			case 'resume':
				close();
			case 'restart song':
				PlayStateUtil.resetSong();
			case 'skip time':
				var timeSecond:Float = Math.floor(theTime / 1000) * 1000;

				if (timeSecond < Conductor.songPosition)
				{
					PlayState.startOnTime = timeSecond;

					PlayStateUtil.resetSong();
				} else {
					if (timeSecond != Conductor.songPosition)
					{
						PlayState.instance.clearNotesBefore(timeSecond);

						PlayState.instance.setSongTime(timeSecond);
					}
				}

				close();
			case 'options':
				CoolVars.skipTransIn = true;

				CoolUtil.switchState(new CustomState(CoolVars.data.optionsState, [true], [true]));
			case 'leave charting mode':
				PlayState.chartingMode = false;
				
				PlayStateUtil.resetSong();
			case 'exit to menu':
				CoolVars.skipTransIn = true;

				PlayStateUtil.exitSong();
		}
	}

	subCamera.scroll.x = CoolUtil.fpsLerp(subCamera.scroll.x, 30 * selInt - 150, 0.3);
	subCamera.scroll.y = CoolUtil.fpsLerp(subCamera.scroll.y, 125 * selInt - 300, 0.3);
}

function updateTime()
{
	theTime += 1000 * (isBack ? -1 : 1);

	if (theTime < 0)
		theTime = FlxG.sound.music.length;
	
	if (theTime > FlxG.sound.music.length)
		theTime = 0;

	if (timeText != null)
		timeText.text = FlxStringUtil.formatTime(theTime / 1000) + ' / ' + FlxStringUtil.formatTime(FlxG.sound.music.length / 1000);
}

function changeShit()
{
	for (index => sprite in sprites)
	{
		sprite.alpha = index == selInt ? 1 : 0.5;
	}

	if (timeText != null)
		timeText.alpha = options[selInt] == 'skip time' ? 1 : 0.5;
}

function onClose()
{
	PlayState.instance.closeSubState();
}

var mobileCamera:FlxCamera;

function postCreate()
{
    if (CoolVars.mobileControls)
    {
        mobileCamera = new ALECamera();
        mobileCamera.bgColor = FlxColor.TRANSPARENT;
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
}

function onDestroy()
{
    if (CoolVars.mobileControls)
        FlxG.cameras.remove(mobileCamera);

    FlxG.cameras.remove(subCamera);
}