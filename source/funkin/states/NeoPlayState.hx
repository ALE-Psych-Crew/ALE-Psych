package funkin.states;

import lime.app.Application;

import flixel.FlxBasic;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.FlxObject;

import utils.ALEFormatter;

import haxe.Timer;

import haxe.ds.StringMap;

import funkin.visuals.game.StrumLine;
import funkin.visuals.game.NeoCharacter as Character;

import funkin.visuals.objects.NeoBar as Bar;
import funkin.visuals.objects.Icon;

import core.structures.ALESong;
import core.structures.ALESongSection;
import core.structures.ALEStage;
import core.structures.Point;

import core.enums.Rating;

import openfl.events.KeyboardEvent;

class NeoPlayState extends ScriptState
{
    var SONG:ALESong;

    var STAGE:ALEStage;

    var instSound:openfl.media.Sound;

    function new(?song:String, ?difficulty:String)
    {
        SONG ??= ALEFormatter.getSong(song ?? 'bopeebo', difficulty ?? 'hard');

        STAGE ??= ALEFormatter.getStage(SONG.stage);

        instSound = Paths.voices('songs/' + (song ?? 'bopeebo'));
        
        super();
    }

    var characters:FlxTypedGroup<Character>;

    var opponents:FlxTypedGroup<Character>;
    var players:FlxTypedGroup<Character>;
    var extras:FlxTypedGroup<Character>;

    var dad(get, never):Character;
    function get_dad():Character
        return opponents.members[0];

    var boyfriend(get, never):Character;
    function get_boyfriend():Character
        return players.members[0];

    var gf(get, never):Character;
    function get_gf():Character
        return extras.members[0];

    var healthBar:Bar;

    var icons:FlxTypedGroup<Icon>;

    var playerIcon:Icon;
    var opponentIcon:Icon;

    var iconP1(get, never):Icon;
    function get_iconP1():Icon
        return playerIcon;

    var iconP2(get, never):Icon;
    function get_iconP2():Icon
        return opponentIcon;

    var scoreText:FlxText;

    var scoreTxt(get, never):FlxText;
    function get_scoreTxt():FlxText
        return scoreText;

    var botplay(default, set):Bool;
    function set_botplay(value:Bool):Bool
    {
        botplay = value;

        for (strl in strumLines)
            strl.botplay = strl.type != 'player' || botplay;

        return botplay;
    }

    override function create()
    {
        super.create();

        ClientPrefs.data.downScroll = false;
        ClientPrefs.data.botplay = false;

        initSong();

        initStage();

        initControls();

        initCamera();

        initHud();

        FlxG.sound.playMusic(instSound, 1, false);
    }

    function initHud()
    {
        healthBar = new Bar(0, FlxG.height * (ClientPrefs.data.downScroll ? 0.1 : 0.9), 50, true);
        healthBar.x = FlxG.width / 2 - healthBar.width / 2;
        healthBar.cameras = [camHUD];
        add(healthBar);

        icons = new FlxTypedGroup<Icon>();

        playerIcon = new Icon('player');
        playerIcon.cameras = [camHUD];
        playerIcon.offsetX = 20;
        addIcon(playerIcon);
        
        opponentIcon = new Icon('opponent');
        opponentIcon.cameras = [camHUD];
        opponentIcon.offsetX = 20;
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
        scoreText.cameras = [camHUD];
        add(scoreText);
    }

    function addIcon(icon:Icon)
    {
        icons.add(icon);

        add(icon);
    }

    var health(default, set):Float = 1;
    function set_health(value:Float):Float
    {
        health = FlxMath.bound(value, 0, 2);

        updateHealth();

        return health;
    }

    function updateHealth()
    {
        healthBar.percent = health * 50;

        final barMiddle:FlxPoint = healthBar.getMiddle();
        
        icons.forEachAlive(
            icon -> iconPosition(icon, barMiddle)
        );
        
        if (health <= 0)
        {
            FlxG.sound.music.pause();

            CoolUtil.openSubState(new CustomSubState(CoolVars.data.gameOverScreen));
        }
    }

    var strumLines:FlxTypedGroup<StrumLine>;

