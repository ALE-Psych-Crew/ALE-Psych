package funkin.states;

import core.structures.JsonHudRating;
import core.structures.ALEEventList;
import core.structures.ALEEvent;
import core.structures.ALESong;
import core.structures.JsonHud;
import core.structures.Point;

import core.enums.CharacterType;
import core.enums.SongType;

import funkin.visuals.objects.Bar;
import funkin.visuals.FXCamera;
import funkin.visuals.game.*;
import funkin.config.Score;

import utils.cool.ReflectUtil;
import utils.cool.StringUtil;
import utils.Formatter;

import flixel.util.typeLimit.OneOfTwo;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.FlxBasic;

import openfl.media.Sound as OpenFLSound;
import openfl.events.KeyboardEvent;

import haxe.ds.GenericStack;

import ale.ui.UIUtils;

@:publicFields
class PlayState extends ScriptedState
{
    static var instance:PlayState;

    var startTime:Float = 0;

    var spawnNotes:Bool = true;
    var skipCountdown:Bool = false;

    var chart:ALESong;
    var hud:JsonHud;

    var hudRoute(get, never):String;
    function get_hudRoute():String
        return 'huds/' + hud.directory;

    final song:String;
    final week:String;
    final playlist:Array<String>;
    final difficulty:String;
    final songIndex:Int;
    final songRoute:String;

    final type:SongType;
    var weekScore:Float = 0;

    var score:Float = 0;
    var totalNotes:Int = 0;
    var accuracyMod:Float = 0;
    var misses:Int = 0;
    var combo:Int = 0;

    var stage:Stage;

    var accuracy(get, never):Float;
    function get_accuracy():Float
        return totalNotes == 0 ? 100 : accuracyMod / totalNotes;

    var botplay(default, set):Bool;
    function set_botplay(value:Bool):Bool
    {
        botplay = value;

        for (strl in strumLines)
            strl.botplay = botplay || strl.type != PLAYER;

        if (scoreText != null)
            updateScoreText();

        return botplay;
    }

    var speed(default, set):Float = 1;
    function set_speed(value:Float):Float
    {
        speed = value;

        for (strl in strumLines)
            strl.speed = speed;

        return speed;
    }

    var health(default, set):Float = 50;
    function set_health(value:Float)
        return health = FlxMath.bound(value, 0, 100);

    function new(?newType:SongType, ?newPlaylist:Array<String>, ?newDifficulty:String, ?newWeek:String, ?newWeekScore:Float, ?newSongIndex:Int)
    {
        super();

        newType ??= FREEPLAY;
        newPlaylist ??= ['bopeebo'];
        newDifficulty ??= 'normal';
        newWeekScore ??= 0;
        newSongIndex ??= 0;

        type = newType;

        playlist = newPlaylist;
        difficulty = newDifficulty;
        songIndex = newSongIndex;
        song = playlist[songIndex];

        week = newWeek;
        weekScore = newWeekScore;

        songRoute = CoolUtil.searchComplexFile('songs/' + song);

        chart = Formatter.getChart(song, difficulty);

        stage = new Stage(Formatter.getStage(chart.stage), this);

        hud = Formatter.getHud(stage.config.hud);
        hud.ratings.sort((a, b) -> Reflect.compare(a.time, b.time));
    }


    var totalNoteTypes:Array<String> = [];
    var totalEvents:Array<String> = [];

    override function create()
    {
        instance = this;
        
        allowCamerasConfig = false;

        super.create();

        Conductor.stop();
        Conductor.reset(chart.bpm, chart.stepsPerBeat, chart.beatsPerSection);

        Conductor.loadEvents(chart);

        scriptsManager.loadFolder('scripts/global');
        scriptsManager.loadFolder('scripts/songs');
        scriptsManager.loadFolder(songRoute + '/scripts');

        scriptsManager.load('scripts/stages/' + chart.stage);

        if (scriptsManager.callback(ON, 'Create'))
        {
            initCameras();

            initEvents();

            initCharacters();

            initCombo();
            
            initHud();

            initIcons();

            initStrumLines();

            botplay = ClientPrefs.data.botplay;

            speed = chart.speed;

            initControls();

            initSounds();

            initSong();

            changeStage(chart.stage);

            moveCamera(0);

            camGame.snapToTarget();

            for (noteType in totalNoteTypes)
                scriptsManager.load('scripts/noteTypes/' + noteType);

            for (event in totalEvents)
                scriptsManager.load('scripts/events/' + event);
        }

        scriptsManager.callback(POST, 'Create');
    }

    var _lastHealth:Float = -1;

    var allowPausing:Bool = true;

    override function update(elapsed:Float)
    {
        if (Controls.RESET && CoolVars.meta.developerMode && !UIUtils.usingInputs)
            reset();

        if (scriptsManager.callback(ON, 'Update', [elapsed]))
        {
            super.update(elapsed);

            if (Controls.RESET && !CoolVars.meta.developerMode && !ClientPrefs.data.noReset && !UIUtils.usingInputs)
                health = 0;

            health = FlxMath.bound(health, 0, 100);

            if (_lastHealth != health)
            {
                _lastHealth = health;

                updateHealth();
            }

            while (!eventsListStack.isEmpty() && eventsListStack.first().time <= Conductor.songPosition)
                for (event in eventsListStack.pop().events)
                    eventHit(event);

            if (Controls.PAUSE && allowPausing)
                pause();
        }

        scriptsManager.callback(POST, 'Update', [elapsed]);
    }

    override function draw()
    {
        if (scriptsManager.callback(ON, 'Draw'))
            super.draw();

        scriptsManager.callback(POST, 'Draw');
    }

    var cameraFactory:Void -> FXCamera = () -> new FXCamera();

    override function initCameras()
    {
        if (scriptsManager.callback(ON, 'CamerasInit'))
        {
            camGame = cameraFactory();

            final camGame:FXCamera = cast camGame;
            
            camGame.speed = 1;
            camGame.zoomSpeed = 1;
            camGame.bopModulo = 4;
            camGame.zoom = camGame.targetZoom = stage.config.zoom;

            FlxG.cameras.reset(camGame);
            FlxG.cameras.setDefaultDrawTarget(camGame, true);
            
            camHUD = cameraFactory();

            FlxG.cameras.add(camHUD, false);
                
            camOther = cameraFactory();

            FlxG.cameras.add(camOther, false);
        }

        scriptsManager.callback(POST, 'CamerasInit');
    }

