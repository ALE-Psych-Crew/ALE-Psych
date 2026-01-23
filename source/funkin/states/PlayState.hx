package funkin.states;

import openfl.events.KeyboardEvent;
import openfl.media.Sound;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxBasic;

import core.structures.ALESongSection;
import core.structures.ALEEventList;
import core.structures.ALEEvent;
import core.structures.ALEStage;
import core.structures.ALEStageObject;
import core.structures.ALEStageObjectsConfig;
import core.structures.ALESong;
import core.structures.ALEHud;
import core.structures.Point;
import core.enums.SongType;
import core.enums.Rating;

import utils.ALEFormatter;

import haxe.ds.StringMap;
import haxe.ds.GenericStack;

import funkin.visuals.game.*;
import funkin.visuals.objects.Bar;
import funkin.visuals.FXCamera;

class PlayState extends ScriptState
{
    public static var instance:PlayState;

    public var CHART:ALESong;
    public var STAGE:ALEStage;
    public var HUD:ALEHud;

    public final song:String;
    public final playlist:Array<String>;
    public final difficulty:String;
    public final songIndex:Int;
    public final songRoute:String;

    public final type:SongType;

    public var score:Float = 0;
    public var totalPlayed:Int = 0;
    public var accuracyMod:Float = 0;
    public var misses:Int = 0;
    public var combo:Int = 0;

    public var accuracy(get, never):Float;
    function get_accuracy():Float
        return totalPlayed == 0 ? 0 : accuracyMod / totalPlayed;

    public var botplay(default, set):Bool;
    function set_botplay(value:Bool):Bool
    {
        botplay = value;

        for (strl in strumLines)
            strl.botplay = strl.type != 'player' || botplay;

        return botplay;
    }

    public var health(default, set):Float = 1;
    function set_health(value:Float):Float
    {
        health = FlxMath.bound(value, 0, 2);

        updateHealth();

        return health;
    }

    public function new(?type:SongType, ?playlist:Array<String>, ?difficulty:String, ?songIndex:Int)
    {
        super();

        this.type = type ?? FREEPLAY;

        this.playlist = playlist ?? ['bopeebo'];
        this.difficulty = difficulty ?? 'hard';
        this.songIndex = songIndex ?? 0;
        this.song = this.playlist[this.songIndex];

        CHART ??= ALEFormatter.getSong(this.song, this.difficulty);
        STAGE ??= ALEFormatter.getStage(CHART.stage);
        HUD ??= ALEFormatter.getHud(STAGE.hud);

        songRoute = CoolUtil.searchComplexFile('songs/' + this.song);
    }

    public var shouldMoveCamera:Bool = true;

    public var allowSongPositionUpdate:Bool = false;

    public var skipCountdown:Bool = false;

    public var spawnNotes:Bool = true;
    
    public var canPause:Bool = true;

    var totalNoteTypes:Array<String> = [];
    var totalEvents:Array<String> = [];

    override function create()
    {
        instance = this;

        super.create();

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in [songRoute + '/scripts', 'scripts/songs'])
			if (Paths.exists(folder) && Paths.isDirectory(folder))
					for (file in Paths.readDirectory(folder))
						if (file.endsWith('.lua') || file.endsWith('.hx'))
							loadScript(folder + '/' + file);

		loadScript('scripts/stages/' + CHART.stage);
		#end

        if (scriptCallbackCall(ON, 'Create'))
        {
            Conductor.calculateBPMChanges(CHART);

            add(comboGroup = new FlxTypedSpriteGroup<FlxSprite>(HUD.combo.position.x, HUD.combo.position.y));
            add(uiGroup = new FlxTypedGroup<FlxBasic>());
            add(strumLines = new FlxTypedGroup<StrumLine>());

            initCameras();

            initStrumLines();

            botplay = ClientPrefs.data.botplay;

            initEvents();
            initStage();
            initControls();
            initHud();

            initSounds();
            initCombo();

            startCountdown();
            
            #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
            for (notetype in totalNoteTypes)
                loadScript('scripts/noteTypes/' + notetype);

            for (event in totalEvents)
                loadScript('scripts/events/' + event);
            #end
        }