    var cameraCharacters:Array<Array<Character>> = [];

    var score:Float = 0;
    var totalPlayed:Int = 0;
    var accuracyMod:Float = 0;
    var misses:Int = 0;

    var accuracy(get, never):Float;
    function get_accuracy():Float
        return totalPlayed == 0 ? 0 : accuracyMod / totalPlayed;

    function initStrumLines()
    {
        final notes:Array<Array<Dynamic>> = [];

        Conductor.bpm = SONG.bpm;

        for (section in SONG.sections)
        {
            if (section.changeBPM)
                Conductor.bpm = section.bpm;

            for (note in section.notes)
            {
                notes[note[4][0]] ??= [];

                notes[note[4][0]].push(
                    [
                        note[0],
                        note[1],
                        note[2],
                        note[3],
                        note[4][1],
                        Conductor.stepCrochet
                    ]
                );
            }
        }

        Conductor.bpm = SONG.bpm;

        characters = new FlxTypedGroup<Character>();
        
        opponents = new FlxTypedGroup<Character>();
        players = new FlxTypedGroup<Character>();
        extras = new FlxTypedGroup<Character>();

        add(strumLines = new FlxTypedGroup<StrumLine>());
        strumLines.cameras = [camHUD];

        for (strlIndex => strl in SONG.strumLines)
        {
            final strlCharacters:Array<Character> = [];

            for (character in strl.characters)
            {
                final character:Character = new Character(character, strl.type);

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

                cameraCharacters[strlIndex] ??= [];

                cameraCharacters[strlIndex].push(character);

                strlCharacters.push(character);

                addCharacter(character);
            }

            final strumLine:StrumLine = new StrumLine(strl, notes[strlIndex] ?? [], SONG.speed, strlCharacters);

            strumLine.onHitNote = (note, rating, removeNote) -> {
                switch (note.character.type)
                {
                    case 'player':
                        health = health + note.hitHealth;

                        score += ratingToScore(rating);

                        if (note.type == 'note')
                        {
                            accuracyMod += ratingToAccuracy(rating);

                            totalPlayed++;
                        }
                    default:
                }

                return null;
            };

            strumLine.onMissNote = (note) -> {
                switch (note.character.type)
                {
                    case 'player':
                        health = health - note.missHealth;

                        misses++;

                        if (note.type == 'note')
                            totalPlayed++;
                    default:
                }

                return null;
            };

            strumLines.add(strumLine);
        }
    }

    function ratingToAccuracy(rating:Rating):Float
    {
        return switch (cast rating)
        {
            case 'sick':
                100;
            case 'good':
                67;
            case 'bad':
                33;
            default:
                0;
        };
    }

    function ratingToScore(rating:Rating):Float
    {
        return switch (cast rating)
        {
            case 'sick':
                350;
            case 'good':
                200;
            case 'bad':
                100;
            case 'shit':
                50;
            default:
                0;
        };
    }

    override function update(elapsed:Float)
    {
        Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        icons.forEachAlive(
            (icon) -> {
                iconScale(icon);
            }
        );

        scoreText.text = ClientPrefs.data.botplay ? 'BOTPLAY' : 'Score: ' + score + '    Misses: ' + misses + '    Accuracy: ' + CoolUtil.floorDecimal(accuracy, 2) + '%';
    }

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

        characters.add(character);