    override function reset()
    {
        allowMemoryCleaning = false;

        CoolUtil.switchState(new PlayState(type, playlist, difficulty, week, weekScore, songIndex), true, true);
    }

    override function destroy()
    {
        super.destroy();

        if (scriptsManager.callback(ON, 'Destroy'))
        {
            Conductor.stop();

            FlxG.stage.removeEventListener('keyDown', justPressedKey);
            FlxG.stage.removeEventListener('keyUp', justReleasedKey);

            for (vocal in vocals.copy())
                Conductor.synchronizedSounds?.remove(vocal);

            characters?.destroy();

            playerCharacters?.destroy();
            opponentCharacters?.destroy();
            extraCharacters?.destroy();

            playerIcons?.destroy();
            opponentIcons?.destroy();
            extraIcons?.destroy();

            playerStrumLines?.destroy();
            opponentStrumLines?.destroy();
            extraStrumLines?.destroy();

            strums?.destroy();

            playerStrums?.destroy();
            opponentStrums?.destroy();
            extraStrums?.destroy();
        }

        scriptsManager.callback(POST, 'Destroy');

        instance = null;
    }


    final eventsListStack:GenericStack<ALEEventList> = new GenericStack();

    function initEvents()
    {
        if (scriptsManager.callback(ON, 'EventsInit'))
        {
            final sortedEvents = chart.events.copy();

            sortedEvents.sort((a, b) -> {
                final timeA:Float = a[0];
                final timeB:Float = b[0];

                return timeA > timeB ? -1 : timeA < timeB ? 1 : 0;
            });

            for (targetEvent in sortedEvents)
            {
                stackEventList({
                    time: targetEvent[0],
                    events: [
                        for (event in cast(targetEvent[1], Array<Dynamic>))
                        {
                            id: event.shift(),
                            values: event
                        }
                    ]
                });
            }
        }

        scriptsManager.callback(POST, 'EventsInit');
    }

    function stackEventList(eventList:ALEEventList)
    {
        eventsListStack.add(eventList);

        if (scriptsManager.callback(ON, 'EventListStack', [eventList]))
            for (event in eventList.events)
                if (!totalEvents.contains(event.id))
                    totalEvents.push(event.id);

        scriptsManager.callback(POST, 'EventListStack', [eventList]);
    }

    function eventHit(event:ALEEvent)
    {
        final args:Array<Dynamic> = cast([event.id], Array<Dynamic>).concat(event.values);

        scriptsManager.callback(ON, 'EventHit', args);

        scriptsManager.callback(POST, 'EventHit', args);
    }


    function changeStage(id:String)
    {
        if (scriptsManager.callback(ON, 'StageChange', [id]))
        {
            stage.change(id);

            if (characters != null)
                for (char in characters)
                    resetCharacterPosition(char);

            final camGame:FXCamera = cast camGame;

            camGame.targetZoom = stage.config.zoom;
            camGame.speed = stage.config.speed;
        }

        scriptsManager.callback(POST, 'StageChange', [id]);
    }


    function pause(?force:Bool = false)
    {
        if (scriptsManager.callback(ON, 'Pause'))
        {
            if (allowPausing || force)
            {
                Conductor.pause();

                toggleTweensAndTimers(false);

                CoolUtil.openSubState(new CustomSubState(CoolVars.meta.pauseSubState));
            }
        }

        scriptsManager.callback(POST, 'Pause');
    }

    function resume()
    {
        if (scriptsManager.callback(ON, 'Resume'))
        {
            Conductor.resume();

            toggleTweensAndTimers(true);
        }

        scriptsManager.callback(POST, 'Resume');
    }

    function restart()
    {
        if (scriptsManager.callback(ON, 'Restart'))
            reset();

        scriptsManager.callback(POST, 'Restart');
    }

    function endSong()
    {
        if (scriptsManager.callback(ON, 'SongEnd'))
        {
            Conductor.pause();

            saveScore();

            if (songIndex + 1 < playlist.length)
                CoolUtil.switchState(new PlayState(type, playlist, difficulty, week, weekScore + score, songIndex + 1), true, true);
            else
                exit();
        }

        scriptsManager.callback(POST, 'SongEnd');
    }

    function overGame()
    {
        if (scriptsManager.callback(ON, 'GameOver'))
        {
            Conductor.pause();

            CoolUtil.openSubState(new CustomSubState(CoolVars.data.gameOverSubState));
        }

        scriptsManager.callback(POST, 'GameOver');
    }

    function exit()
    {
        if (scriptsManager.callback(ON, 'Exit'))
        {
            allowPausing = false;

            toggleTweensAndTimers(false);

            CoolUtil.switchState(new CustomState(type == STORY ? CoolVars.meta.storyMenuState : CoolVars.meta.freeplayState));
        }

        scriptsManager.callback(POST, 'Exit');
    }


    function saveScore()
    {
        if (scriptsManager.callback(ON, 'ScoreSave'))
        {
            if (!botplay && !ClientPrefs.data.practice)
            {
                Score.saveSong(song, difficulty, score, accuracy);

                if (type == STORY && songIndex >= playlist.length - 1)
                    Score.saveWeek(week, difficulty, weekScore + score);
            }
        }

        scriptsManager.callback(POST, 'ScoreSave');
    }


    function toggleTweensAndTimers(toggle:Bool)
    {
        if (scriptsManager.callback(ON, 'TweensAndTimersToggle', [toggle]))
        {
            FlxTimer.globalManager.forEach(tmr -> if (tmr != null && !tmr.finished) tmr.active = toggle);
            FlxTween.globalManager.forEach(twn ->  if (twn != null && !twn.finished) twn.active = toggle);
        }

        scriptsManager.callback(POST, 'TweensAndTimersToggle', [toggle]);
    }


    override function stepHit(curStep:Int)
    {
        if (scriptsManager.callback(ON, 'StepHit', [curStep]))
            super.stepHit(curStep);

        scriptsManager.callback(POST, 'StepHit', [curStep]);
    }

