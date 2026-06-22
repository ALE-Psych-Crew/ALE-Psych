package funkin.states;

import core.structures.JsonHudRating;
import core.structures.ALESong;
import core.structures.JsonHud;
import core.structures.Point;

import core.enums.SongType;

import funkin.visuals.objects.Bar;
import funkin.visuals.FXCamera;
import funkin.visuals.game.*;

import utils.cool.ReflectUtil;
import utils.cool.StringUtil;
import utils.Formatter;

import flixel.util.typeLimit.OneOfTwo;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;

import openfl.media.Sound as OpenFLSound;
import openfl.events.KeyboardEvent;

import ale.ui.UIUtils;

class PlayState extends ScriptedState
{
    public var startTime:Float = 0;

    public var spawnNotes:Bool = true;
    public var skipCountdown:Bool = false;

    public var chart:ALESong;
    public var hud:JsonHud;

    public var hudRoute(get, never):String;
    public function get_hudRoute():String
        return 'huds/' + hud.directory;

    public final song:String;
    public final week:String;
    public final playlist:Array<String>;
    public final difficulty:String;
    public final songIndex:Int;
    public final songRoute:String;

    public final type:SongType;
    public var weekScore:Float = 0;

    public var score:Float = 0;
    public var totalNotes:Int = 0;
    public var accuracyMod:Float = 0;
    public var misses:Int = 0;
    public var combo:Int = 0;

    public var stage:Stage;

    public var accuracy(get, never):Float;
    public function get_accuracy():Float
        return totalNotes == 0 ? 100 : accuracyMod / totalNotes;

    public var botplay(default, set):Bool;
    public function set_botplay(value:Bool):Bool
    {
        botplay = value;

        for (strl in strumLines)
            strl.botplay = botplay || strl.type != PLAYER;

        return botplay;
    }

    public var health(default, set):Float = 50;
    function set_health(value:Float)
        return health = FlxMath.bound(value, 0, 100);

    public function new(?newType:SongType, ?newPlaylist:Array<String>, ?newDifficulty:String, ?newWeek:String, ?newWeekScore:Float, ?newSongIndex:Int)
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

    override function create()
    {
        super.create();

        Conductor.stop();
        Conductor.reset(chart.bpm, chart.stepsPerBeat, chart.beatsPerSection);

        scriptsManager.loadFolder('scripts/global');
        scriptsManager.loadFolder('scripts/songs');
        scriptsManager.loadFolder(songRoute + '/scripts');

        scriptsManager.load('scripts/stages/' + chart.stage);

        if (scriptsManager.callback(ON, 'Create'))
        {
            initCharacters();

            initCombo();
            
            initHud();

            initIcons();

            initStrumLines();

            botplay = ClientPrefs.data.botplay;

            initControls();

            initSounds();

            initSong();

            stage.change(chart.stage);

            moveCamera(0);

            camGame.snapToTarget();
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

            health = FlxMath.bound(health, 0, 100);

            if (_lastHealth != health)
            {
                _lastHealth = health;

                updateHealth();
            }

            if (Controls.PAUSE && allowPausing)
                pause();
        }

        scriptsManager.callback(POST, 'Update', [elapsed]);
    }

    override function initCameras()
    {
        if (scriptsManager.callback(ON, 'CamerasInit'))
        {
            camGame = new FXCamera();

            final camGame:FXCamera = cast camGame;
            
            camGame.speed = 1;
            camGame.zoomSpeed = 1;
            camGame.bopModulo = 4;
            camGame.zoom = camGame.targetZoom = stage.config.zoom;

            FlxG.cameras.reset(camGame);
            FlxG.cameras.setDefaultDrawTarget(camGame, true);
            
            camHUD = new FXCamera();

            FlxG.cameras.add(camHUD, false);
                
            camOther = new FXCamera();

            FlxG.cameras.add(camOther, false);
        }

        scriptsManager.callback(POST, 'CamerasInit');
    }

    function pause(?force:Bool = false)
    {
        if (scriptsManager.callback(ON, 'Pause'))
        {
            if (allowPausing || force)
            {
                FlxTimer.globalManager.forEach(tmr -> if (tmr != null && !tmr.finished) tmr.active = false);
                FlxTween.globalManager.forEach(twn ->  if (twn != null && !twn.finished) twn.active = false);

                CoolUtil.openSubState(new CustomSubState(CoolVars.meta.pauseSubState));
            }
        }

        scriptsManager.callback(POST, 'Pause');
    }

