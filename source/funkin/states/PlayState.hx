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
import core.structures.ALESong;
import core.structures.ALEHud;
import core.structures.Point;
import core.enums.SongType;
import core.enums.Rating;

import utils.ALEFormatter;

import haxe.ds.StringMap;
import haxe.ds.GenericStack;

import funkin.visuals.game.StrumLine;
import funkin.visuals.game.Character;
import funkin.visuals.game.Strum;
import funkin.visuals.game.Icon;
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
    }

    public var shouldMoveCamera:Bool = true;

    public var allowSongPositionUpdate:Bool = false;

    public var skipCountdown:Bool = false;

    public var spawnNotes:Bool = true;
    
    public var canPause:Bool = false;

    override function create()
    {
        instance = this;

        super.create();

        Conductor.calculateBPMChanges(CHART);

        initCamera();

        initStrumLines();

        botplay = ClientPrefs.data.botplay;

        initEvents();
        initStage();
        initControls();
        initHud();

        cacheSounds();
        cacheCombo();

        startCountdown();
    }

    override function update(elapsed:Float)
    {
        if ((FlxG.sound.music != null && FlxG.sound.music.playing) || allowSongPositionUpdate)
            Conductor.songPosition += elapsed * 1000;

        super.update(elapsed);
        
        while (!eventsListStack.isEmpty() && eventsListStack.first().time <= Conductor.songPosition)
            for (event in eventsListStack.pop().events)
                eventHit(event);

        scoreText.text = botplay ? 'BOTPLAY' : 'Score: ' + score + '    Misses: ' + misses + '    Accuracy: ' + CoolUtil.floorDecimal(accuracy, 2) + '%';

        if (Controls.PAUSE && canPause)
        {
            CoolUtil.openSubState(new CustomSubState(CoolVars.data.pauseSubState));
        }

        if (Controls.RESET)
        {
            shouldClearMemory = false;

            pauseMusic();
            
            CoolUtil.resetState();
        }
    }

    override function destroy()
    {
        FlxG.stage.removeEventListener('keyDown', justPressedKey);
        FlxG.stage.removeEventListener('keyUp', justReleasedKey);
        
        pauseMusic();

        super.destroy();

        destroyScripts();
        
        instance = null;
    }

    override function stepHit(curStep:Int)
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

    override function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

        for (camera in [camGame, camHUD])
            cast(camera, FXCamera).bop(curBeat);
    }

    override function sectionHit(curSection:Int)
    {
        super.sectionHit(curSection);

        final songSection:ALESongSection = CHART.sections[curSection];

        if (songSection == null)
            return;

        moveCamera(cameraCharacters[songSection.camera[0]][songSection.camera[1]]);
    }

    function eventHit(event:ALEEvent)
    {
    }

    public var countdownSprite:FlxSprite;

    function startCountdown()
    {
        if (skipCountdown)
        {
            startSong();
            
            return;
        }

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
            if (loop == 5)
            {
                remove(countdownSprite);
                
                allowSongPositionUpdate = false;

                startSong();

                return;
            }

            final graphic:FlxGraphic = graphics[loop - 1];

            FlxG.sound.play(sounds[loop - 1]);

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
                    char.beatHit(loop - 1);
                });
            }
        }, 5);
    }

    function startSong()
    {
        FlxG.sound.playMusic(soundsMap.get('::MUSIC'), 0.85, false);
        
        FlxG.sound.music.onComplete = finishSong.bind();

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

        Conductor.songPosition = 0;
        
        canPause = true;
    }

    public function finishSong()
    {
        canPause = false;

        pauseMusic();

        exit();
    }

    public function exit()
    {
        if (songIndex + 1 < playlist.length)
            CoolUtil.switchState(new PlayState(type, playlist, difficulty, songIndex + 1), true, true);
        else
            CoolUtil.switchState(new CustomState(type == STORY ? CoolVars.data.storyMenuState : CoolVars.data.freeplayState));
    }

    // Config

    var camOther:FXCamera;

    function initCamera()
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

    var strumLines:FlxTypedGroup<StrumLine>;

    var strums:FlxTypedGroup<Strum>;
    
    var characters:FlxTypedGroup<Character>;

    var opponents:FlxTypedGroup<Character>;
    var players:FlxTypedGroup<Character>;
    var extras:FlxTypedGroup<Character>;

    var cameraCharacters:Array<Array<Character>> = [];

    function initStrumLines()
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

        add(strumLines = new FlxTypedGroup<StrumLine>());

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

            final strumLine:StrumLine = new StrumLine(strl, notes[strlIndex] ?? [], CHART.speed, strlCharacters);

            strumLine.onHitNote = (note, rating, character, removeNote) ->
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

                return null;
            };

            strumLine.onMissNote = (note, character) ->
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

                return null;
            };

            strumLines.add(strumLine);

            for (strum in strumLine.strums)
                strums.add(strum);
        }
    }

    final eventsListStack:GenericStack<ALEEventList> = new GenericStack();

    function initEvents()
    {
        final tempEvents:Array<Array<Dynamic>> = CHART.events.copy();

        for (i in 0...tempEvents.length)
        {
            final targetEvent:Array<Dynamic> = tempEvents[tempEvents.length - 1 - i];

            eventsListStack.add({
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

    var stageObjects:StringMap<FlxSprite> = new StringMap<FlxSprite>();

    function initStage()
    {
        if (STAGE.objectsConfig != null)
        {
            final config = STAGE.objectsConfig;

            for (object in config.objects)
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

                if (addMethod != null)
                    Reflect.callMethod(this, addMethod, [obj]);

                stageObjects.set(object.id, obj);
            }
        }
    }

    function initControls()
    {
        FlxG.stage.addEventListener('keyDown', justPressedKey);
        FlxG.stage.addEventListener('keyUp', justReleasedKey);
    }

    public var uiGroup:FlxTypedGroup<FlxBasic>;

    public var healthBar:Bar;

    public var icons:FlxTypedGroup<Icon>;
    
    public var playerIcon:Icon;
    public var opponentIcon:Icon;

    public var scoreText:FlxText;

    function initHud()
    {
        add(uiGroup = new FlxTypedGroup<FlxBasic>());

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

    public final soundsMap:StringMap<Sound> = new StringMap();

    function cacheSounds()
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

    public var comboGroup:FlxTypedSpriteGroup<FlxSprite>;

    public var comboSprite:FlxSprite;

    public var comboNumbers:Array<FlxSprite> = [];

    function cacheCombo()
    {
        for (obj in ['sick', 'good', 'bad', 'sick'].concat([for (i in 0...10) '$i']))
            Paths.image('hud/' + STAGE.hud + '/combo/' + obj);
        
        add(comboGroup = new FlxTypedSpriteGroup<FlxSprite>(HUD.combo.position.x, HUD.combo.position.y));
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

    function resetCharacterPosition(character:Character)
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

    function changeCharacter(char:Character, newChar:String)
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

    function moveCamera(character:Character)
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

    function addIcon(icon:Icon)
    {
        icon.bar = healthBar;

        icons.add(icon);

        uiGroup.add(icon);
    }

    function updateHealth()
    {
        healthBar.percent = health * 50;

        if (health <= 0)
            death();
    }

    function death()
    {
        pauseMusic();

        CoolUtil.openSubState(new CustomSubState(CoolVars.data.gameOverScreen));
    }

    function justPressedKey(event:KeyboardEvent)
    {
        if (FlxG.keys.firstJustPressed() <= -1)
            return;

        strumLines.forEachAlive(strl -> strl.justPressedKey(event.keyCode));
    }

    function justReleasedKey(event:KeyboardEvent)
    {
        strumLines.forEachAlive(strl -> strl.justReleasedKey(event.keyCode));
    }

    final vocals:Array<FlxSound> = [];

    function addVocal(vocal:FlxSound)
    {
        if (vocal == null)
            return;

        vocals.push(vocal);

        FlxG.sound.list.add(vocal);
    }

    function resyncVocals()
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

    function pauseMusic()
    {
        FlxG.sound.music?.pause();

        for (sound in vocals)
            if (sound != null)
                sound.pause();
    }

    function resumeMusic()
    {
        FlxG.sound.music?.resume();

        for (sound in vocals)
            if (sound != null)
                sound.resume();
    }

    function displayCombo(rating:Rating)
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