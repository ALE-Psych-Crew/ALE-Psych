package funkin.visuals.game;

import openfl.events.KeyboardEvent;

import haxe.ds.GenericStack;

import utils.Formatter;

import core.structures.JsonStrumLineConfig;
import core.structures.JsonStrumLine;

import core.enums.CharacterType;
import core.enums.Rating;

import funkin.visuals.shaders.RGBPalette;

class StrumLine extends FlxSpriteGroup
{
    public var config:JsonStrumLine;

    public var botplay:Bool;

    public var downScroll:Bool = ClientPrefs.data.downScroll;

    public var type:CharacterType;

    var inputMap:Map<Int, Array<Int>>;

    var notesShader:Array<RGBPalette> = [];

    public function new(id:String, type:CharacterType, strlIndex:Int, ?noteStackCallback:Note -> Bool, ?notes:Array<Array<Dynamic>>)
    {
        super();

        this.config = Formatter.getStrumLine(id);

        this.type = type;

        botplay = type != PLAYER || ClientPrefs.data.botplay;

        initStrums();
        initNotes(notes ?? [], strlIndex, noteStackCallback);
        initSplashes();
        initInputs();
    }

    public var strums:FlxTypedSpriteGroup<Strum>;

    function initStrums()
    {
        add(strums = new FlxTypedSpriteGroup<Strum>());

        for (index => data in config.config)
        {
            final strum:Strum = new Strum(config.strums, data);
            strum.x = config.spacing * index;
            strum.strumLine = this;
            strum.data = index;
            strums.add(strum);
        }
    }

    public var notes:FlxTypedSpriteGroup<Note>;

    public var notesStack:GenericStack<Note>;

    var paletteCache:Array<RGBPalette> = [];
    
    function initNotes(notesArray:Array<Array<Dynamic>>, strlIndex:Int, ?noteStackCallback:Note -> Bool)
    {
        add(notes = new FlxTypedSpriteGroup<Note>());
        
        final tempNotes:Array<Note> = [];

        for (index => noteData in notesArray)
        {
            final time:Float = noteData[0];
            final data:Int = noteData[1];
            final length:Float = noteData[2];
            final type:String = noteData[3];
            final character:Int = noteData[4];
            final crochet:Float = noteData[5];

            final strum:Strum = strums.members[data];

            paletteCache[data] ??= new RGBPalette();

            final palette:RGBPalette = paletteCache[data];

            final note:Note = new Note(config.notes, config.config[data], ARROW, palette);
            note.strum = strum;
            note.strumLine = this;
            note.time = time;
            note.data = data;
            note.length = length;
            note.noteType = type;
            note.character = [strlIndex, character];

            tempNotes.push(note);

            if (length > 0)
            {
                final floorLength:Int = Math.floor(length / crochet) + 1;

                var parent:Note = note;
                
                for (i in 0...floorLength)
                {
                    final sustain:Note = new Note(config.notes, config.config[data], i == floorLength - 1 ? END : SUSTAIN, palette);
                    sustain.sustainHeight = crochet * 0.465;
                    sustain.strumLine = this;
                    sustain.strum = strum;
                    sustain.time = time + i * crochet;
                    sustain.data = data;
                    sustain.noteType = type;
                    sustain.xOffset = strum.width / 2 - sustain.width / 2;
                    sustain.yOffset = strum.height / 2;
                    sustain.parent = parent;
                    sustain.alphaMultiplier = 0.5;
                    sustain.flipY = downScroll;
                    sustain.character = [strlIndex, character];

                    tempNotes.push(sustain);

                    parent = sustain;
                }
            }
        }

        tempNotes.sort(
            (a, b) -> {
                if (a.time == b.time)
                    return a.type == b.type ? 0 : b.type == ARROW ? 1 : -1;

                return a.time > b.time ? -1 : 1;
            }
        );

        notesStack = new GenericStack<Note>();
        
        for (note in tempNotes)
            if (noteStackCallback == null ? true : noteStackCallback(note))
                notesStack.add(note);
    }

    public var splashes:FlxTypedSpriteGroup<Splash>;

    function initSplashes()
    {
        add(splashes = new FlxTypedSpriteGroup<Splash>());

        for (index => data in config.config)
        {
            final splash:Splash = new Splash(config.splashes, data);
            splash.strumLine = this;
            splash.strum = strums.members[index];
            splash.data = index;
            splashes.add(splash);
        }
    }

