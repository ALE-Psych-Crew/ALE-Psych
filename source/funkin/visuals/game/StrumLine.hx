package funkin.visuals.game;

import utils.ALEFormatter;

import funkin.visuals.game.Strum;
import funkin.visuals.game.Splash;
import funkin.visuals.game.ALENote as Note;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSort;

import core.structures.ALEStrumLine;
import core.structures.ALESongStrumLine;

import core.enums.CharacterType;
import core.enums.Rating;

import openfl.events.KeyboardEvent;

class StrumLine extends FlxSpriteGroup
{
    public var strums:FlxTypedSpriteGroup<Strum>;
    public var notes:FlxTypedSpriteGroup<Note>;
    public var splashes:FlxTypedSpriteGroup<Splash>;

    public var botplay:Bool;

    public var unspawnNotes:Array<Note> = [];

    public final config:ALEStrumLine;

    public var inputsArray:Array<Array<FlxKey>>;

    public var scrollSpeed:Float = 1;

    public function new(chartData:ALESongStrumLine, arrayNotes:Array<Dynamic>, speed:Float)
    {
        super();

        this.scrollSpeed = speed;

        config = ALEFormatter.getStrumLine(chartData.file);

        visible = chartData.visible;

        botplay = chartData.type != 'player';

        add(strums = new FlxTypedSpriteGroup<Strum>());
        
        add(notes = new FlxTypedSpriteGroup<Note>());

        add(splashes = new FlxTypedSpriteGroup<Splash>());

        var inputs = ClientPrefs.controls.notes;

        inputsArray = [inputs.left, inputs.down, inputs.up, inputs.right];

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

        for (note in arrayNotes)
            unspawnNotes.push(new Note(config.strums[note[1]], note[0], note[1], note[2], note[3], 'note', config.space, config.noteScale, config.noteTextures));
        
        unspawnNotes.sort(
            function(a:Note, b:Note)
            {
                if (a.time == b.time)
                    return 0;

                return a.time > b.time ? -1 : 1;
            }
        );

		FlxG.stage.addEventListener('keyDown', this.keyPressed);
		FlxG.stage.addEventListener('keyUp', this.keyReleased);
    }

    public function keyPressed(_:KeyboardEvent)
    {
        if (botplay)
            return;

        for (i in 0...strums.members.length)
            if (FlxG.keys.anyJustPressed(inputsArray[i]))
                keyJustPressed[i] = true;
    }

    public function keyReleased(_:KeyboardEvent)
    {
        if (botplay)
            return;

        for (i in 0...strums.members.length)
            if (FlxG.keys.anyJustReleased(inputsArray[i]))
                keyJustReleased[i] = true;
    }

    override function destroy()
    {
		FlxG.stage.removeEventListener('keyDown', this.keyPressed);
		FlxG.stage.removeEventListener('keyUp', this.keyReleased);

        super.destroy();
    }

    public var spawnTime:Float = 2000;

    public var missTime:Float = 180;

    var keyJustPressed:Array<Bool> = [];
    var keyJustReleased:Array<Bool> = [];

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        final songPosition:Float = Conductor.songPosition;

        while (unspawnNotes.length > 0 && unspawnNotes[unspawnNotes.length - 1].time <= songPosition + spawnTime / scrollSpeed)
            notes.add(unspawnNotes.pop());

        notes.forEachAlive(
            (note) -> {
                final strum:Strum = strums.members[note.data];
                
                note.followStrum(strum, Conductor.stepCrochet, scrollSpeed);

                if (botplay)
                {
                    if (note.timeDistance <= 0)
                        hitNote(note);
                } else {
                    if (Math.abs(note.timeDistance) <= missTime)
                    {
                        if (keyJustPressed[note.data])
                        {
                            keyJustPressed[note.data] = false;
                            
                            hitNote(note);
                        }
                    } else if (note.timeDistance < 0) {
                        removeNote(note);
                    }
                }
            }
        );
        
        strums.forEachAlive(
            (strum) -> {
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
        );
    }

    public function hitNote(note:Note)
    {
        final rating:Rating = judgeNote(note.timeDistance);

        if (rating == 'sick' && !botplay)
            splashes.members[note.data].splash();

        strums.members[note.data].playAnim('hit');

        removeNote(note);
    }

    public function judgeNote(time:Float):Rating
    {
        time = Math.abs(time);

        if (time < 45)
            return 'sick';

        if (time < 90)
            return 'good';

        if (time < 135)
            return 'bad';

        return 'shit';
    }

    public function removeNote(note:Note)
    {
        note.kill();
        notes.remove(note, false);
        note.destroy();
    }
}
