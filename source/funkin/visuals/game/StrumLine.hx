package funkin.visuals.game;

import utils.ALEFormatter;

import funkin.visuals.game.Strum;
import funkin.visuals.game.Splash;
import funkin.visuals.game.NeoCharacter as Character;
import funkin.visuals.game.NeoNote as Note;

import flixel.input.keyboard.FlxKey;

import haxe.ds.GenericStack;
import haxe.ds.IntMap;

import funkin.visuals.shaders.RGBPalette;

import core.structures.ALEStrumLine;
import core.structures.ALESongStrumLine;
import core.structures.ALEStrum;

import core.enums.CharacterType;
import core.enums.Rating;

class StrumLine extends FlxSpriteGroup
{
    public var strums:FlxTypedSpriteGroup<Strum>;
    public var notes:FlxTypedSpriteGroup<Note>;
    public var splashes:FlxTypedSpriteGroup<Splash>;

    public var botplay:Bool;

    public var unspawnNotes:GenericStack<Note> = new GenericStack<Note>();

    public final config:ALEStrumLine;

    public var scrollSpeed:Float = 1;

    public var inputMap:IntMap<Int> = new IntMap();

    public final totalStrums:Int;

    public var notesShader:Array<RGBPalette> = [];

    function getNoteShader(shader:Null<Array<String>>, data:Int):RGBPalette
    {
        if (notesShader[data] == null)
        {
            final palette:RGBPalette = new RGBPalette();

            notesShader[data] = palette;

            if (shader != null)
            {
                palette.r = CoolUtil.colorFromString(shader[0]);
                palette.g = CoolUtil.colorFromString(shader[1]);
                palette.b = CoolUtil.colorFromString(shader[2]);
            }
        }

        return notesShader[data];
    }

    public final type:CharacterType;

    public function new(chartData:ALESongStrumLine, arrayNotes:Array<Dynamic>, speed:Float, characters:Array<Character>, ?onStackNote:Note -> Dynamic, ?postStackNote:Note -> Void)
    {
        super();

        this.scrollSpeed = speed;

        config = ALEFormatter.getStrumLine(chartData.file);

        visible = chartData.visible;

        type = chartData.type;

        botplay = type != 'player' || ClientPrefs.data.botplay;

        add(strums = new FlxTypedSpriteGroup<Strum>());
        
        add(notes = new FlxTypedSpriteGroup<Note>());

        add(splashes = new FlxTypedSpriteGroup<Splash>());

        var inputs = ClientPrefs.controls.notes;

        var inputsArray:Array<Array<FlxKey>> = [inputs.left, inputs.down, inputs.up, inputs.right];

        for (arrayIndex => array in inputsArray)
            for (key in array)
                inputMap.set(key, arrayIndex);

        var strumHeight:Float = 0;

        for (strumIndex => strumConfig in config.strums)
        {
            final strum:Strum = new Strum(strumConfig, strumIndex, config.strumFramerate, config.strumTextures, config.strumScale, config.space);
            strums.add(strum);
            strum.returnToIdle = botplay;

            final splash:Splash = new Splash(strumConfig, strum, config.splashScale, config.splashFramerate, config.splashTextures);
            splashes.add(splash);

            strumHeight = Math.max(strumHeight, strum.height);
        }

        x = chartData.rightToLeft ? config.position.x : FlxG.width - config.position.x - (config.strums.length - 1) * config.space - strums.members[strums.members.length - 1].width;
        y = ClientPrefs.data.downScroll ? FlxG.height - config.position.y - strumHeight : config.position.y;

        var tempNotes:Array<Note> = [];

        for (note in arrayNotes)
        {
            final time:Float = note[0];
            final data:Int = note[1];
            final length:Float = note[2];
            final character:Character = characters[note[4]];
            final type:String = note[3];
            final crochet:Float = note[5];

            final space:Float = config.space;
            final scale:Float = config.noteScale;
            final textures:Array<String> = config.noteTextures;

            final strum:Strum = strums.members[data];

            final strumConfig:ALEStrum = config.strums[data];

            final note:Note = new Note(strumConfig, time, data, length, type, 'note', space, scale, textures, getNoteShader(strumConfig.shader, data), character);

            var parent:Note = note;

            tempNotes.push(note);

            if (length > 0)
            {
                final floorLength:Int = Math.floor(length / crochet);

                for (i in 0...(floorLength + 1))
                {
                    final sustain:Note = new Note(strumConfig, time + i * crochet, data, crochet, type, i == floorLength ? 'end' : 'sustain', space, scale, textures, getNoteShader(strumConfig.shader, data), character);
                    sustain.offsetY = strum.height / 2;
                    sustain.offsetX = strum.width / 2 - sustain.width / 2;
                    sustain.parent = parent;
                    sustain.multAlpha = 0.5;
                    sustain.flipY = ClientPrefs.data.downScroll;

                    if (i != floorLength)
                        sustain.setGraphicSize(sustain.width, crochet * speed * 0.46);
                    
                    sustain.updateHitbox();

                    tempNotes.push(sustain);

                    parent = sustain;
                }
            }
        }
        
        tempNotes.sort(
            function(a:Note, b:Note)
            {
                if (a.time == b.time)
                    return a.type == b.type ? 0 : b.type == 'note' ? 1 : -1;

                return a.time > b.time ? -1 : 1;
            }
        );

        for (note in tempNotes)
        {
            final callbackResult:Dynamic = onStackNote == null ? null : onStackNote(note);
            
            if (callbackResult != CoolVars.Function_Stop)
            {
                note.update(0);
                note.draw();

                unspawnNotes.add(note);
            }

            if (postStackNote != null)
                postStackNote(note);
        }

        this.totalStrums = strums.members.length;

        for (i in 0...totalStrums)
        {
            notesToHit[i] = null;
            keyPressed[i] = false;
            keyJustPressed[i] = false;
            keyJustReleased[i] = false;
        }
    }

