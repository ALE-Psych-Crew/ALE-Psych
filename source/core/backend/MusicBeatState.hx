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
        
        Conductor.stepHit.add(hitCallbackHandler(stepHit));
        Conductor.safeStepHit.add(hitCallbackHandler(safeStepHit));

        Conductor.beatHit.add(hitCallbackHandler(beatHit));
        Conductor.safeBeatHit.add(hitCallbackHandler(safeBeatHit));

        Conductor.sectionHit.add(hitCallbackHandler(sectionHit));
        Conductor.safeSectionHit.add(hitCallbackHandler(safeSectionHit));
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
        Conductor.stepHit.remove(hitCallbackHandler(stepHit));
        Conductor.safeStepHit.remove(hitCallbackHandler(safeStepHit));

        Conductor.beatHit.remove(hitCallbackHandler(beatHit));
        Conductor.safeBeatHit.remove(hitCallbackHandler(safeBeatHit));

        Conductor.sectionHit.remove(hitCallbackHandler(sectionHit));
        Conductor.safeSectionHit.remove(hitCallbackHandler(safeSectionHit));

        super.destroy();
    }

    function hitCallbackHandler(callback:Int -> Void):Int -> Void
    {
        return (value) -> {
            if (subState != null && !persistentUpdate)
                return;

            callback(value);
        }
    }

    function stepHit(curStep:Int) {}
    function safeStepHit(safeStep:Int) {}

    function beatHit(curBeat:Int) {}
    function safeBeatHit(safeBeat:Int) {}

    function sectionHit(curSection:Int) {}
    function safeSectionHit(safeSection:Int) {}
}