        add(character);
    }

    inline function addBehindOpponents(obj:FlxBasic)
        addBehindGroup(opponents, obj);

    inline function addBehindPlayers(obj:FlxBasic)
        addBehindGroup(players, obj);

    inline function addBehindExtras(obj:FlxBasic)
        addBehindGroup(extras, obj);

    inline function addBehindDad(obj:FlxBasic)
        addBehindGroup(opponents, obj);

    inline function addBehindBF(obj:FlxBasic)
        addBehindGroup(players, obj);

    inline function addBehindGF(obj:FlxBasic)
        addBehindGroup(extras, obj);

    var stageObjects:StringMap<FlxSprite> = new StringMap<FlxSprite>();

    function initStage()
    {
        if (STAGE.objectsConfig != null)
        {
            final config = STAGE.objectsConfig;

            for (object in config.objects)
            {
                final obj:FlxSprite = Type.createInstance(Type.resolveClass(object.classPath ?? 'flixel.FlxSprite'), object.classArguments ?? []);

                obj.loadGraphic(Paths.image('stages/' + config.directory + '/' + (object.path ?? object.id)));

                for (props in [config.properties, object.properties])
                    if (props != null)
                        CoolUtil.setMultiProperty(obj, props);

                var addMethod:FlxBasic -> Dynamic = null;

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

    function addBehindGroup(group:FlxTypedGroup<Dynamic>, obj:FlxBasic)
        insert(members.indexOf(group.members[0]), obj);

    function initControls()
    {
        FlxG.stage.addEventListener('keyDown', justPressedKey);
        FlxG.stage.addEventListener('keyUp', justReleasedKey);
    }

    function justPressedKey(event:KeyboardEvent)
    {
        if (FlxG.keys.firstJustPressed() <= -1)
            return;

        strumLines.forEachAlive(
            (strl) -> {
                strl.justPressedKey(event.keyCode);
            }
        );
    }

    function justReleasedKey(event:KeyboardEvent)
    {
        strumLines.forEachAlive(
            (strl) -> {
                strl.justReleasedKey(event.keyCode);
            }
        );
    }

    function initSong()
    {
        initStrumLines();

        Conductor.bpm = SONG.bpm;
    }

    var camFollow:FlxObject;

    function initCamera()
    {
        camFollow = new FlxObject(1, 1, 0, 0);

        camGame.follow(camFollow);

        camGame.followLerp = 2.5 * STAGE.speed ?? 1;

        camGame.zoom = STAGE.zoom;
    }

    override function sectionHit()
    {
        super.sectionHit();

        final songSection:ALESongSection = SONG.sections[curSection];

        if (songSection == null)
            return;

        final character:Character = cameraCharacters[songSection.camera[0]][songSection.camera[1]];

        camFollow.x = character.getMidpoint().x + character.data.cameraPosition.x * (character.type == 'player' ? -1 : 1);
        camFollow.y = character.getMidpoint().y + character.data.cameraPosition.y;

        if (STAGE.cameraOffset != null)
        {
            var offset:Point = null;

            if (STAGE.cameraOffset.type != null)
                offset = Reflect.getProperty(STAGE.cameraOffset.type, cast character.type);

            if (STAGE.cameraOffset.id != null)
                offset = Reflect.getProperty(STAGE.cameraOffset.id, character.id);

            if (offset != null)
            {
                camFollow.x += offset.x ?? 0;
                camFollow.y += offset.y ?? 0;
            }
        }
    }

    override function beatHit()
    {
        super.beatHit();

        characters.forEachAlive(
            (char) -> {
                char.dance();
            }
        );

        icons.forEachAlive(
            (icon) -> {
                bopIcon(icon);
            }
        );
    }

    function bopIcon(icon:Icon)
    {
        icon.scale.x = icon.scale.y = 1.2;
        icon.updateHitbox();

        final barMiddle:FlxPoint = healthBar.getMiddle();

        iconPosition(icon, barMiddle);
    }

    function iconScale(icon:Icon)
    {
        var mult:Float = CoolUtil.fpsLerp(icon.scale.x, 1, 0.3);

        icon.scale.x = icon.scale.y = mult;
        icon.updateHitbox();

        final barMiddle:FlxPoint = healthBar.getMiddle();

        icons.forEachAlive(
            (icon) -> {
                iconPosition(icon, barMiddle);
            }
        );
    }

    function iconPosition(icon:Icon, barMiddle:FlxPoint)
    {
        final isRight:Bool = icon.type == 'player' == healthBar.rightToLeft;

        icon.x = isRight ? (barMiddle.x - icon.offsetX) : (barMiddle.x - icon.width + icon.offsetX);
        icon.y = barMiddle.y - icon.height / 2 + icon.offsetY;

        if (icon.flipX != isRight)
            icon.flipX = isRight;
    }

    override function destroy()
    {
        super.destroy();

        FlxG.stage.removeEventListener('keyDown', justPressedKey);
        FlxG.stage.removeEventListener('keyUp', justReleasedKey);
    }
}