    var notesToHit:Array<Null<Note>> = [];
    var keyPressed:Array<Bool> = [];
    var keyJustPressed:Array<Bool> = [];
    var keyJustReleased:Array<Bool> = [];

    public function justPressedKey(key:Int)
    {
        if (botplay)
            return;

        var strumIndex:Null<Int> = inputMap.get(key);

        if (strumIndex != null)
        {
            keyPressed[strumIndex] = true;
            keyJustPressed[strumIndex] = true;
        }
    }

    public function justReleasedKey(key:Int)
    {
        if (botplay)
            return;

        var strumIndex:Null<Int> = inputMap.get(key);

        if (strumIndex != null)
        {
            keyPressed[strumIndex] = false;
            keyJustReleased[strumIndex] = true;
        }
    }

    public var spawnWindow:Float = 0;
    public var despawnWindow:Float = 650;

    var _lastScrollSpeed:Float = 0;

    public var onSpawnNote:Note -> Dynamic;
    public var postSpawnNote:Note -> Void;

    override public function update(elapsed:Float)
    {
        if (_lastScrollSpeed != scrollSpeed)
        {
            _lastScrollSpeed = scrollSpeed;

            spawnWindow = 2000 / scrollSpeed;
        }

        super.update(elapsed);

        while (!unspawnNotes.isEmpty() && unspawnNotes.first().time <= Conductor.songPosition + spawnWindow)
        {
            final note:Note = unspawnNotes.pop();

            final callbackResult:Dynamic = onSpawnNote == null ? null : onSpawnNote(note);

            if (callbackResult != CoolVars.Function_Stop)
            {
                notes.add(note);
            }

            if (postSpawnNote != null)
                postSpawnNote(note);
        }

        var noteIndex:Int = 0;
        
        while (noteIndex < notes.members.length)
        {
            final note:Note = notes.members[noteIndex];

            if (note == null || !note.exists || !note.alive)
            {
                noteIndex++;

                continue;
            }

            note.timeDistance = note.time - Conductor.songPosition;

            final strum:Strum = strums.members[note.data];

            if (botplay)
            {
                if (!note.hit && note.timeDistance <= 0)
                    hitNote(note, note.type == 'note');
            } else {
                if (note.type == 'note')
                {
                    if (Math.abs(note.timeDistance) <= shitWindow)
                        if (keyJustPressed[note.data])
                            if (notesToHit[note.data] == null || note.timeDistance < notesToHit[note.data].timeDistance)
                                notesToHit[note.data] = note;
                } else {
                    if (!note.hit && note.timeDistance <= 0 && keyPressed[note.data] && note.parent.hit)
                        hitNote(note, false);
                }

                if (note.timeDistance < -shitWindow && !note.miss && !note.hit)
                    missNote(note);
            }

            if (note.timeDistance < -despawnWindow)
                removeNote(note);

            noteIndex++;
        }

        for (data in 0...totalStrums)
        {
            if (!botplay && notesToHit[data] != null)
            {
                keyJustPressed[data] = false;

                hitNote(notesToHit[data]);

                notesToHit[data] = null;
            }
            
            final strum:Strum = strums.members[data];

            if (keyJustPressed[strum.data])
            {
                keyJustPressed[strum.data] = false;

                strum.playAnim('pressed');
            }

            if (keyJustReleased[strum.data])
            {
                keyJustReleased[strum.data] = false;

                strum.playAnim('idle');
            }
        }

        for (note in notes)
            note.followStrum(strums.members[note.data], Conductor.stepCrochet, scrollSpeed);
    }

