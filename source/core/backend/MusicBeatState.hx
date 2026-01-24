package core.backend;

import core.interfaces.IMusicState;
import core.interfaces.IMusicObject;

import flixel.FlxState;

class MusicBeatState extends ALEState implements IMusicState
{
    public var curStep(get, never):Int;
    function get_curStep():Int
        return Conductor.curStep;

    public var safeStep(get, never):Int;
    function get_safeStep():Int
        return Conductor.safeStep;
    
    public var curBeat(get, never):Int;
    function get_curBeat():Int
        return Conductor.curBeat;
    
    public var safeBeat(get, never):Int;
    function get_safeBeat():Int
        return Conductor.safeBeat;
    
    public var curSection(get, never):Int;
    function get_curSection():Int
        return Conductor.curSection;
    
    public var safeSection(get, never):Int;
    function get_safeSection():Int
        return Conductor.safeSection;

    public var shouldResetConductor:Bool = true;

    override function destroy()
    {
        removeConductorListeners();

        super.destroy();
        
        if (shouldResetConductor)
            Conductor.reset();
    }

    override function create()
    {
        addConductorListeners();

        super.create();
    }

    var addedConductorListeners:Bool = false;

    public function addConductorListeners()
    {
        if (addedConductorListeners)
            return;

        addedConductorListeners = true;

        removedConductorListeners = false;

        Conductor.stepHit.add(onStepHit);
        Conductor.safeStepHit.add(onSafeStepHit);

        Conductor.beatHit.add(onBeatHit);
        Conductor.safeBeatHit.add(onSafeBeatHit);

        Conductor.sectionHit.add(onSectionHit);
        Conductor.safeSectionHit.add(onSafeSectionHit);
    }

    var removedConductorListeners:Bool = false;

    public function removeConductorListeners()
    {
        if (removedConductorListeners)
            return;

        removedConductorListeners = true;

        addedConductorListeners = false;

        Conductor.stepHit.remove(onStepHit);
        Conductor.safeStepHit.remove(onSafeStepHit);

        Conductor.beatHit.remove(onBeatHit);
        Conductor.safeBeatHit.remove(onSafeBeatHit);

        Conductor.sectionHit.remove(onSectionHit);
        Conductor.safeSectionHit.remove(onSafeSectionHit);
    }

    function onStepHit(step:Int):Void
    {
        if (subState != null && !persistentUpdate && !FlxState.transitioning)
            return;

        stepHit(step);
    }

    function onSafeStepHit(step:Int):Void
    {
        if (subState != null && !persistentUpdate && !FlxState.transitioning)
            return;

        safeStepHit(step);
    }

    function onBeatHit(beat:Int):Void
    {
        if (subState != null && !persistentUpdate && !FlxState.transitioning)
            return;

        beatHit(beat);
    }

    function onSafeBeatHit(beat:Int):Void
    {
        if (subState != null && !persistentUpdate && !FlxState.transitioning)
            return;

        safeBeatHit(beat);
    }

    function onSectionHit(section:Int):Void
    {
        if (subState != null && !persistentUpdate && !FlxState.transitioning)
            return;

        sectionHit(section);
    }

    function onSafeSectionHit(section:Int):Void
    {
        if (subState != null && !persistentUpdate && !FlxState.transitioning)
            return;

        safeSectionHit(section);
    }
    
    function recursiveMusicHit(obj:Dynamic, handler:IMusicObject->Void)
    {
        if (obj is IMusicObject)
            handler(cast obj);
        else if (obj is FlxTypedGroup)
            cast(obj, FlxTypedGroup<Dynamic>).forEachAlive((subObj) -> {
                recursiveMusicHit(subObj, handler);
            });
    }

    public function stepHit(curStep:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> m.stepHit(curStep));
        });
    }

    public function safeStepHit(safeStep:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> m.safeStepHit(safeStep));
        });
    }

    public function beatHit(curBeat:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> m.beatHit(curBeat));
        });
    }

    public function safeBeatHit(safeBeat:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> m.safeBeatHit(safeBeat));
        });
    }

    public function sectionHit(curSection:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> m.sectionHit(curSection));
        });
    }

    public function safeSectionHit(safeSection:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> m.safeSectionHit(safeSection));
        });
    }
}