    function resume()
    {
        if (scriptsManager.callback(ON, 'Resume'))
        {
            FlxTimer.globalManager.forEach(tmr -> if (tmr != null && !tmr.finished) tmr.active = true);
            FlxTween.globalManager.forEach(twn ->  if (twn != null && !twn.finished) twn.active = true);
        }

        scriptsManager.callback(POST, 'Resume');
    }

    override function sectionHit(curSection:Int)
    {
        if (scriptsManager.callback(ON, 'SectionHit', [curSection]))
        {
            super.sectionHit(curSection);

            moveCamera(curSection);
        }

        scriptsManager.callback(POST, 'SectionHit', [curSection]);
    }

    override public function reset()
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
    }

    public var characters:FlxTypedGroup<Character>;

    public var charactersArray:Array<Array<Character>> = [];

    public var playerCharacters:FlxTypedGroup<Character>;
    public var opponentCharacters:FlxTypedGroup<Character>;
    public var extraCharacters:FlxTypedGroup<Character>;

    public var bf(get, never):Character;
    public function get_bf():Character
        return playerCharacters.members[0];

    public var dad(get, never):Character;
    public function get_dad():Character
        return opponentCharacters.members[0];

    public var gf(get, never):Character;
    public function get_gf():Character
        return extraCharacters.members[0];

    public function initCharacters()
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
                    final character:Character = new Character(char, strl.type);
                    
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

    public function changeCharacter(char:Character, id:String)
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

    public function getCharacterCamera(character:Character):Point
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

    public var comboGroup:FlxTypedSpriteGroup<FlxSprite>;

    public var ratingSprite:FunkinSprite;
    public var comboNumbers:FlxTypedSpriteGroup<FunkinSprite>;

    public function initCombo()
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

    public function displayCombo(rating:JsonHudRating)
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

    public var uiGroup:FlxGroup;

    public var healthBar:Bar;
    public var scoreText:FlxText;

    public function initHud()
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

    public function updateScoreText()
    {
        if (scriptsManager.callback(ON, 'ScoreTextUpdate'))
            scoreText.text = 'Score: ' + score + '    Misses: ' + misses + '    Accuracy: ' + CoolUtil.floorDecimal(get_accuracy(), 2) + '%';

        scriptsManager.callback(POST, 'ScoreTextUpdate');
    }

    public function updateHealth()
    {
        if (scriptsManager.callback(ON, 'HealthUpdate'))
            healthBar.percent = health;

        scriptsManager.callback(POST, 'HealthUpdate');
    }

    public var icons:FlxTypedGroup<Icon>;

    public var playerIcons:FlxTypedGroup<Icon>;
    public var opponentIcons:FlxTypedGroup<Icon>;
    public var extraIcons:FlxTypedGroup<Icon>;

    public var iconP1(get, never):Icon;
    public function get_iconP1():Icon
        return playerIcons.members[0];

    public var iconP2(get, never):Icon;
    public function get_iconP2():Icon
        return opponentIcons.members[0];

    public var iconP3(get, never):Icon;
    public function get_iconP3():Icon
        return extraIcons.members[0];

    public function initIcons()
    {
        if (scriptsManager.callback(ON, 'IconsInit'))
        {
            uiGroup.insert(uiGroup.members.indexOf(scoreText), icons = new FlxTypedGroup<Icon>());

            playerIcons = new FlxTypedGroup<Icon>();
            opponentIcons = new FlxTypedGroup<Icon>();
            extraIcons = new FlxTypedGroup<Icon>();

            for (char in [dad ?? gf ?? bf, bf ?? gf ?? dad])
            {
                final icon:Icon = new Icon(char._castConfig.icon, char.type);
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

    public var strumLines:FlxTypedGroup<StrumLine>;

    public var playerStrumLines:FlxTypedGroup<StrumLine>;
    public var opponentStrumLines:FlxTypedGroup<StrumLine>;
    public var extraStrumLines:FlxTypedGroup<StrumLine>;

    public var strums:FlxTypedGroup<Strum>;

    public var playerStrums:FlxTypedGroup<Strum>;
    public var opponentStrums:FlxTypedGroup<Strum>;
    public var extraStrums:FlxTypedGroup<Strum>;

    public function initStrumLines()
    {
        if (scriptsManager.callback(ON, 'StrumLinesInit'))
        {
            add(strumLines = new FlxTypedGroup<StrumLine>());
            strumLines.camera = camHUD;
            
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
                final strumLine:StrumLine = new StrumLine(strl.file, strl.type, index, notes[index], stackNote);
                strumLine.noteSpawnCallback = spawnNote;
                strumLine.noteHitCallback = hitNote;
                strumLine.noteMissCallback = missNote;
                strumLine.visible = strl.visible;
                strumLine.missWindow = hud.ratings[hud.ratings.length - 1].time;

                addStrumLine(strumLine);

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

    public function stackNote(note:Note):Bool
    {
        nextNoteToStack = note;

        final result:Bool = scriptsManager.callback(ON, 'NoteStack', null, [nextNoteToStack]);

        scriptsManager.callback(POST, 'NoteStack', null, [nextNoteToStack]);

        return result;
    }

    var nextNoteToSpawn:Note;

    public function spawnNote(note:Note):Bool
    {
        nextNoteToSpawn = note;

        final result:Bool = scriptsManager.callback(ON, 'NoteSpawn', null, [nextNoteToSpawn]);

        scriptsManager.callback(POST, 'NoteSpawn', null, [nextNoteToSpawn]);

        return result;
    }

    var nextNoteToHit:Note;
    var nextNoteToHitCharacter:Character;

    public function hitNote(note:Note, timeDistance:Float, removeNote:Bool):Bool
    {
        nextNoteToHit = note;
        nextNoteToHitCharacter = characterFromNote(nextNoteToHit);
        
        final rating:JsonHudRating = note.type == ARROW ? judgeNote(timeDistance) : null;

        final result:Bool = scriptsManager.callback(ON, 'NoteHit', null, [nextNoteToHit, nextNoteToHitCharacter, rating, timeDistance, removeNote], [rating, timeDistance, removeNote]);

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

        scriptsManager.callback(POST, 'NoteHit', null, [nextNoteToHit, nextNoteToHitCharacter, timeDistance, removeNote], [timeDistance, removeNote]);

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

    public function missNote(note:Note):Bool
    {
        nextNoteToMiss = note;
        nextNoteToMissCharacter = characterFromNote(nextNoteToMiss);

        final result:Bool = scriptsManager.callback(ON, 'NoteMiss', null, [nextNoteToMiss, nextNoteToMissCharacter]);

        if (result)
        {
            nextNoteToMissCharacter?.miss(note.type != ARROW && !nextNoteToMissCharacter._castConfig.sustainAnimation ? null : note.strumLineConfig.miss);

            if (nextNoteToMissCharacter.type == PLAYER)
            {
                health -= note.missHealth;

                combo = 0;
                
                if (note.type == ARROW)
                {
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

    public function characterFromNote(note:Note)
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

        public function initControls()
    {
        if (scriptsManager.callback(ON, 'ControlsInit'))
        {
            FlxG.stage.addEventListener('keyDown', justPressedKey);
            FlxG.stage.addEventListener('keyUp', justReleasedKey);
        }

        scriptsManager.callback(POST, 'ControlsInit');
    }

    public function justPressedKey(event:KeyboardEvent)
    {
        if (!updating)
            return;

        if (Controls.anyJustPressed([event.keyCode]))
        {
            if (scriptsManager.callback(ON, 'KeyJustPressed', null, [event], [event.keyCode]))
                strumLines.forEachAlive(strl -> strl.justPressedKey(event.keyCode));

            scriptsManager.callback(POST, 'KeyJustPressed', null, [event], [event.keyCode]);
        }
    }

    public function justReleasedKey(event:KeyboardEvent)
    {
        if (!updating)
            return;

        if (Controls.anyJustReleased([event.keyCode]))
        {
            if (scriptsManager.callback(ON, 'KeyJustReleased', null, [event], [event.keyCode]))
                strumLines.forEachAlive(strl -> strl.justReleasedKey(event.keyCode));

            scriptsManager.callback(POST, 'KeyJustReleased', null, [event], [event.keyCode]);
        }
    }

    public final soundsCache:Map<String, OpenFLSound> = new Map<String, OpenFLSound>();

    public function initSounds()
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

    public var vocals:Array<Sound> = [];

    public function addVocal(sound:Sound)
    {
        if (scriptsManager.callback(ON, 'VocalAdd', null, [sound], []))
        {
            if (sound != null)
            {
                vocals.push(sound);

                Conductor.synchronizedSounds.push(sound);

                FlxG.sound.list.add(sound);
            }
        }

        scriptsManager.callback(POST, 'VocalAdd', null, [sound], []);
    }


    public function initSong()
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

    public function startCountdown()
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

    public function tickCountdown(index:Int)
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

    public function startSong()
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

    public var camOther:FXCamera;

    public var allowCameraMoving:Bool = true;

    public var cameraTarget:Character;

    public function moveCamera(?char:OneOfTwo<Character, Int>, ?force:Bool = false)
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
}