    function initInputs()
    {
        inputMap = new Map();

        for (index => data in config.config)
        {
            for (key in CoolUtil.getControl(data.keyBind.group, data.keyBind.id))
            {
                var list = inputMap.get(key);

                if (list == null)
                {
                    list = [];

                    inputMap.set(key, list);
                }

                list.push(index);
            }
        }
    }

    public var noteSpawnCallback:Note -> Bool;

    public var spawnWindow:Float = 2000;
    public var despawnWindow:Float = 650;

    public var speed:Float = 1;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        while (!notesStack.isEmpty() && notesStack.first().time < Conductor.songPosition + spawnWindow / speed)
        {
            final note:Note = notesStack.pop();

            if (noteSpawnCallback == null ? true : noteSpawnCallback(note))
                addNote(note);
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

            if (botplay)
            {
                if (note.botplayMiss && note.timeDistance < -shitWindow && !note.miss && !note.hit && note.ignore)
                    missNote(note);
                
                if (!note.hit && note.timeDistance <= 0 && !note.ignore)
                    hitNote(note, note.type == 'arrow');
            } else {
                if (note.type != 'arrow' && !note.miss && !note.hit && note.timeDistance <= 0 && keyPressed[note.data] && note.parent.hit)
                    hitNote(note, false);

                if (note.timeDistance < -shitWindow && !note.miss && !note.hit && !note.ignore)
                    missNote(note);
            }
            
            if (note.exists)
            {
                if (note.speed != speed)
                    note.speed = speed;

                note.followStrum();

                if (note.timeDistance < -despawnWindow)
                    removeNote(note);
            }

            noteIndex++;
        }
    }
    
    public var sickWindow:Int = 45;
    public var goodWindow:Int = 90;
    public var badWindow:Int = 135;
    public var shitWindow:Int = 180;

    var keyPressed:Array<Bool> = [];

    public function justPressedKey(key:Int)
    {
        if (botplay)
            return;

        var strumIndices:Null<Array<Null<Int>>> = inputMap.get(key);

        if (strumIndices != null)
        {
            for (strumIndex in strumIndices)
            {
                keyPressed[strumIndex] = true;

                var noteToHit:Null<Note> = null;

                for (note in notes)
                {
                    if (note == null || note.type != 'arrow' || note.data != strumIndex || note.timeDistance < -shitWindow)
                        continue;

                    if (note.timeDistance > shitWindow)
                        break;

                    if (noteToHit == null || noteToHit.timeDistance > note.timeDistance)
                        noteToHit = note;
                }

                if (noteToHit != null)
                    hitNote(noteToHit);
                else
                    strums.members[strumIndex].playAnim(config.config[strumIndex].press);
            }
        }
    }

    public function justReleasedKey(key:Int)
    {
        if (botplay)
            return;

        var strumIndices:Null<Array<Null<Int>>> = inputMap.get(key);

        if (strumIndices != null)
        {
            for (strumIndex in strumIndices)
            {
                keyPressed[strumIndex] = false;

                strums.members[strumIndex].playAnim(config.config[strumIndex].idle);
            }
        }
    }

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

    public var noteHitCallback:Note -> String -> Bool -> Bool;
    
    public function hitNote(note:Note, ?remove:Bool = true)
    {
        final rating:Rating = judgeNote(note.timeDistance);

        if (noteHitCallback == null ? true : noteHitCallback(note, rating, remove))
        {
            note.hit = true;

            if (note.type == 'arrow' && rating == 'sick' && !botplay)
                splashes.members[note.data].splash();

            note.strum.playAnim(note.strum.strumLineConfig.hit);

            if (remove)
                removeNote(note);
        }
    }

    public var noteMissCallback:Note -> Bool;

    public function missNote(note:Note)
    {
        if (noteMissCallback == null ? true : noteMissCallback(note))
            note.miss = true;
    }

    public function addNote(note:Note)
    {
        notes.add(note);

        note?.strum?.children.push(note);
    }

    public function removeNote(note:Note)
    {
        note.kill();

        note?.strum?.children.remove(note);

        notes.remove(note, true);

        note.destroy();
    }

    override function destroy()
    {
        while (!notesStack.isEmpty())
            notesStack.pop().destroy();

        keyPressed = null;

        paletteCache = null;

        super.destroy();
    }
}