        scriptCallbackCall(POST, 'Create');
    }

    override function update(elapsed:Float)
    {
        if (scriptCallbackCall(ON, 'Update', [elapsed]))
        {
            if ((FlxG.sound.music != null && FlxG.sound.music.playing) || allowSongPositionUpdate)
                Conductor.songPosition += elapsed * 1000;
                
            super.update(elapsed);

            while (!eventsListStack.isEmpty() && eventsListStack.first().time <= Conductor.songPosition)
                for (event in eventsListStack.pop().events)
                    eventHit(event);

            updateScoreText();

            if (Controls.PAUSE && canPause)
                pause();

            if (Controls.RESET)
                if (CoolVars.data.developerMode)
                    restart();
                else
                    health = 0;
        }

        scriptCallbackCall(POST, 'Update', [elapsed]);
    }

    function updateScoreText()
    {
        if (scriptCallbackCall(ON, 'ScoreTextUpdate'))
            scoreText.text = botplay ? 'BOTPLAY' : 'Score: ' + score + '    Misses: ' + misses + '    Accuracy: ' + CoolUtil.floorDecimal(accuracy, 2) + '%';

        scriptCallbackCall(POST, 'ScoreTextUpdate');
    }

    function pause()
    {
        if (scriptCallbackCall(ON, 'Pause'))
        {
			FlxTimer.globalManager.forEach((tmr) -> if (!tmr.finished) tmr.active = false);

			FlxTween.globalManager.forEach((twn) ->  if (!twn.finished) twn.active = false);

            pauseMusic();

            CoolUtil.openSubState(new CustomSubState(CoolVars.data.pauseSubState));
        }

        scriptCallbackCall(POST, 'Pause');
    }

    function resume()
    {
        if (scriptCallbackCall(ON, 'Resume'))
        {
			FlxTimer.globalManager.forEach((tmr) -> if (!tmr.finished) tmr.active = true);

			FlxTween.globalManager.forEach((twn) ->  if (!twn.finished) twn.active = true);

            resumeMusic();
        }

        scriptCallbackCall(POST, 'Resume');
    }

    function restart()
    {
        if (scriptCallbackCall(ON, 'Restart'))
        {
            shouldClearMemory = false;

            pauseMusic();
            
            CoolUtil.switchState(new PlayState(type, playlist, difficulty, songIndex), true, true);
        }

        scriptCallbackCall(POST, 'Restart');
    }

    override function destroy()
    {
        if (scriptCallbackCall(ON, 'Destroy'))
        {
            FlxG.stage.removeEventListener('keyDown', justPressedKey);
            FlxG.stage.removeEventListener('keyUp', justReleasedKey);
            
            pauseMusic();
        }

        super.destroy();

        scriptCallbackCall(POST, 'Destroy');

        destroyScripts();
        
        instance = null;
    }

    override function stepHit(curStep:Int)
    {
        if (scriptCallbackCall(ON, 'StepHit', [curStep]))
        {
            super.stepHit(curStep);

            if (FlxG.sound.music != null && FlxG.sound.music.time >= -ClientPrefs.data.offset)
            {
                final timeSub:Float = Conductor.songPosition - Conductor.offset;
                final syncTime:Float = 20;

                for (audio in [FlxG.sound.music].concat(vocals))
                {
                    if (audio != null && audio.length > 0)
                    {
                        if (Math.abs(audio.time - timeSub) > syncTime)
                        {
                            resyncVocals();

                            break;
                        }
                    }
                }
            }
        }

        scriptCallbackCall(POST, 'StepHit', [curStep]);
    }

    override function beatHit(curBeat:Int)
    {
        if (scriptCallbackCall(ON, 'BeatHit', [curBeat]))
        {
            super.beatHit(curBeat);

            for (camera in [camGame, camHUD])
                cast(camera, FXCamera).bop(curBeat);
        }

        scriptCallbackCall(POST, 'BeatHit', [curBeat]);
    }

    override function sectionHit(curSection:Int)
    {
        if (scriptCallbackCall(ON, 'SectionHit', [curSection]))
        {
            super.sectionHit(curSection);

            final songSection:ALESongSection = CHART.sections[curSection];

            if (songSection == null)
                return;

            moveCamera(cameraCharacters[songSection.camera[0]][songSection.camera[1]]);
        }

        scriptCallbackCall(POST, 'SectionHit', [curSection]);
    }

    override public function safeStepHit(safeStep:Int)
    {
        if (scriptCallbackCall(ON, 'SafeStepHit', [safeStep]))
            super.safeStepHit(safeStep);

        scriptCallbackCall(POST, 'SafeStepHit', [safeStep]);
    }

    override public function safeBeatHit(safeBeat:Int)
    {
        if (scriptCallbackCall(ON, 'SafeBeatHit', [safeBeat]))
            super.safeBeatHit(safeBeat);

        scriptCallbackCall(POST, 'SafeBeatHit', [safeBeat]);
    }

    override public function safeSectionHit(safeSection:Int)
    {
        if (scriptCallbackCall(ON, 'SafeSectionHit', [safeSection]))
            super.safeSectionHit(safeSection);

        scriptCallbackCall(POST, 'SafeSectionHit', [safeSection]);
    }

    override public function onFocus()
    {
        if (scriptCallbackCall(ON, 'OnFocus'))
            super.onFocus();

        scriptCallbackCall(POST, 'OnFocus');
    }

    override public function onFocusLost()
    {
        if (scriptCallbackCall(ON, 'OnFocusLost'))
            super.onFocusLost();

        scriptCallbackCall(POST, 'OnFocusLost');
    }

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        if (scriptCallbackCall(ON, 'OpenSubState', null, [substate], [Type.getClassName(Type.getClass(substate))]))
            super.openSubState(substate);

        scriptCallbackCall(POST, 'OpenSubState', null, [substate], [Type.getClassName(Type.getClass(substate))]);
    }

    override public function closeSubState():Void
    {
        if (scriptCallbackCall(ON, 'CloseSubState'))
            super.closeSubState();

        scriptCallbackCall(POST, 'CloseSubState');
    }

    function eventHit(event:ALEEvent)
    {
        scriptCallbackCall(ON, 'EventHit', cast([event.id], Array<Dynamic>).concat(event.values));

        scriptCallbackCall(POST, 'EventHit', cast([event.id], Array<Dynamic>).concat(event.values));
    }

    public var countdownSprite:FlxSprite;

    function startCountdown()
    {
        if (skipCountdown)
        {
            startSong();
            
            return;
        }

        if (scriptCallbackCall(ON, 'StartCountdown'))
        {
            countdownSprite = new FlxSprite();
            countdownSprite.alpha = 0;
            countdownSprite.cameras = [camOther];
            countdownSprite.antialiasing = HUD.antialiasing && ClientPrefs.data.antialiasing;

            add(countdownSprite);
            
            final ids:Array<String> = [null, 'ready', 'set', 'go'];

            final graphics:Array<FlxGraphic> = [for (spr in ids) spr == null ? null : Paths.image('hud/' + STAGE.hud + '/countdown/' + spr)];

            final sounds:Array<Sound> = [for (spr in ['three', 'two', 'one', 'go']) spr == null ? null : Paths.sound('hud/' + STAGE.hud + '/countdown/' + spr)];

            allowSongPositionUpdate = true;
            
            Conductor.songPosition = -Conductor.crochet * 5;

            FlxTimer.loop(Conductor.crochet / 1000, (loop) -> {
                tickCountdown(loop - 1, graphics[loop - 1], sounds[loop - 1]);
            }, 5);
        }

        scriptCallbackCall(POST, 'StartCountdown');
    }

    function tickCountdown(val:Int, graphic:FlxGraphic, sound:Sound)
    {
        if (scriptCallbackCall(ON, 'CountdownTick', null, [val, graphic, sound], [val]))
        {
            if (val == 4)
            {
                remove(countdownSprite);
                
                allowSongPositionUpdate = false;

                startSong();

                return;
            }

            FlxG.sound.play(sound);

            if (graphic != null)
            {
                countdownSprite.loadGraphic(graphic);

                FlxTween.cancelTweensOf(countdownSprite);
                FlxTween.cancelTweensOf(countdownSprite.scale);

                countdownSprite.scale.x = countdownSprite.scale.y = HUD.countdown.scale;
                countdownSprite.alpha = HUD.countdown.alpha;

                countdownSprite.updateHitbox();
                countdownSprite.screenCenter();

                FlxTween.tween(countdownSprite.scale, {x: HUD.countdown.endScale, y: HUD.countdown.endScale}, Conductor.crochet / 1000 * HUD.countdown.beats, {ease: CoolUtil.easeFromString(HUD.countdown.scaleEase)});

                FlxTween.tween(countdownSprite, {alpha: HUD.countdown.endAlpha}, Conductor.crochet / 1000 * HUD.countdown.beats, {ease: CoolUtil.easeFromString(HUD.countdown.alphaEase)});

                characters.forEachAlive((char) -> {
                    char.beatHit(val);
                });
            }
        }
        
        scriptCallbackCall(POST, 'CountdownTick', null, [val, graphic, sound], [val]);
    }

    function startSong()
    {
        if (scriptCallbackCall(ON, 'SongStart'))
        {
            FlxG.sound.playMusic(soundsMap.get('::MUSIC'), 0.85, false);
            
            FlxG.sound.music.onComplete = endSong.bind();

            var voices:Null<FlxSound> = null;

            if (soundsMap.exists('::VOICES'))
                voices = new FlxSound().loadEmbedded(soundsMap.get('::VOICES'));

            var playerVoices:Null<FlxSound> = null;

            if (soundsMap.exists('::PLAYER'))
                playerVoices = new FlxSound().loadEmbedded(soundsMap.get('::PLAYER'));

            var opponentVoices:Null<FlxSound> = null;

            if (soundsMap.exists('::OPPONENT'))
                opponentVoices = new FlxSound().loadEmbedded(soundsMap.get('::OPPONENT'));

            var extraVoices:Null<FlxSound> = null;

            if (soundsMap.exists('::EXTRA'))
                extraVoices = new FlxSound().loadEmbedded(soundsMap.get('::EXTRA'));

            for (sound in [voices, playerVoices, opponentVoices, extraVoices])
                if (sound != null)
                    addVocal(sound);

            final existingCharactersVocals:StringMap<FlxSound> = new StringMap();

            characters.forEachAlive((char) ->
            {
                if (voices != null)
                    char.vocals.push(voices);

                final defaultVoice:Null<FlxSound> = switch (cast char.type)
                {
                    case 'player':
                        playerVoices;

                    case 'opponent':
                        opponentVoices;

                    case 'extra':
                        extraVoices;

                    default:
                        null;
                };

                if (defaultVoice != null)
                    char.vocals.push(defaultVoice);

                var voice:Null<FlxSound> = null;

                if (existingCharactersVocals.exists(char.id))
                {
                    voice = existingCharactersVocals.get(char.id);
                } else if (soundsMap.exists(char.id)) {
                    voice = new FlxSound().loadEmbedded(soundsMap.get(char.id));

                    addVocal(voice);

                    existingCharactersVocals.set(char.id, voice);
                }

                if (voice != null)
                    char.vocals.push(voice);
            });

            for (voice in vocals)
                voice.play();

            Conductor.songPosition = -1;
        }

        scriptCallbackCall(POST, 'SongStart');
    }

    public function endSong()
    {
        if (scriptCallbackCall(ON, 'SongEnd'))
        {
            canPause = false;

            pauseMusic();

            exit();
        }

        scriptCallbackCall(POST, 'SongEnd');
    }

    public function exit()
    {
        if (scriptCallbackCall(ON, 'Exit'))
        {
			FlxTimer.globalManager.forEach((tmr) -> if (!tmr.finished) tmr.active = false);

			FlxTween.globalManager.forEach((twn) ->  if (!twn.finished) twn.active = false);

            if (songIndex + 1 < playlist.length)
                CoolUtil.switchState(new PlayState(type, playlist, difficulty, songIndex + 1), true, true);
            else
                CoolUtil.switchState(new CustomState(type == STORY ? CoolVars.data.storyMenuState : CoolVars.data.freeplayState));
        }

        scriptCallbackCall(POST, 'Exit');
    }

    // Config

    var camOther:FXCamera;

    function initCameras()
    {
        if (scriptCallbackCall(ON, 'CamerasInit'))
        {
            camGame = new FXCamera(STAGE.speed ?? 1);

            final camGame:FXCamera = cast camGame;

            camGame.zoomSpeed = 1;
            camGame.bopModulo = 4;
            camGame.targetZoom = STAGE.zoom;

            FlxG.cameras.reset(camGame);
                
            camHUD = new FXCamera();

            final camHUD:FXCamera = cast camHUD;

            camHUD.zoomSpeed = 1;
            camHUD.bopModulo = 4;
            camHUD.bopZoom = 2;
            
            FlxG.cameras.add(camHUD, false);
                
            camOther = new FXCamera();

            FlxG.cameras.add(camOther, false);
        }

        scriptCallbackCall(POST, 'CamerasInit');
    }

    var strumLines:FlxTypedGroup<StrumLine>;

    var strums:FlxTypedGroup<Strum>;
    
    var characters:FlxTypedGroup<Character>;

    var opponents:FlxTypedGroup<Character>;
    var players:FlxTypedGroup<Character>;
    var extras:FlxTypedGroup<Character>;

    var cameraCharacters:Array<Array<Character>> = [];

    function initStrumLines()
    {
        if (scriptCallbackCall(ON, 'StrumLinesInit'))
        {
            final notes:Array<Array<Dynamic>> = [];

            Conductor.bpm = CHART.bpm;

            if (spawnNotes)
            {
                for (section in CHART.sections)
                {
                    if (section.changeBPM)
                        Conductor.bpm = section.bpm;

                    for (note in section.notes)
                    {
                        notes[note[4][0]] ??= [];
                        notes[note[4][0]].push([
                            note[0],
                            note[1],
                            note[2],
                            note[3],
                            note[4][1],
                            Conductor.stepCrochet
                        ]);
                    }
                }

                Conductor.bpm = CHART.bpm;
            }

            Conductor.bpm = CHART.bpm;

            characters = new FlxTypedGroup<Character>();
            opponents = new FlxTypedGroup<Character>();
            players = new FlxTypedGroup<Character>();
            extras = new FlxTypedGroup<Character>();

            strumLines.cameras = [camHUD];

            strums = new FlxTypedGroup<Strum>();

            for (strlIndex => strl in CHART.strumLines)
            {
                final strlCharacters:Array<Character> = [];

                for (char in strl.characters)
                {
                    final character:Character = new Character(char, strl.type);

                    cameraCharacters[strlIndex] ??= [];

                    cameraCharacters[strlIndex].push(character);

                    strlCharacters.push(character);
                    
                    addCharacter(character);
                }

                final strumLine:StrumLine = new StrumLine(strl, notes[strlIndex] ?? [], CHART.speed, strlCharacters, stackNote);

                strumLine.onHitNote = hitNote;

                strumLine.onMissNote = missNote;

                strumLines.add(strumLine);

                for (strum in strumLine.strums)
                    strums.add(strum);
            }
        }

        scriptCallbackCall(POST, 'StrumLinesInit');
    }

    var lastStackedNote:Note = null;

    function stackNote(note:Note)
    {
        lastStackedNote = note;

        if (scriptCallbackCall(ON, 'StackNote', null, [note], []))
        {
            if (!totalNoteTypes.contains(note.noteType))
                totalNoteTypes.push(note.noteType);
        }

        scriptCallbackCall(POST, 'StackNote', null, [note], []);
    }

    var lastHitNote:Note = null;
    var lastHitNoteCharacter:Character = null;

    function hitNote(note:Note, rating:Rating, character:Character, removeNote:Bool):Dynamic
    {
        lastHitNote = note;
        lastHitNoteCharacter = character;

        final scriptResult:Bool = scriptCallbackCall(ON, 'NoteHit', null, [note, rating, character, removeNote], [rating, removeNote]);

        if (scriptResult)
        {
            if (character.type == 'player')
            {
                health = health + note.hitHealth;

                score += rating.toScore();

                if (note.type == 'note')
                {
                    accuracyMod += rating.toAccuracy();

                    totalPlayed++;

                    combo++;

                    displayCombo(rating);
                }
            }
        }

        scriptCallbackCall(POST, 'NoteHit', null, [note, rating, character, removeNote], [rating, removeNote]);

        return scriptResult ? null : CoolVars.Function_Stop;
    }

    var lastMissNote:Note = null;
    var lastMissNoteCharacter:Character = null;

    function missNote(note:Note, character:Character):Dynamic
    {
        lastMissNote = note;
        lastMissNoteCharacter = character;

        final scriptResult:Bool = scriptCallbackCall(ON, 'NoteMiss', null, [note, character], []);

        if (scriptResult)
        {
            if (character.type == 'player')
            {
                if (note.type == 'note')
                {
                    combo = 0;

                    health = health - note.missHealth;

                    misses++;

                    totalPlayed++;
                }
            }
        }

        scriptCallbackCall(POST, 'NoteMiss', null, [note, character], []);

        return scriptResult ? null : CoolVars.Function_Stop;
    }

    final eventsListStack:GenericStack<ALEEventList> = new GenericStack();

    function initEvents()
    {
        if (scriptCallbackCall(ON, 'EventsInit'))
        {
            final tempEvents:Array<Array<Dynamic>> = CHART.events.copy();

            for (i in 0...tempEvents.length)
            {
                final targetEvent:Array<Dynamic> = tempEvents[tempEvents.length - 1 - i];

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

        scriptCallbackCall(POST, 'EventsInit');
    }

    function stackEventList(eventList:ALEEventList)
    {
        eventsListStack.add(eventList);

        if (scriptCallbackCall(ON, 'EventListStack', [eventList]))
        {
            for (event in eventList.events)
                if (!totalEvents.contains(event.id))
                    totalEvents.push(event.id);
        }

        scriptCallbackCall(POST, 'EventListStack', [eventList]);
    }

    var stageObjects:StringMap<FlxSprite> = new StringMap<FlxSprite>();

    function initStage()
    {
        if (scriptCallbackCall(ON, 'StageInit'))
        {
            if (STAGE.objectsConfig != null)
                for (object in STAGE.objectsConfig.objects)
                    initStageObject(object, STAGE.objectsConfig);
        }
        
        scriptCallbackCall(POST, 'StageInit');
    }

    function initStageObject(object:ALEStageObject, config:ALEStageObjectsConfig)
    {
        if (scriptCallbackCall(ON, 'StageObjectInit', [object, config]))
        {
            final obj:FlxSprite =
                Type.createInstance(
                    Type.resolveClass(object.classPath ?? 'flixel.FlxSprite'),
                    object.classArguments ?? []
                );

            obj.loadGraphic(Paths.image('stages/' + config.directory + '/' + (object.path ?? object.id)));

            for (props in [config.properties, object.properties])
                if (props != null)
                    CoolUtil.setMultiProperty(obj, props);

            obj.exists = object.highQuality ?? false ? !ClientPrefs.data.lowQuality : true;

            var addMethod:FlxBasic->Dynamic = null;

            #if flixel
            addMethod = Reflect.getProperty(this, object.addMethod ?? 'addBehindExtras');
            #else
            addMethod = Reflect.getProperty(this, 'variables').get(object.addMethod ?? 'addBehindExtras');
            #end

            obj.updateHitbox();

            if (addMethod != null)
                Reflect.callMethod(this, addMethod, [obj]);

            stageObjects.set(object.id, obj);
        }

        scriptCallbackCall(POST, 'StageObjectInit', [object, config]);
    }

    function initControls()
    {
        if (scriptCallbackCall(ON, 'ControlsInit'))
        {
            FlxG.stage.addEventListener('keyDown', justPressedKey);
            FlxG.stage.addEventListener('keyUp', justReleasedKey);
        }

        scriptCallbackCall(POST, 'ControlsInit');
    }

    public var uiGroup:FlxTypedGroup<FlxBasic>;

    public var healthBar:Bar;

    public var icons:FlxTypedGroup<Icon>;
    
    public var playerIcon:Icon;
    public var opponentIcon:Icon;

    public var scoreText:FlxText;

    function initHud()
    {
        if (scriptCallbackCall(ON, 'HudInit'))
        {
            uiGroup.cameras = [camHUD];

            healthBar = new Bar('hud/' + STAGE.hud + '/bar', 0, FlxG.height * (ClientPrefs.data.downScroll ? 0.1 : 0.9), 50, true);
            healthBar.x = FlxG.width / 2 - healthBar.width / 2;
            uiGroup.add(healthBar);

            icons = new FlxTypedGroup<Icon>();

            playerIcon = new Icon('player');
            addIcon(playerIcon);

            opponentIcon = new Icon('opponent');
            addIcon(opponentIcon);

            if (dad != null)
            {
                healthBar.rightBar.color = CoolUtil.colorFromString(dad.data.barColor);
                opponentIcon.change(dad.data.icon);
            } else {
                healthBar.rightBar.color = FlxColor.BLACK;
                opponentIcon.visible = false;
            }

            if (boyfriend != null)
            {
                healthBar.leftBar.color = CoolUtil.colorFromString(boyfriend.data.barColor);
                playerIcon.change(boyfriend.data.icon);
            } else {
                healthBar.leftBar.color = FlxColor.BLACK;
                playerIcon.visible = false;
            }

            scoreText = new FlxText(0, healthBar.y + 40, FlxG.width, 'Score      Misses      Rating');
            scoreText.setFormat(Paths.font('vcr.ttf'), 17, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            scoreText.borderSize = 1.25;

            uiGroup.add(scoreText);
        }

        scriptCallbackCall(POST, 'HudInit');
    }

    public final soundsMap:StringMap<Sound> = new StringMap();

    function initSounds()
    {
        if (scriptCallbackCall(ON, 'SoundsInit'))
        {
            soundsMap.set('::MUSIC', Paths.inst('songs/' + song));

            final voices:Sound = Paths.voices('songs/' + song, '', false, false);

            if (voices != null)
                soundsMap.set('::VOICES', voices);

            final playerVoices:Sound = Paths.voices('songs/' + song, 'Player', false, false);

            if (playerVoices != null)
                soundsMap.set('::PLAYER', playerVoices);

            final opponentVoices:Sound = Paths.voices('songs/' + song, 'Opponent', false, false);

            if (opponentVoices != null)
                soundsMap.set('::OPPONENT', opponentVoices);

            final extraVoices:Sound = Paths.voices('songs/' + song, 'Extra', false, false);

            if (extraVoices != null)
                soundsMap.set('::EXTRA', extraVoices);

            characters.forEachAlive((char) -> {
                final voice:Sound = Paths.voices('songs/' + song, char.id, false, false);

                if (voice != null)
                    soundsMap.set(char.id, voice);
            });
        }

        scriptCallbackCall(POST, 'SoundsInit');
    }

    public var comboGroup:FlxTypedSpriteGroup<FlxSprite>;

    public var comboSprite:FlxSprite;

    public var comboNumbers:Array<FlxSprite> = [];

    function initCombo()
    {
        if (scriptCallbackCall(ON, 'ComboInit'))
        {
            for (obj in ['sick', 'good', 'bad', 'shit'].concat([for (i in 0...10) '$i']))
                Paths.image('hud/' + STAGE.hud + '/combo/' + obj);
            
            comboGroup.cameras = [camHUD];

            comboSprite = new FlxSprite();
            comboSprite.scale.x = comboSprite.scale.y = HUD.combo.scale;

            comboGroup.add(comboSprite);

            for (i in 0...3)
            {
                final number:FlxSprite = new FlxSprite();
                number.scale.x = number.scale.y = HUD.combo.numberScale;
                
                comboGroup.add(number);

                comboNumbers.push(number);
            }

            for (spr in comboGroup)
            {
                spr.alpha = 0;

                spr.antialiasing = HUD.antialiasing && ClientPrefs.data.antialiasing;
            }
        }

        scriptCallbackCall(POST, 'ComboInit');
    }

    // Utils

    inline function addBehindOpponents(obj:FlxBasic)
        addBehindGroup(opponents, obj);

    inline function addBehindPlayers(obj:FlxBasic)
        addBehindGroup(players, obj);

    inline function addBehindExtras(obj:FlxBasic)
        addBehindGroup(extras, obj);

    function addBehindGroup(group:FlxTypedGroup<Dynamic>, obj:FlxBasic)
        insert(members.indexOf(group.members[0]), obj);

    function addCharacter(character:Character)
    {
        if (scriptCallbackCall(ON, 'CharacterAdd', null, [character], []))
        {
            switch (character.type)
            {
                case 'opponent':
                    opponents.add(character);

                case 'player':
                    players.add(character);

                case 'extra':
                    extras.add(character);

                default:
            }
            
            resetCharacterPosition(character);

            characters.add(character);

            add(character);
        }

        scriptCallbackCall(POST, 'CharacterAdd', null, [character], []);
    }

    function resetCharacterPosition(character:Character)
    {
        if (scriptCallbackCall(ON, 'CharacterPositionReset', null, [character], []))
        {
            character.x = character.data.position.x;
            character.y = character.data.position.y;

            if (STAGE.characterOffset != null)
            {
                var offset:Point = null;

                if (STAGE.characterOffset.type != null)
                    offset = Reflect.getProperty(STAGE.characterOffset.type, cast character.type);

                if (STAGE.characterOffset.id != null)
                    offset = Reflect.getProperty(STAGE.characterOffset.id, character.id);

                if (offset != null)
                {
                    character.x += offset.x ?? 0;
                    character.y += offset.y ?? 0;
                }
            }
        }

        scriptCallbackCall(POST, 'CharacterPositionReset', null, [character], []);
    }

    function changeCharacter(char:Character, newChar:String)
    {
        if (scriptCallbackCall(ON, 'CharacterChange', null, [char, newChar], [newChar]))
        {
            char.change(newChar);

            if (char == boyfriend)
            {
                playerIcon.change(char.data.icon);

                healthBar.leftBar.color = CoolUtil.colorFromString(char.data.barColor);
            }

            if (char == dad)
            {
                opponentIcon.change(char.data.icon);

                healthBar.rightBar.color = CoolUtil.colorFromString(char.data.barColor);
            }

            resetCharacterPosition(char);
        }

        scriptCallbackCall(POST, 'CharacterChange', null, [char, newChar], [newChar]);
    }

    function moveCamera(character:Character)
    {
        if (scriptCallbackCall(ON, 'CameraMove', null, [character], []))
        {
            if (!shouldMoveCamera)
                return;

            if (character == null)
                return;

            final camGame:FXCamera = cast camGame;

            camGame.position.x = character.getMidpoint().x + character.data.cameraPosition.x * (character.type == 'player' ? -1 : 1);
            camGame.position.y = character.getMidpoint().y + character.data.cameraPosition.y;

            if (STAGE.cameraOffset != null)
            {
                var offset:Point = null;

                if (STAGE.cameraOffset.type != null)
                    offset = Reflect.getProperty(STAGE.cameraOffset.type, cast character.type);

                if (STAGE.cameraOffset.id != null)
                    offset = Reflect.getProperty(STAGE.cameraOffset.id, character.id);

                if (offset != null)
                {
                    camGame.position.x += offset.x ?? 0;
                    camGame.position.y += offset.y ?? 0;
                }
            }
        }

        scriptCallbackCall(POST, 'CameraMove', null, [character], []);
    }

    function addIcon(icon:Icon)
    {
        if (scriptCallbackCall(ON, 'IconAdd', null, [icon], []))
        {
            icon.bar = healthBar;

            icons.add(icon);

            uiGroup.add(icon);
        }

        scriptCallbackCall(POST, 'IconAdd', null, [icon], []);
    }

    function updateHealth()
    {
        if (scriptCallbackCall(ON, 'HealthUpdate'))
        {
            healthBar.percent = health * 50;

            if (health <= 0)
                gameOver();
        }

        scriptCallbackCall(POST, 'HealthUpdate');
    }

    function gameOver()
    {
        if (scriptCallbackCall(ON, 'GameOver'))
        {
            pauseMusic();

            CoolUtil.openSubState(new CustomSubState(CoolVars.data.gameOverScreen));
        }

        scriptCallbackCall(POST, 'GameOver');
    }

    function justPressedKey(event:KeyboardEvent)
    {
        if (scriptCallbackCall(ON, 'JustPressedKey', null, [event], [event.keyCode]))
        {
            if (FlxG.keys.firstJustPressed() <= -1)
                return;

            strumLines.forEachAlive(strl -> strl.justPressedKey(event.keyCode));
        }

        scriptCallbackCall(POST, 'JustPressedKey', null, [event], [event.keyCode]);
    }

    function justReleasedKey(event:KeyboardEvent)
    {
        if (scriptCallbackCall(ON, 'JustReleasedKey', null, [event], [event.keyCode]))
            strumLines.forEachAlive(strl -> strl.justReleasedKey(event.keyCode));

        scriptCallbackCall(POST, 'JustReleasedKey', null, [event], [event.keyCode]);
    }

    final vocals:Array<FlxSound> = [];

    function addVocal(vocal:FlxSound)
    {
        if (scriptCallbackCall(ON, 'VocalAdd', null, [vocal], []))
        {
            if (vocal == null)
                return;

            vocals.push(vocal);

            FlxG.sound.list.add(vocal);
        }
        
        scriptCallbackCall(POST, 'VocalAdd', null, [vocal], []);
    }

    function resyncVocals()
    {
        if (scriptCallbackCall(ON, 'VocalsResync'))
        {
            if (FlxG.sound.music != null)
                Conductor.songPosition = FlxG.sound.music.time;

            for (vocal in vocals)
                if (vocal != null)
                {
                    vocal.pause();

                    if (Conductor.songPosition <= vocal.length)
                        vocal.time = Conductor.songPosition;
                    
                    vocal.play();
                }
        }

        scriptCallbackCall(POST, 'VocalsResync');
    }

    function pauseMusic()
    {
        if (scriptCallbackCall(ON, 'MusicPause'))
        {
            FlxG.sound.music?.pause();

            for (sound in vocals)
                if (sound != null)
                    sound.pause();
        }

        scriptCallbackCall(POST, 'MusicPause');
    }

    function resumeMusic()
    {
        if (scriptCallbackCall(ON, 'MusicResume'))
        {
            FlxG.sound.music?.resume();

            for (sound in vocals)
                if (sound != null)
                    sound.resume();
        }

        scriptCallbackCall(POST, 'MusicResume');
    }

    function displayCombo(rating:Rating)
    {
        if (scriptCallbackCall(ON, 'ComboDisplay', [rating]))
        {
            final path:String = 'hud/' + STAGE.hud + '/combo';

            FlxTween.cancelTweensOf(comboSprite);

            comboSprite.loadGraphic(Paths.image(path + '/' + Std.string(rating)));
            comboSprite.alpha = HUD.combo.alpha;
            comboSprite.updateHitbox();
            comboSprite.x = comboGroup.x - comboSprite.width / 2;
            comboSprite.y = comboGroup.y - comboSprite.height / 2;

            FlxTween.tween(comboSprite, {x: comboSprite.x + FlxG.random.float(-HUD.combo.endPosition.x, HUD.combo.endPosition.x), y: comboSprite.y + HUD.combo.endPosition.y, alpha: 0}, HUD.combo.duration, {ease: CoolUtil.easeFromString(HUD.combo.ease)});

            final comboString:String = '${combo % 1000}'.lpad('0', 3);

            final numberOffset:Float = FlxG.random.float(-HUD.combo.numberEndPosition.x, HUD.combo.numberEndPosition.x);

            for (index => number in comboNumbers)
            {
                FlxTween.cancelTweensOf(number);

                number.loadGraphic(Paths.image(path + '/' + comboString.charAt(index)));
                number.updateHitbox();
                number.alpha = HUD.combo.numberAlpha;
                number.x = comboGroup.x + HUD.combo.numberPosition.x + HUD.combo.space * index - number.width / 2;
                number.y = comboGroup.y + HUD.combo.numberPosition.y - number.height / 2;

                FlxTween.tween(number, {x: number.x + numberOffset, y: number.y + HUD.combo.numberEndPosition.y, alpha: 0}, HUD.combo.numberDuration, {ease: CoolUtil.easeFromString(HUD.combo.numberEase)});
            }
        }

        scriptCallbackCall(POST, 'ComboDisplay', [rating]);
    }

    // Psych Engine Compat.

    var dad(get, never):Character;
    function get_dad():Character
        return opponents.members[0];

    var boyfriend(get, never):Character;
    function get_boyfriend():Character
        return players.members[0];

    var gf(get, never):Character;
    function get_gf():Character
        return extras.members[0];

    var iconP1(get, never):Icon;
    function get_iconP1():Icon
        return playerIcon;

    var iconP2(get, never):Icon;
    function get_iconP2():Icon
        return opponentIcon;

    var scoreTxt(get, never):FlxText;
    function get_scoreTxt():FlxText
        return scoreText;

    var strumLineNotes(get, never):FlxTypedGroup<Strum>;
    function get_strumLineNotes():FlxTypedGroup<Strum>
        return strums;

    inline function addBehindDad(obj:FlxBasic)
        addBehindOpponents(obj);

    inline function addBehindBF(obj:FlxBasic)
        addBehindPlayers(obj);

    inline function addBehindGF(obj:FlxBasic)
        addBehindExtras(obj);
}