    override function beatHit(curBeat:Int)
    {
        if (scriptsManager.callback(ON, 'BeatHit', [curBeat]))
        {
            super.beatHit(curBeat);

            for (cam in [camGame, camHUD])
                cast(cam, FXCamera).bop(curBeat);
        }

        scriptsManager.callback(POST, 'BeatHit', [curBeat]);
    }

    override function sectionHit(curSection:Int)
    {
        if (scriptsManager.callback(ON, 'SectionHit', [curSection]))
            super.sectionHit(curSection);

        scriptsManager.callback(POST, 'SectionHit', [curSection]);
    }

    override function safeStepHit(safeStep:Int)
    {
        if (scriptsManager.callback(ON, 'SafeStepHit', [safeStep]))
            super.safeStepHit(safeStep);

        scriptsManager.callback(POST, 'SafeStepHit', [safeStep]);
    }

    override function safeBeatHit(safeBeat:Int)
    {
        if (scriptsManager.callback(ON, 'SafeBeatHit', [safeBeat]))
            super.safeBeatHit(safeBeat);

        scriptsManager.callback(POST, 'SafeBeatHit', [safeBeat]);
    }

    override function safeSectionHit(safeSection:Int)
    {
        if (scriptsManager.callback(ON, 'SafeSectionHit', [safeSection]))
        {
            super.safeSectionHit(safeSection);

            moveCamera(safeSection);
        }

        scriptsManager.callback(POST, 'SafeSectionHit', [safeSection]);
    }

    override function musicPlay()
    {
        if (scriptsManager.callback(ON, 'MusicPlay'))
            super.musicPlay();

        scriptsManager.callback(POST, 'MusicPlay');
    }

    override function musicPause()
    {
        if (scriptsManager.callback(ON, 'MusicPause'))
            super.musicPause();

        scriptsManager.callback(POST, 'MusicPause');
    }

    override function musicResume()
    {
        if (scriptsManager.callback(ON, 'MusicResume'))
            super.musicResume();

        scriptsManager.callback(POST, 'MusicResume');
    }

    override function musicStop()
    {
        if (scriptsManager.callback(ON, 'MusicStop'))
            super.musicStop();

        scriptsManager.callback(POST, 'MusicStop');
    }

    override function musicComplete()
    {
        if (scriptsManager.callback(ON, 'MusicComplete'))
        {
            super.musicComplete();

            endSong();
        }

        scriptsManager.callback(POST, 'MusicComplete');
    }

    override function musicResync()
    {
        if (scriptsManager.callback(ON, 'MusicResync'))
            super.musicResync();

        scriptsManager.callback(POST, 'MusicResync');
    }

    override function onFocus()
    {
        if (scriptsManager.callback(ON, 'OnFocus'))
            super.onFocus();

        scriptsManager.callback(POST, 'OnFocus');
    }

    override function onFocusLost()
    {
        if (scriptsManager.callback(ON, 'OnFocusLost'))
            super.onFocusLost();

        scriptsManager.callback(POST, 'OnFocusLost');
    }

    override function openSubState(substate:flixel.FlxSubState):Void
    {
        if (scriptsManager.callback(ON, 'OpenSubState', null, [substate]))
            super.openSubState(substate);

        scriptsManager.callback(POST, 'OpenSubState', null, [substate]);
    }

    override function closeSubState():Void
    {
        if (scriptsManager.callback(ON, 'CloseSubState'))
            super.closeSubState();

        scriptsManager.callback(POST, 'CloseSubState');
    }
    

    var characters:FlxTypedGroup<Character>;

    var charactersArray:Array<Array<Character>> = [];

    var playerCharacters:FlxTypedGroup<Character>;
    var opponentCharacters:FlxTypedGroup<Character>;
    var extraCharacters:FlxTypedGroup<Character>;

    var characterFactory:(String, CharacterType) -> Character = (char, type) -> new Character(char, type);

    function initCharacters()
    {
        if (scriptsManager.callback(ON, 'CharactersInit'))
        {
            characters = new FlxTypedGroup<Character>();

            playerCharacters = new FlxTypedGroup<Character>();
            opponentCharacters = new FlxTypedGroup<Character>();
            extraCharacters = new FlxTypedGroup<Character>();

            for (strlIndex => strl in chart.strumLines)
            {
                for (index => char in strl.characters)
                {
                    final character:Character = characterFactory(char, strl.type);
                    
                    addCharacter(character);

                    charactersArray[strlIndex] ??= [];

                    charactersArray[strlIndex][index] = character;
                }
            }
        }

        scriptsManager.callback(POST, 'CharactersInit');
    }

    var nextCharacterToAdd:Character;

    function addCharacter(char:Character)
    {
        nextCharacterToAdd = char;

        if (scriptsManager.callback(ON, 'CharacterAdd', null, [nextCharacterToAdd]))
        {
            switch (nextCharacterToAdd.type)
            {
                case PLAYER:
                    playerCharacters.add(nextCharacterToAdd);

                case OPPONENT:
                    opponentCharacters.add(nextCharacterToAdd);

                case EXTRA:
                    extraCharacters.add(nextCharacterToAdd);
            }

            characters.add(char);

            add(nextCharacterToAdd);

            resetCharacterPosition(nextCharacterToAdd);
        }

        scriptsManager.callback(POST, 'CharacterAdd', null, [nextCharacterToAdd]);
    }

    var nextCharacterToResetPosition:Character;

    function resetCharacterPosition(char:Character)
    {
        nextCharacterToResetPosition = char;

        if (scriptsManager.callback(ON, 'CharacterPositionReset', null, [nextCharacterToResetPosition]))
        {
            nextCharacterToResetPosition.x = nextCharacterToResetPosition._castConfig.properties.x;
            nextCharacterToResetPosition.y = nextCharacterToResetPosition._castConfig.properties.y;

            if (stage.config.charactersOffset != null)
            {
                var offset:Point = null;

                if (stage.config.charactersOffset.type != null)
                    offset = Reflect.getProperty(stage.config.charactersOffset.type, cast char.type);

                if (stage.config.charactersOffset.id != null)
                    offset = Reflect.getProperty(stage.config.charactersOffset.id, char.id);

                if (offset != null)
                {
                    nextCharacterToResetPosition.x += offset.x ?? 0;
                    nextCharacterToResetPosition.y += offset.y ?? 0;
                }
            }
        }

        scriptsManager.callback(POST, 'CharacterPositionReset', null, [nextCharacterToResetPosition]);
    }

