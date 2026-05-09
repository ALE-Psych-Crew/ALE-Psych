package core.states;

import core.interfaces.IMusicState;
import core.interfaces.IMusicObject;

class MusicBeatState extends State implements IMusicState
{
    override function create()
    {
        addConductorListeners();

        super.create();
    }

    override function destroy()
    {
        removeConductorListeners();

        super.destroy();
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
        if (!updating)
            return;

        stepHit(step);
    }

    function onSafeStepHit(step:Int):Void
    {
        if (!updating)
            return;

        safeStepHit(step);
    }

    function onBeatHit(beat:Int):Void
    {
        if (!updating)
            return;

        beatHit(beat);
    }

    function onSafeBeatHit(beat:Int):Void
    {
        if (!updating)
            return;

        safeBeatHit(beat);
    }

    function onSectionHit(section:Int):Void
    {
        if (!updating)
            return;

        sectionHit(section);
    }

    function onSafeSectionHit(section:Int):Void
    {
        if (!updating)
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
            recursiveMusicHit(obj, (m) -> if (m.stepHit != null) m.stepHit(curStep));
        });
    }

    public function safeStepHit(safeStep:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> if (m.safeStepHit != null) m.safeStepHit(safeStep));
        });
    }

    public function beatHit(curBeat:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> if (m.beatHit != null) m.beatHit(curBeat));
        });
    }

    public function safeBeatHit(safeBeat:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> if (m.safeBeatHit != null) m.safeBeatHit(safeBeat));
        });
    }

    public function sectionHit(curSection:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> if (m.sectionHit != null) m.sectionHit(curSection));
        });
    }

    public function safeSectionHit(safeSection:Int)
    {
        forEachAlive((obj) -> {
            recursiveMusicHit(obj, (m) -> if (m.safeSectionHit != null) m.safeSectionHit(safeSection));
        });
    }
}