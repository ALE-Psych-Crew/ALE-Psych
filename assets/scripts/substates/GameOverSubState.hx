import funkin.visuals.game.Character;
import funkin.visuals.FXCamera;

final play:PlayState = PlayState.instance;

final character:Character;

var sfx:Sound;
var music:Sound;

function postCreate()
{
	final targetCharacter:String = (play.nextNoteToMissCharacter ?? play.bf ?? play.gf ?? play.dad)._castConfig.death;

	character = new Character(targetCharacter, 'player');
	character.camera = subCamera;
	add(character);
    character.playAnim('firstDeath');

    character.animation.onFinish.addOnce(
        (name) -> {
            if (name == 'firstDeath')
                startMusic();
        }
    );

	play.resetCharacterPosition(character);

	subCamera.scroll.x = play.camGame.scroll.x;
	subCamera.scroll.y = play.camGame.scroll.y;
	subCamera.zoom = play.camGame.zoom;
	subCamera.targetZoom = play.stage.config.zoom;
	
	final charCam = play.getCharacterCamera(character);

	subCamera.position.set(charCam.x, charCam.y);

	sfx = CoolUtil.playSound(play.hudRoute + '/gameOver');

	FlxG.sound.list.add(music = new Sound());
	music.loadEmbedded(Paths.music(play.hudRoute + '/gameOver'), true);
}

function startMusic()
{
	sfx.pause();
	
	music.play();

    character.playAnim('deathLoop');
}

function onCamerasInit()
{
	subCamera = new FXCamera();
	subCamera.bgColor = FlxColor.BLACK;
	subCamera.speed = 1;

	FlxG.cameras.add(subCamera, false);

	return Function_Stop;
}

var canSelect:Bool = true;

function postUpdate(elapsed:Float)
{
	if (Controls.BACK)
	{
		CoolVars.skipTransIn = true;

		play.exit();
	}

	if (canSelect && Controls.ACCEPT)
	{
		if (music.playing)
		{
			music.stop();

			final sound:Sound = CoolUtil.playSound(play.hudRoute + '/gameOverEnd');

            character.playAnim('deathConfirm');

			canSelect = false;

            subCamera.fade(FlxColor.BLACK, 2.5, false, () -> {
                close();

				play.reset();
            });
		} else {
			startMusic();
		}
	}
}

CoolUtil.createTouchButtons([
    { label: 'A', keys: ClientPrefs.controls.ui.accept },
    { label: 'B', keys: ClientPrefs.controls.ui.back }
], FlxG.width - 200, FlxG.height - 170);