    var nextCharacterToChange:Character;

    function changeCharacter(char:Character, id:String)
    {
        nextCharacterToChange = char;

        if (scriptsManager.callback(ON, 'CharacterChange'))
        {
            nextCharacterToChange?.change(id);

            if (nextCharacterToChange != null)
            {
                if (nextCharacterToChange == bf)
                    if (iconP1 != null)
                        changeIcon(iconP1, nextCharacterToChange._castConfig.icon);

                if (nextCharacterToChange == dad)
                    if (iconP2 != null)
                        changeIcon(iconP2, nextCharacterToChange._castConfig.icon);

                if (nextCharacterToChange == bf)
                    if (iconP3 != null)
                        changeIcon(iconP3, nextCharacterToChange._castConfig.icon);
            }
        }

        scriptsManager.callback(POST, 'CharacterChange');
    }

    function getCharacterCamera(character:Character):Point
    {
        final result:Point = {x: character.getMidpoint().x + character._castConfig.cameraOffset.x * (character.type == PLAYER ? -1 : 1), y: character.getMidpoint().y + character._castConfig.cameraOffset.y};

        if (stage.config.charactersCamera != null)
        {
            var offset:Point = null;

            if (stage.config.charactersCamera.type != null)
                offset = Reflect.getProperty(stage.config.charactersCamera.type, cast character.type);

            if (stage.config.charactersCamera.id != null)
                offset = Reflect.getProperty(stage.config.charactersCamera.id, character.id);

            if (offset != null)
            {
                result.x += offset.x ?? 0;
                result.y += offset.y ?? 0;
            }
        }

        return result;
    }

    var comboGroup:FlxTypedSpriteGroup<FlxSprite>;

    var ratingSprite:FunkinSprite;
    var comboNumbers:FlxTypedSpriteGroup<FunkinSprite>;

    function initCombo()
    {
        if (scriptsManager.callback(ON, 'CombosInit'))
        {
            add(comboGroup = new FlxTypedSpriteGroup<FlxSprite>());
            comboGroup.camera = camHUD;

            ReflectUtil.setProperties(comboGroup, hud.combo.properties);

            comboGroup.y = ClientPrefs.data.downScroll ? FlxG.height - comboGroup.y : comboGroup.y;

            comboGroup.add(ratingSprite = new FunkinSprite());
            ratingSprite.visible = false;

            ReflectUtil.setProperties(ratingSprite, hud.combo.rating.properties);

            for (rating in hud.ratings)
                Paths.image(hudRoute + '/combo/' + rating.id);

            comboGroup.add(comboNumbers = new FlxTypedSpriteGroup<FunkinSprite>());

            for (i in 0...10)
                Paths.image(hudRoute + '/combo/' + i);
        }

        scriptsManager.callback(POST, 'CombosInit');
    }

    function displayCombo(rating:JsonHudRating)
    {
        if (scriptsManager.callback(ON, 'ComboDisplay', [rating]))
        {
            FlxTween.cancelTweensOf(ratingSprite);

            ratingSprite.loadGraphic(Paths.image(hudRoute + '/combo/' + rating.id));

            final basePosition:FlxPoint = FlxPoint.get(comboGroup.x - ratingSprite.width / 2, comboGroup.y - ratingSprite.height / 2);

            ratingSprite.x = basePosition.x + hud.combo.rating.start.x;
            ratingSprite.y = basePosition.y + hud.combo.rating.start.y;
            ratingSprite.alpha = hud.combo.rating.start.alpha;
            ratingSprite.visible = true;

            FlxTween.tween(ratingSprite, {
                x: basePosition.x + hud.combo.rating.end.x,
                y: basePosition.y + hud.combo.rating.end.y,
                alpha: hud.combo.rating.end.alpha
            }, hud.combo.rating.duration, {
                ease: StringUtil.easeFromString(hud.combo.rating.ease),
                onComplete: _ -> ratingSprite.visible = false
            });

            final comboString:String = Std.string(combo).trim().lpad('0', 3);
            
            while (comboString.length > comboNumbers.members.length)
            {
                final number:FunkinSprite = new FunkinSprite();

                ReflectUtil.setProperties(number, hud.combo.number.properties);

                comboNumbers.add(number);
            }

            basePosition.set(-hud.combo.number.spacing * (comboNumbers.members.length - 1) / 2);

            for (i => number in comboNumbers.members)
            {
                FlxTween.cancelTweensOf(number);

                number.loadGraphic(Paths.image(hudRoute + '/combo/' + comboString.charAt(i)));

                final baseNumberPosition:FlxPoint = FlxPoint.get(basePosition.x + comboGroup.x - number.width / 2 + hud.combo.number.spacing * i, comboGroup.y - number.width / 2);

                number.x = baseNumberPosition.x + hud.combo.number.start.x;
                number.y = baseNumberPosition.y + hud.combo.number.start.y;
                number.alpha = hud.combo.number.start.alpha;
                number.visible = true;

                FlxTween.tween(number, {
                    x: baseNumberPosition.x + hud.combo.number.end.x,
                    y: baseNumberPosition.y + hud.combo.number.end.y,
                    alpha: hud.combo.number.end.alpha
                }, hud.combo.number.duration, {
                    ease: StringUtil.easeFromString(hud.combo.number.ease),
                    onComplete: _ -> number.visible = false
                });

                baseNumberPosition.put();
            }

            basePosition.put();
        }

        scriptsManager.callback(POST, 'ComboDisplay', [rating]);
    }

    var uiGroup:FlxGroup;

    var healthBar:Bar;
    var scoreText:FlxText;

