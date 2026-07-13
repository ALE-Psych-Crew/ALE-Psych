import funkin.visuals.objects.Alphabet;

@:typedef JsonPause = {
	var cameraOffset:Point;
	
	var optionsSpacing:Point;

	var cameraSpeed:Float;
	
	var infoCorner:String;
};

final play:PlayState = PlayState.instance;

final music:Sound = new Sound().loadEmbedded(Paths.music(play.hudRoute + '/pause', true), true);
music.play();
music.fadeIn(5, 0, 0.5);

FlxG.sound.list.add(music);

final config:JsonPause = Paths.json('data/menus/pause');

var options:FlxTypedGroup<Alphabet>;


function postCreate()
{
	final bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	bg.scrollFactor.set();
	bg.alpha = 0;
	add(bg);

	FlxTween.tween(bg, {alpha: 0.5}, 0.5, {ease: FlxEase.cubeOut});

	add(options = new FlxTypedGroup<Alphabet>());

	for (index => opt in ['resume', 'restart', 'options', 'exit'])
	{
		final text:Alphabet = new Alphabet(0, 0, opt);
		options.add(text);

		FlxTween.tween(text, {x: index * config.optionsSpacing.x, y: index * config.optionsSpacing.y}, config.cameraSpeed, {ease: FlxEase.cubeOut});
	}

	for (index => txt in ['Song: ' + play.song, 'Difficulty: ' + play.difficulty, play.type == 'story' ? 'Story Mode' : 'Freeplay'])
	{
		final text:FlxText = new FlxText(FlxG.width, 10 + 30 * index, 0, txt, 30);
		text.font = Paths.font('vcr.ttf');
		text.camera = subCamera;
		text.scrollFactor.set();
		text.alpha = 0;
		
		add(text);

		FlxTween.tween(text, {x: FlxG.width - 19 - text.width, alpha: 1}, 0.5, {ease: FlxEase.cubeOut, startDelay: index * 0.1});
	}

	for (obj in members)
		obj.camera = subCamera;

	changeOption();
}

var selInt:Int = 0;

function changeOption(?change:Int = 0)
{
	selInt += change;

	if (selInt < 0)
		selInt = options.members.length - 1;

	if (selInt > options.members.length - 1)
		selInt = 0;

	for (index => opt in options)
		opt.alpha = selInt == index ? 1 : 0.5;
}

function onUpdate(elapsed:Float)
{
	subCamera.scroll.x = CoolUtil.fpsLerp(subCamera.scroll.x, selInt * config.optionsSpacing.x + config.cameraOffset.x, config.cameraSpeed);
	subCamera.scroll.y = CoolUtil.fpsLerp(subCamera.scroll.y, selInt * config.optionsSpacing.y + config.cameraOffset.y, config.cameraSpeed);

	if (Controls.UI_DOWN_P || Controls.UI_UP_P)
	{
		changeOption(Controls.UI_DOWN_P ? 1 : -1);

		CoolUtil.playSound('scroll');
	}

	if (Controls.ACCEPT)
	{
		switch (options.members[selInt].text)
		{
			case 'restart':
				play.restart();

			case 'options':
				CoolUtil.switchState(new CustomState(CoolVars.data.optionsState, [play.type, play.playlist, play.difficulty, play.week, play.weekScore, play.songIndex]));

			case 'exit':
				play.exit();

			default:
				play.resume();
		}

		close();
	}
}

function onDestroy()
	music.stop();

CoolUtil.createTouchButtons([
    { label: 'D', keys: ClientPrefs.controls.ui.down },
    { label: 'U', keys: ClientPrefs.controls.ui.up }
], 150, FlxG.height - 170, 90);

CoolUtil.createTouchButtons([
    { label: 'A', keys: ClientPrefs.controls.ui.accept },
    { label: 'B', keys: ClientPrefs.controls.ui.back }
], FlxG.width - 200, FlxG.height - 170);