import funkin.visuals.game.Character;

final playState:PlayState = PlayState.instance;

var playStateCam:ALECamera = playState.camGame;

playState.pauseMusic();

subCamera.scroll.x = playStateCam.scroll.x;
subCamera.scroll.y = playStateCam.scroll.y;
subCamera.zoom = playStateCam.zoom;

var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
bg.cameras = [subCamera];
bg.scrollFactor.set();
bg.scale.x = bg.scale.y = 1 / subCamera.zoom;
bg.alpha = 0;
add(bg);

FlxTween.tween(bg, {alpha: 1}, 0.25, {ease: FlxEase.cubeOut});

var sfx:FlxSound;
var music:FlxSound;

var deadCharacter:Character;

var playStateChar:Character;

final filesPath:String = 'hud/' + playState.stage.data.hud;

function new(?char:Character)
{
    playStateChar = char ?? playState.lastMissNoteCharacter;
    
    playStateChar.exists = false;

    deadCharacter = new Character(playStateChar.data.death, playStateChar.type);
    deadCharacter.cameras = [subCamera];
    deadCharacter.playAnim('firstDeath');
    add(deadCharacter);

    deadCharacter.animation.onFinish.addOnce(
        (name) -> {
            if (name == 'firstDeath')
                startMusic();
        }
    );

    sfx = new FlxSound().loadEmbedded(Paths.sound(filesPath + '/gameOver'));
    FlxG.sound.list.add(sfx);
    sfx.play();

    music = new FlxSound().loadEmbedded(Paths.music(filesPath + '/gameOverMusic'), true);

    playState.resetCharacterPosition(deadCharacter);

    playState.moveCamera(deadCharacter);
}

final startedMusic:Bool = false;

function startMusic()
{
    if (startedMusic)
        return;

    startedMusic = true;

    sfx.stop();

    music.play();

    deadCharacter.playAnim('deathLoop');
}

var canSelect:Bool = true;

function onUpdate(elapsed:Float)
{
    if (Controls.ACCEPT && canSelect)
    {
        if (startedMusic)
        {
            music.stop();

            FlxG.sound.play(Paths.sound(filesPath + '/gameOverEnd'));

            deadCharacter.playAnim('deathConfirm');

            subCamera.fade(FlxColor.BLACK, 2.5, false, () -> {
                close();

                playState.restart();
            });

            canSelect = false;
        } else {
            startMusic();
        }
    }

    subCamera.scroll.x = playStateCam.scroll.x;
    subCamera.scroll.y = playStateCam.scroll.y;
}

function onDestroy()
{
    playStateChar.exists = true;

    sfx.stop();
    music.stop();
}