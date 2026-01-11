package funkin.visuals.game;

import utils.ALEFormatter;

import funkin.visuals.game.Strum;
import funkin.visuals.game.ALENote as Note;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSort;

import core.enums.CharacterType;
import core.enums.Rating;

import core.structures.ALEStrumLine;
import core.structures.ALESongStrumLine;

import core.enums.CharacterType;

class StrumLine extends FlxSpriteGroup
{
    public var strums:FlxTypedSpriteGroup<Strum>;
    public var notes:FlxTypedSpriteGroup<Note>;

    public var botplay:Bool;

    public var notesToSpawn:Array<Note> = [];

    public final config:ALEStrumLine;

    public var scrollSpeed:Float = 1;

    public function new(chartData:ALESongStrumLine, arrayNotes:Array<Dynamic>, speed:Float)
    {
        super();

        this.scrollSpeed = speed;

        config = ALEFormatter.getStrumLine(chartData.file);

        visible = chartData.visible;

        botplay = chartData.type != PLAYER;

        add(strums = new FlxTypedSpriteGroup<Strum>());

        var inputs = ClientPrefs.controls.notes;

        var inputsArray = [inputs.left, inputs.down, inputs.up, inputs.right];

        var strumHeight:Float = 0;

        for (strumIndex => strumConfig in config.strums)
        {
            final strum:Strum = new Strum(strumConfig, strumIndex, inputsArray[strumIndex], config.textures, config.scale, config.space);
            strums.add(strum);
            strum.returnToIdle = botplay;

            strumHeight = Math.max(strumHeight, strum.height);
        }

        x = chartData.rightToLeft ? config.position.x : FlxG.width - config.position.x - (config.strums.length - 1) * config.space - strums.members[strums.members.length - 1].width;
        y = ClientPrefs.data.downScroll ? FlxG.height - config.position.y - strumHeight : config.position.y;
        
        add(notes = new FlxTypedSpriteGroup<Note>());

        for (note in arrayNotes)
            notesToSpawn.push(new Note(config.strums[note[1]], strums.members[note[1]], note[0], note[1], note[2], note[3], NOTE, config.space, config.scale, config.textures));
        
        notesToSpawn.sort(
            function(a:Note, b:Note)
            {
                if (a.time == b.time)
                    return 0;

                return a.time > b.time ? -1 : 1;
            }
        );
    }

    public var spawnTime:Float = 5000;

    public var missTime:Float = 175;

    public final speedMult:Float = ClientPrefs.data.downScroll ? -0.45 : 0.45;

    var hitData:Array<Bool> = [];

    var keyPressed:Array<Bool> = [];

    var hitNotes:Array<Note> = [];
    var deleteNotes:Array<Note> = [];

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        final songPosition:Float = Conductor.songPosition;

        while (notesToSpawn.length > 0 && notesToSpawn[notesToSpawn.length - 1].time <= songPosition + Math.max(spawnTime / scrollSpeed, spawnTime))
            notes.add(notesToSpawn.pop());

        hitData.resize(0);

        if (!botplay)
            for (index => strum in strums.members)
                keyPressed[index] = FlxG.keys.anyJustPressed(strum.input);

        hitNotes.resize(0);

        deleteNotes.resize(0);

        for (note in notes)
        {
            if (note == null)
                continue;

            final timeDiff:Float = note.time - songPosition;

            note.y = this.y + timeDiff * speedMult * scrollSpeed;

            if (hitData[note.data])
                continue;

            if (botplay)
            {
                if (timeDiff <= 0)
                    hitNotes.push(note);
            } else {
                if (Math.abs(timeDiff) <= 180)
                {
                    if (keyPressed[note.data])
                    {
                        hitNotes.push(note);

                        hitData[note.data] = true;
                    }
                } else if (timeDiff < 0) {
                    deleteNotes.push(note);
                }
            }
        }

        for (note in hitNotes)
            hitNote(note);

        for (note in deleteNotes)
            removeNote(note);

        if (botplay)
            return;

        for (index => strum in strums.members)
        {
            if (!hitData[index] && keyPressed[index])
                strum.playAnim('pressed');

            if (FlxG.keys.anyJustReleased(strum.input))
                strum.playAnim('idle');
        }
    }

    public function hitNote(note:Note)
    {
        final rating:Rating = judgeNote(Math.abs(note.time - Conductor.songPosition));

        note.strum.playAnim('hit');

        removeNote(note);
    }

    public function judgeNote(time:Float):Rating
    {
        if (time < 45)
            return SICK;

        if (time < 90)
            return GOOD;

        if (time < 135)
            return BAD;

        return SHIT;
    }

    public function removeNote(note:Note)
    {
        note.kill();
        notes.remove(note, true);
        note.destroy();
    }
}