    function initHud()
    {
        if (scriptsManager.callback(ON, 'HudInit'))
        {
            add(uiGroup = new FlxGroup());
            uiGroup.camera = camHUD;

            healthBar = new Bar(hudRoute + '/' + hud.bar, hudRoute + '/' + hud.barFilling, false, health);
            healthBar.x = FlxG.width / 2 - healthBar.width / 2;
            healthBar.y = FlxG.height * (ClientPrefs.data.downScroll ? 0.1 : 0.9);
            healthBar.fillingBack.color = CoolUtil.colorFromString((dad ?? gf ?? bf)._castConfig.barColor);
            healthBar.fillingFront.color = CoolUtil.colorFromString((bf ?? gf ?? dad)._castConfig.barColor);
            uiGroup.add(healthBar);

            scoreText = new FlxText(0, healthBar.y + 40, FlxG.width, '');
            scoreText.setFormat(Paths.font(hud.textFont), 17, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            scoreText.borderSize = 1.25;
            uiGroup.add(scoreText);

            updateScoreText();
        }

        scriptsManager.callback(POST, 'HudInit');
    }

    function updateScoreText()
    {
        if (scriptsManager.callback(ON, 'ScoreTextUpdate'))
            scoreText.text = botplay ? 'BOTPLAY' : 'Score: ' + score + '    Misses: ' + misses + '    Accuracy: ' + CoolUtil.floorDecimal(get_accuracy(), 2) + '%';

        scriptsManager.callback(POST, 'ScoreTextUpdate');
    }

    function updateHealth()
    {
        if (scriptsManager.callback(ON, 'HealthUpdate'))
        {
            healthBar.percent = health;

            if (health <= 0 && !ClientPrefs.data.practice)
                overGame();
        }

        scriptsManager.callback(POST, 'HealthUpdate');
    }

    var icons:FlxTypedGroup<Icon>;

    var playerIcons:FlxTypedGroup<Icon>;
    var opponentIcons:FlxTypedGroup<Icon>;
    var extraIcons:FlxTypedGroup<Icon>;

    var iconFactory:(String, CharacterType) -> Icon = (icon, type) -> new Icon(icon, type);

    function initIcons()
    {
        if (scriptsManager.callback(ON, 'IconsInit'))
        {
            uiGroup.insert(uiGroup.members.indexOf(scoreText), icons = new FlxTypedGroup<Icon>());

            playerIcons = new FlxTypedGroup<Icon>();
            opponentIcons = new FlxTypedGroup<Icon>();
            extraIcons = new FlxTypedGroup<Icon>();

            for (char in [dad ?? gf ?? bf, bf ?? gf ?? dad])
            {
                final icon:Icon = iconFactory(char._castConfig.icon, char.type);
                addIcon(icon);
            }
        }

        scriptsManager.callback(POST, 'IconsInit');
    }

    var nextIconToAdd:Icon;

    function addIcon(icon:Icon)
    {
        nextIconToAdd = icon;
        
        if (scriptsManager.callback(ON, 'IconAdd', null, [nextIconToAdd]))
        {
            nextIconToAdd.bar = healthBar;

            switch (nextIconToAdd.type)
            {
                case PLAYER:
                    playerIcons.add(nextIconToAdd);

                case OPPONENT:
                    opponentIcons.add(nextIconToAdd);

                case EXTRA:
                    extraIcons.add(nextIconToAdd);
            }

            icons.add(nextIconToAdd);
        }

        scriptsManager.callback(POST, 'IconAdd', null, [nextIconToAdd]);
    }

    var nextIconToChange:Icon;

    function changeIcon(icon:Icon, id:String)
    {
        nextIconToChange = icon;

        if (scriptsManager.callback(ON, 'IconChange', null, [nextIconToChange]))
            icon?.change(id);

        scriptsManager.callback(POST, 'IconChange', null, [nextIconToChange]);
    }

    var strumLines:FlxTypedGroup<StrumLine>;

    var playerStrumLines:FlxTypedGroup<StrumLine>;
    var opponentStrumLines:FlxTypedGroup<StrumLine>;
    var extraStrumLines:FlxTypedGroup<StrumLine>;

    var strums:FlxTypedGroup<Strum>;

    var playerStrums:FlxTypedGroup<Strum>;
    var opponentStrums:FlxTypedGroup<Strum>;
    var extraStrums:FlxTypedGroup<Strum>;

    var strumLineFactory:(String, CharacterType, Int, Array<Array<Dynamic>>, Note -> Bool) -> StrumLine = (id, type, index, notes, stack) -> new StrumLine(id, type, index, notes, stack);

    function initStrumLines()
    {
        if (scriptsManager.callback(ON, 'StrumLinesInit'))
        {
            add(strumLines = new FlxTypedGroup<StrumLine>());
            
            playerStrumLines = new FlxTypedGroup<StrumLine>();
            opponentStrumLines = new FlxTypedGroup<StrumLine>();
            extraStrumLines = new FlxTypedGroup<StrumLine>();

            strums = new FlxTypedGroup<Strum>();
            
            playerStrums = new FlxTypedGroup<Strum>();
            opponentStrums = new FlxTypedGroup<Strum>();
            extraStrums = new FlxTypedGroup<Strum>();

            final notes = [];

            if (spawnNotes)
            {
                for (section in chart.sections)
                {
                    if (section.changeBPM)
                        Conductor.bpm = section.bpm;

                    for (note in section.notes)
                    {
                        if (note[0] < startTime)
                            continue;

                        notes[note[4]] ??= [];

                        notes[note[4]].push([
                            note[0],
                            note[1],
                            note[2],
                            note[3],
                            note[5],
                            Conductor.stepCrochet
                        ]);
                    }
                }
            }

            Conductor.bpm = chart.bpm;

            for (index => strl in chart.strumLines)
            {
                final strumLine:StrumLine = strumLineFactory(strl.file, strl.type, index, notes[index], stackNote);

                addStrumLine(strumLine);
                
                strumLine.noteSpawnCallback = spawnNote;
                strumLine.noteHitCallback = hitNote;
                strumLine.noteMissCallback = missNote;
                strumLine.visible = strl.visible;
                strumLine.missWindow = hud.ratings[hud.ratings.length - 1].time;

                strumLine.camera = camHUD;

                var strumsOffsetX:Float = 0;
                var strumsOffsetY:Float = 0;

                for (strumIndex => strum in strumLine.strums.members)
                {
                    strumsOffsetX += strumIndex >= strumLine.strums.length - 1 ? strum.width : strumLine.config.spacing;

                    strumsOffsetY = Math.max(strumsOffsetY, strum.height);
                    
                    addStrum(strum);
                }

                strumLine.x = strumLine.type == PLAYER ? FlxG.width - strl.position.x - strumsOffsetX : strl.position.x;
                strumLine.y = strumLine.downScroll ? FlxG.height - strl.position.y - strumsOffsetY : strl.position.y;
            }
        }

        scriptsManager.callback(POST, 'StrumLinesInit');
    }

    var nextNoteToStack:Note;

    function stackNote(note:Note):Bool
    {
        nextNoteToStack = note;

        final result:Bool = scriptsManager.callback(ON, 'NoteStack', null, [nextNoteToStack]);

        if (result)
            if (!totalNoteTypes.contains(nextNoteToStack.noteType))
                totalNoteTypes.push(nextNoteToStack.noteType);

        scriptsManager.callback(POST, 'NoteStack', null, [nextNoteToStack]);

        return result;
    }

    var nextNoteToSpawn:Note;

    function spawnNote(note:Note):Bool
    {
        nextNoteToSpawn = note;

        final result:Bool = scriptsManager.callback(ON, 'NoteSpawn', null, [nextNoteToSpawn]);

        scriptsManager.callback(POST, 'NoteSpawn', null, [nextNoteToSpawn]);

        return result;
    }

    var nextNoteToHit:Note;
    var nextNoteToHitCharacter:Character;

    function hitNote(note:Note, timeDistance:Float, removeNote:Bool):Bool
    {
        nextNoteToHit = note;
        nextNoteToHitCharacter = characterFromNote(nextNoteToHit);
        
        final rating:JsonHudRating = note.type == ARROW ? judgeNote(timeDistance) : null;

        final result:Bool = scriptsManager.callback(ON, 'NoteHit', null, [nextNoteToHit, nextNoteToHitCharacter, rating, timeDistance, removeNote] #if ALLOW_LUA , [rating, timeDistance, removeNote] #end);

        if (result)
        {
            nextNoteToHitCharacter?.sing(note.type != ARROW && !nextNoteToHitCharacter._castConfig.sustainAnimation ? null : note.strumLineConfig.sing);

            if (rating != null && note.strumLine.type == PLAYER)
            {
                if (rating.splash && !note.strumLine.botplay)
                    note.splash?.splash();

                score += rating.score;

                accuracyMod += rating.accuracy;

                totalNotes++;

                health += note.singHealth;

                combo++;

                updateScoreText();

                displayCombo(rating);
            }
        }

        scriptsManager.callback(POST, 'NoteHit', null, [nextNoteToHit, nextNoteToHitCharacter, timeDistance, removeNote] #if ALLOW_LUA , [rating, timeDistance, removeNote] #end);

        return result;
    }

    function judgeNote(time:Float):JsonHudRating
    {
        time = Math.abs(time);

        var result = hud.ratings[0];

        var index:Int = 0;

        while (time > result.time && index < hud.ratings.length)
            result = hud.ratings[index++];

        return result;
    }

    var nextNoteToMiss:Note;
    var nextNoteToMissCharacter:Character;

    function missNote(note:Note):Bool
    {
        nextNoteToMiss = note;
        nextNoteToMissCharacter = characterFromNote(nextNoteToMiss);

        final result:Bool = scriptsManager.callback(ON, 'NoteMiss', null, [nextNoteToMiss, nextNoteToMissCharacter]);

        if (result)
        {
            nextNoteToMissCharacter?.miss(note.type != ARROW && !nextNoteToMissCharacter._castConfig.sustainAnimation ? null : note.strumLineConfig.miss);

            if (nextNoteToMissCharacter.type == PLAYER)
            {
                if (note.type == ARROW)
                {
                    health -= note.missHealth;
                    
                    combo = 0;

                    misses++;

                    totalNotes++;

                    updateScoreText();
                }
            }
        }

        scriptsManager.callback(POST, 'NoteMiss', null, [nextNoteToMiss, nextNoteToMissCharacter]);

        return result;
    }

    function characterFromNote(note:Note)
        return charactersArray[note.character[0]][note.character[1]];

    var nextStrumLineToAdd:StrumLine;

    function addStrumLine(strl:StrumLine)
    {
        nextStrumLineToAdd = strl;

        if (scriptsManager.callback(ON, 'StrumLineAdd', null, [nextStrumLineToAdd]))
        {
            switch (nextStrumLineToAdd.type)
            {
                case PLAYER:
                    playerStrumLines.add(nextStrumLineToAdd);

                case OPPONENT:
                    opponentStrumLines.add(nextStrumLineToAdd);

                case EXTRA:
                    extraStrumLines.add(nextStrumLineToAdd);
            }

            strumLines.add(nextStrumLineToAdd);
        }

        scriptsManager.callback(POST, 'StrumLineAdd', null, [nextStrumLineToAdd]);
    }

    var nextStrumToAdd:Strum;

    function addStrum(strum:Strum)
    {
        nextStrumToAdd = strum;

        if (scriptsManager.callback(ON, 'StrumAdd', null, [nextStrumToAdd]))
        {
            switch (nextStrumToAdd.strumLine.type)
            {
                case PLAYER:
                    playerStrums.add(nextStrumToAdd);

                case OPPONENT:
                    opponentStrums.add(nextStrumToAdd);

                case EXTRA:
                    extraStrums.add(nextStrumToAdd);
            }

            strums.add(nextStrumToAdd);
        }

        scriptsManager.callback(POST, 'StrumAdd', null, [nextStrumToAdd]);
    }

        function initControls()
    {
        if (scriptsManager.callback(ON, 'ControlsInit'))
        {
            FlxG.stage.addEventListener('keyDown', justPressedKey);
            FlxG.stage.addEventListener('keyUp', justReleasedKey);
        }

        scriptsManager.callback(POST, 'ControlsInit');
    }

    function justPressedKey(event:KeyboardEvent)
    {
        if (!updating)
            return;

        if (Controls.anyJustPressed([event.keyCode]))
        {
            if (scriptsManager.callback(ON, 'KeyJustPressed', null, [event] #if ALLOW_LUA , [event.keyCode] #end))
                strumLines.forEachAlive(strl -> strl.justPressedKey(event.keyCode));

            scriptsManager.callback(POST, 'KeyJustPressed', null, [event] #if ALLOW_LUA , [event.keyCode] #end);
        }
    }

    function justReleasedKey(event:KeyboardEvent)
    {
        if (!updating)
            return;

        if (Controls.anyJustReleased([event.keyCode]))
        {
            if (scriptsManager.callback(ON, 'KeyJustReleased', null, [event] #if ALLOW_LUA , [event.keyCode] #end))
                strumLines.forEachAlive(strl -> strl.justReleasedKey(event.keyCode));

            scriptsManager.callback(POST, 'KeyJustReleased', null, [event] #if ALLOW_LUA , [event.keyCode] #end);
        }
    }

    final soundsCache:Map<String, OpenFLSound> = new Map<String, OpenFLSound>();

    function initSounds()
    {
        if (scriptsManager.callback(ON, 'SoundsInit'))
        {
            soundsCache.set('::MUSIC', Paths.inst(songRoute));

            for (postfix in [null, 'Player', 'Opponent', 'Extra'])
            {
                final audio:OpenFLSound = Paths.voices(songRoute, postfix, false, false);

                if (audio != null)
                    soundsCache.set('::' + (postfix == null ? 'VOICES' : postfix.toUpperCase()), audio);

                for (char in characters)
                {
                    final audio:OpenFLSound = Paths.voices(songRoute, char.id, false, false);

                    if (audio != null)
                        soundsCache.set(char.id, audio);
                }
            }
        }

        scriptsManager.callback(POST, 'SoundsInit');
    }

    var vocals:Array<Sound> = [];

    function addVocal(sound:Sound)
    {
        if (scriptsManager.callback(ON, 'VocalAdd', null, [sound]))
        {
            if (sound != null)
            {
                vocals.push(sound);

                Conductor.synchronizedSounds.push(sound);

                FlxG.sound.list.add(sound);
            }
        }

        scriptsManager.callback(POST, 'VocalAdd', null, [sound]);
    }


    function initSong()
    {
        if (scriptsManager.callback(ON, 'SongInit'))
        {
            if (skipCountdown || startTime > 0)
                FlxTimer.wait(0.001, startSong);
            else
                startCountdown();
        }

        scriptsManager.callback(POST, 'SongInit');
    }

    var countdownSprite:FunkinSprite;

    function startCountdown()
    {
        if (scriptsManager.callback(ON, 'CountdownStart'))
        {
            add(countdownSprite = new FunkinSprite());
            countdownSprite.camera = camOther;
            countdownSprite.visible = false;

            ReflectUtil.setProperties(countdownSprite, hud.countdown.properties);

            for (count in hud.countdown.list)
            {
                final route:String = hudRoute + '/countdown/' + count;

                Paths.image(route, false, false);
                Paths.sound(route, false, false);
            }

            tickCountdown(0);

            FlxTimer.loop(Conductor.secCrochet, index -> tickCountdown(index), hud.countdown.list.length - 1);

            Conductor.time = -Conductor.crochet * hud.countdown.list.length;

            FlxTween.tween(Conductor, {time: 0}, -Conductor.time / 1000, { onComplete: _ -> startSong() });
        }

        scriptsManager.callback(POST, 'CountdownStart');
    }

    function tickCountdown(index:Int)
    {
        if (scriptsManager.callback(ON, 'CountdownTick', [index]))
        {
            final route:String = hudRoute + '/countdown/' + hud.countdown.list[index];

            final graphic:FlxGraphic = Paths.image(route, false, false);

            if (graphic != null)
            {
                FlxTween.cancelTweensOf(countdownSprite);
                FlxTween.cancelTweensOf(countdownSprite.scale);

                countdownSprite.loadGraphic(graphic);

                countdownSprite.scale.x = hud.countdown.start.scale.x;
                countdownSprite.scale.y = hud.countdown.start.scale.y;

                countdownSprite.updateHitbox();

                final basePosition:FlxPoint = FlxPoint.get(FlxG.width / 2 - countdownSprite.width / 2, FlxG.height / 2 - countdownSprite.height / 2);

                countdownSprite.visible = true;

                countdownSprite.x = basePosition.x + hud.countdown.start.x;
                countdownSprite.y = basePosition.y + hud.countdown.start.y;
                countdownSprite.alpha = hud.countdown.start.alpha;

                FlxTween.tween(countdownSprite, {x: basePosition.x + hud.countdown.end.x, y: basePosition.y + hud.countdown.end.y, alpha: hud.countdown.end.alpha}, Conductor.secCrochet * hud.countdown.beats, { ease: StringUtil.easeFromString(hud.countdown.ease), onComplete: _ -> countdownSprite.visible = false });
                FlxTween.tween(countdownSprite.scale, {x: hud.countdown.end.scale.x, y: hud.countdown.end.scale.y}, Conductor.secCrochet * hud.countdown.beats, { ease: StringUtil.easeFromString(hud.countdown.ease)});

                basePosition.put();
            }

            final sound:OpenFLSound = Paths.sound(route, false, false);

            if (sound != null)
                CoolUtil.playSound(route);
        }

        scriptsManager.callback(POST, 'CountdownTick', [index]);
    }

    function startSong()
    {
        if (scriptsManager.callback(ON, 'SongStart'))
        {
            Conductor.play(soundsCache.get('::MUSIC'), chart.bpm, chart.stepsPerBeat, chart.beatsPerSection, false, 0.85);

            Conductor.music.time = startTime;

            var voices:Null<Sound> = null;

            if (soundsCache.exists('::VOICES'))
            {
                voices = new Sound();
                voices.loadEmbedded(soundsCache.get('::VOICES'));
            }

            var playersVoices:Null<Sound> = null;

            if (soundsCache.exists('::PLAYER'))
            {
                playersVoices = new Sound();
                playersVoices.loadEmbedded(soundsCache.get('::PLAYER'));
            }

            var opponentsVoices:Null<Sound> = null;

            if (soundsCache.exists('::OPPONENT'))
            {
                opponentsVoices = new Sound();
                opponentsVoices.loadEmbedded(soundsCache.get('::OPPONENT'));
            }

            var extrasVoices:Null<Sound> = null;

            if (soundsCache.exists('::EXTRA'))
            {
                extrasVoices = new Sound();
                extrasVoices.loadEmbedded(soundsCache.get('::EXTRA'));
            }

            for (sound in [voices, playersVoices, opponentsVoices, extrasVoices])
                if (sound != null)
                    addVocal(sound);

            final charVocals = new Map<String, Sound>();

            for (char in characters)
            {
                if (voices != null)
                    char.vocals.push(voices);

                final defaultVoice:Null<Sound> = switch (char.type)
                {
                    case PLAYER:
                        playersVoices;

                    case OPPONENT:
                        opponentsVoices;

                    case EXTRA:
                        extrasVoices;
                }

                if (defaultVoice != null)
                    char.vocals.push(defaultVoice);

                var voice:Null<Sound> = null;

                if (charVocals.exists(char.id))
                {
                    voice = charVocals.get(char.id);
                } else if (soundsCache.exists(char.id)) {
                    voice = new Sound();
                    voice.loadEmbedded(soundsCache.get(char.id));

                    addVocal(voice);

                    charVocals.set(char.id, voice);
                }

                if (voice != null)
                    char.vocals.push(voice);
            }

            for (voice in vocals)
            {
                voice.play();

                voice.time = startTime;
            }
        }

        scriptsManager.callback(POST, 'SongStart');
    }

    var camOther:FXCamera;

    var allowCameraMoving:Bool = true;

    var cameraTarget:Character;

    function moveCamera(?char:OneOfTwo<Character, Int>, ?force:Bool = false)
    {
        var character:Character = null;

        if (char is FlxSprite)
        {
            character = cast char;
        } else {
            final songSection = chart.sections[char];
            
            if (songSection != null)
                character = charactersArray[songSection.camera[0]][songSection.camera[1]];
        }

        if (character != null)
            cameraTarget = character;

        if (scriptsManager.callback(ON, 'CameraMove', null, [cameraTarget]))
        {
            if ((allowCameraMoving || force) && character != null)
            {
                final pos:Point = getCharacterCamera(character);

                cast(camGame, FXCamera).position.set(pos.x, pos.y);
            }
        }

        scriptsManager.callback(POST, 'CameraMove', null, [cameraTarget]);
    }


    var bopModulo(never, set):Int;
    function set_bopModulo(value:Int):Int
    {
        for (cam in [camGame, camHUD])
            if (cam is FXCamera)
                cast(cam, FXCamera).bopModulo = value;

        return value;
    }
    
    var bopZoom(never, set):Int;
    function set_bopZoom(value:Int):Int
    {
        if (camGame is FXCamera)
            cast(camGame, FXCamera).bopZoom = value;

        if (camHUD is FXCamera)
            cast(camHUD, FXCamera).bopZoom = value * 2;

        return value;
    }
    
    var defaultCamZoom(never, set):Float;
    function set_defaultCamZoom(value:Float):Float
    {
        if (camGame is FXCamera)
            cast(camGame, FXCamera).targetZoom = value;

        return value;
    }
    
    var defaultHudZoom(never, set):Float;
    function set_defaultHudZoom(value:Float):Float
    {
        if (camHUD is FXCamera)
            cast(camHUD, FXCamera).targetZoom = value;

        return value;
    }

    var iconsBopModulo(never, set):Int;
    function set_iconsBopModulo(value:Int):Int
    {
        for (icon in icons)
            icon._castConfig.bopModulo = value;

        return value;
    }

    var cameraSpeed(never, set):Float;
    function set_cameraSpeed(value:Float):Float
    {
        cast(camGame, FXCamera).speed = value;

        return value;
    }

    var cameraZoomSpeed(never, set):Float;
    function set_cameraZoomSpeed(value:Float):Float
    {
        cast(camGame, FXCamera).zoomSpeed = cast(camGame, FXCamera).zoomSpeed = value;

        return value;
    }
    
    var boyfriend(get, never):Character;
    function get_boyfriend():Character
        return bf;

    var bf(get, never):Character;
    function get_bf():Character
        return playerCharacters.members[0];

    var dad(get, never):Character;
    function get_dad():Character
        return opponentCharacters.members[0];

    var gf(get, never):Character;
    function get_gf():Character
        return extraCharacters.members[0];

    var iconP1(get, never):Icon;
    function get_iconP1():Icon
        return playerIcons.members[0];

    var iconP2(get, never):Icon;
    function get_iconP2():Icon
        return opponentIcons.members[0];

    var iconP3(get, never):Icon;
    function get_iconP3():Icon
        return extraIcons.members[0];

    var scoreTxt(get, never):FlxText;
    function get_scoreTxt():FlxText
        return scoreText;

    var strumLineNotes(get, never):FlxTypedGroup<Strum>;
    function get_strumLineNotes():FlxTypedGroup<Strum>
        return strums;

    inline function addBehindOpponents(obj:FlxBasic):FlxBasic
        return addBehindGroup(opponentCharacters, obj);

    inline function addBehindPlayers(obj:FlxBasic):FlxBasic
        return addBehindGroup(playerCharacters, obj);

    inline function addBehindExtras(obj:FlxBasic):FlxBasic
        return addBehindGroup(extraCharacters, obj);

    inline function addAheadOpponents(obj:FlxBasic):FlxBasic
        return addAheadGroup(opponentCharacters, obj);

    inline function addAheadPlayers(obj:FlxBasic):FlxBasic
        return addAheadGroup(playerCharacters, obj);

    inline function addAheadExtras(obj:FlxBasic):FlxBasic
        return addAheadGroup(extraCharacters, obj);

    inline function addBehindDad(obj:FlxBasic):FlxBasic
        return addBehindOpponents(obj);

    inline function addBehindBF(obj:FlxBasic):FlxBasic
        return addBehindPlayers(obj);

    inline function addBehindGF(obj:FlxBasic):FlxBasic
        return addBehindExtras(obj);

    inline function addAheadDad(obj:FlxBasic):FlxBasic
        return addAheadOpponents(obj);

    inline function addAheadBF(obj:FlxBasic):FlxBasic
        return addAheadPlayers(obj);

    inline function addAheadGF(obj:FlxBasic):FlxBasic
        return addAheadExtras(obj);
}