    public var onHitNote:Note -> Rating -> Bool -> Dynamic;
    public var postHitNote:Note -> Bool -> Void;

    public function hitNote(note:Note, ?remove:Bool)
    {
        final rating:Rating = judgeNote(note.timeDistance);

        final callbackResult:Dynamic = onHitNote == null ? null : onHitNote(note, rating, remove);

        if (callbackResult != CoolVars.Function_Stop)
        {
            note.hit = true;

            note.character.sing(note.type != 'note' && !note.character.data.sustainAnimation ? null : note.singAnimation);

            if (note.type == 'note' && rating == 'sick' && !botplay)
                splashes.members[note.data].splash();

            strums.members[note.data].playAnim('hit');

            if (remove ?? true)
                removeNote(note);
        }

        if (postHitNote != null)
            postHitNote(note, remove ?? true);
    }

    public var sickWindow:Int = 45;
    public var goodWindow:Int = 90;
    public var badWindow:Int = 135;
    public var shitWindow:Int = 180;

    public function judgeNote(time:Float):Rating
    {
        time = Math.abs(time);

        if (time < sickWindow)
            return 'sick';

        if (time < goodWindow)
            return 'good';

        if (time < badWindow)
            return 'bad';

        return 'shit';
    }

    public var onMissNote:Note -> Dynamic;
    public var postMissNote:Note -> Void;

    public function missNote(note:Note)
    {
        final callbackResult:Dynamic = onMissNote == null ? null : onMissNote(note);

        if (callbackResult != CoolVars.Function_Stop)
        {
            note.miss = true;

            note.character.sing(note.type != 'note' && !note.character.data.sustainAnimation ? null : note.missAnimation);
        }

        if (postMissNote != null)
            postMissNote(note);
    }

    public var onRemoveNote:Note -> Dynamic;
    public var postRemoveNote:Note -> Void;

    public function removeNote(note:Note)
    {
        final callbackResult:Dynamic = onRemoveNote == null ? null : onRemoveNote(note);

        if (callbackResult != CoolVars.Function_Stop)
        {
            note.kill();
            notes.remove(note, true);
            note.destroy();
        }

        if (postRemoveNote != null)
            postRemoveNote(note);
    }

    override function destroy()
    {
        while (!unspawnNotes.isEmpty())
            unspawnNotes.pop().destroy();

        notesToHit = null;
        keyPressed = null;
        keyJustReleased = null;
        keyJustPressed = null;

        super.destroy();
    }
}