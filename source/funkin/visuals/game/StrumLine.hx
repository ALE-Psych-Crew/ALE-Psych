package funkin.visuals.game;

import utils.ALEFormatter;

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

    public var botplay(default, set):Bool;
    function set_botplay(val:Bool):Bool
    {
        botplay = val;

        for (str in strums)
            str.returnToIdle = botplay;

        return botplay;
    }

    public var notesStack:GenericStack<Note> = new GenericStack<Note>();

    public final data:ALEStrumLine;

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

    public var characters:Array<Character>;

    public function new(chartData:ALESongStrumLine, arrayNotes:Array<Dynamic>, speed:Float, characters:Array<Character>, ?onStackNote:Note -> Dynamic, ?postStackNote:Note -> Void)
    {
        super();

        this.scrollSpeed = speed;

        this.characters = characters;

        data = ALEFormatter.getStrumLine(chartData.file);

        visible = chartData.visible;

        type = chartData.type;

        add(strums = new FlxTypedSpriteGroup<Strum>());
        
        add(notes = new FlxTypedSpriteGroup<Note>());

        add(splashes = new FlxTypedSpriteGroup<Splash>());

        var inputs = ClientPrefs.controls.notes;

        var inputsArray:Array<Array<FlxKey>> = [];

        var strumHeight:Float = 0;

        for (strumIndex => strumConfig in data.strums)
        {
            inputsArray.push(CoolUtil.getControl(strumConfig.keybind[0], strumConfig.keybind[1]));

            final strum:Strum = new Strum(strumConfig, strumIndex, data.strumFramerate, data.strumTextures, data.strumScale, data.space);
            strums.add(strum);

            final splash:Splash = new Splash(strumConfig, strum, data.splashScale, data.splashFramerate, data.splashTextures);
            splashes.add(splash);

            strumHeight = Math.max(strumHeight, strum.height);
        }

        for (arrayIndex => array in inputsArray)
            for (key in array)
                inputMap.set(key, arrayIndex);

        x = chartData.rightToLeft ? data.position.x : FlxG.width - data.position.x - (data.strums.length - 1) * data.space - strums.members[strums.members.length - 1].width;
        y = ClientPrefs.data.downScroll ? FlxG.height - data.position.y - strumHeight : data.position.y;

        var tempNotes:Array<Note> = [];

        for (chartNote in arrayNotes)
        {
            final time:Float = chartNote[0];
            final noteData:Int = chartNote[1];
            final length:Float = chartNote[2];
            final type:String = chartNote[3];
            final character:Int = chartNote[4];
            final crochet:Float = chartNote[5];

            final space:Float = data.space;
            final scale:Float = data.noteScale;
            final textures:Array<String> = data.noteTextures;

            final strum:Strum = strums.members[noteData];

            final strumConfig:ALEStrum = data.strums[noteData];

            final note:Note = new Note(strumConfig, time, noteData, length, type, 'note', space, scale, textures, getNoteShader(strumConfig.shader, noteData), character);

            var parent:Note = note;

            tempNotes.push(note);

            if (length > 0)
            {
                final floorLength:Int = Math.floor(length / crochet);

                for (i in 0...(floorLength + 1))
                {
                    final sustain:Note = new Note(strumConfig, time + i * crochet, noteData, crochet, type, i == floorLength ? 'end' : 'sustain', space, scale, textures, getNoteShader(strumConfig.shader, noteData), character, i == floorLength ? null : crochet * 0.455, i == floorLength ? null : speed);
                    sustain.offsetY = strum.height / 2;
                    sustain.offsetX = strum.width / 2 - sustain.width / 2;
                    sustain.parent = parent;
                    sustain.multAlpha = 0.5;
                    sustain.flipY = ClientPrefs.data.downScroll;

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

                notesStack.add(note);
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

        while (!notesStack.isEmpty() && notesStack.first().time <= Conductor.songPosition + spawnWindow)
        {
            final note:Note = notesStack.pop();

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
                if (!note.hit && note.timeDistance <= 0 && !note.ignore)
                    hitNote(note, note.type == 'note');

                if (note.botplayMiss && note.timeDistance < -shitWindow && !note.miss && !note.hit && note.ignore)
                    missNote(note);
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

                if (note.timeDistance < -shitWindow && !note.miss && !note.hit && !note.ignore)
                    missNote(note);
            }

            if (note.type == 'sustain')
                if (note.sustainSpeed != scrollSpeed)
                    note.sustainSpeed = scrollSpeed;

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

    public var onHitNote:Note -> Rating -> Character -> Bool -> Dynamic;
    public var postHitNote:Note -> Rating -> Character -> Bool -> Void;

    public function hitNote(note:Note, ?remove:Bool)
    {
        remove ??= true;

        final rating:Rating = judgeNote(note.timeDistance);

        final character:Character = this.characters[note.characterPosition];

        final callbackResult:Dynamic = onHitNote == null ? null : onHitNote(note, rating, character, remove);

        if (callbackResult != CoolVars.Function_Stop)
        {
            note.hit = true;

            character?.sing(note.type != 'note' && !character.data.sustainAnimation ? null : note.singAnimation);

            if (note.type == 'note' && rating == 'sick' && !botplay)
                splashes.members[note.data].splash();

            strums.members[note.data].playAnim('hit');

            if (remove)
                removeNote(note);
        }

        if (postHitNote != null)
            postHitNote(note, rating, character, remove);
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

    public var onMissNote:Note -> Character -> Dynamic;
    public var postMissNote:Note -> Character -> Void;

    public function missNote(note:Note)
    {
        final character:Character = this.characters[note.characterPosition];

        final callbackResult:Dynamic = onMissNote == null ? null : onMissNote(note, character);

        if (callbackResult != CoolVars.Function_Stop)
        {
            note.miss = true;

            character?.miss(note.type != 'note' && !character.data.sustainAnimation ? null : note.missAnimation);
        }

        if (postMissNote != null)
            postMissNote(note, character);
    }

    public var onRemoveNote:Note -> Character -> Dynamic;
    public var postRemoveNote:Note -> Character -> Void;

    public function removeNote(note:Note)
    {
        final character:Character = this.characters[note.characterPosition];

        final callbackResult:Dynamic = onRemoveNote == null ? null : onRemoveNote(note, character);

        if (callbackResult != CoolVars.Function_Stop)
        {
            note.kill();
            notes.remove(note, true);
            note.destroy();
        }

        if (postRemoveNote != null)
            postRemoveNote(note, character);
    }

    override function destroy()
    {
        while (!notesStack.isEmpty())
            notesStack.pop().destroy();

        notesToHit = null;
        keyPressed = null;
        keyJustReleased = null;
        keyJustPressed = null;

        super.destroy();
    }
}