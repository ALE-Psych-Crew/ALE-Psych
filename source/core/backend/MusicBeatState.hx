package core.backend;

class MusicBeatState extends ALEState
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

    override function create()
    {
        super.create();

        Conductor.stepHit.add(onStepHit);
        Conductor.safeStepHit.add(onSafeStepHit);

        Conductor.beatHit.add(onBeatHit);
        Conductor.safeBeatHit.add(onSafeBeatHit);

        Conductor.sectionHit.add(onSectionHit);
        Conductor.safeSectionHit.add(onSafeSectionHit);
    }

    public var shouldUpdateMusic:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (subState != null && !persistentUpdate)
            return;

        Conductor.update();
    }

    override function destroy()
    {
        Conductor.stepHit.remove(onStepHit);
        Conductor.safeStepHit.remove(onSafeStepHit);

        Conductor.beatHit.remove(onBeatHit);
        Conductor.safeBeatHit.remove(onSafeBeatHit);

        Conductor.sectionHit.remove(onSectionHit);
        Conductor.safeSectionHit.remove(onSafeSectionHit);

        super.destroy();
    }

    function onStepHit(step:Int):Void
    {
        if (subState != null && !persistentUpdate)
            return;

        stepHit(step);
    }

    function onSafeStepHit(step:Int):Void
    {
        if (subState != null && !persistentUpdate)
            return;

        safeStepHit(step);
    }

    function onBeatHit(beat:Int):Void
    {
        if (subState != null && !persistentUpdate)
            return;

        beatHit(beat);
    }

    function onSafeBeatHit(beat:Int):Void
    {
        if (subState != null && !persistentUpdate)
            return;

        safeBeatHit(beat);
    }

    function onSectionHit(section:Int):Void
    {
        if (subState != null && !persistentUpdate)
            return;

        sectionHit(section);
    }

    function onSafeSectionHit(section:Int):Void
    {
        if (subState != null && !persistentUpdate)
            return;

        safeSectionHit(section);
    }

    function stepHit(curStep:Int) {}
    function safeStepHit(safeStep:Int) {}

    function beatHit(curBeat:Int) {}
    function safeBeatHit(safeBeat:Int) {}

    function sectionHit(curSection:Int) {}
    function safeSectionHit(safeSection:Int) {}
}