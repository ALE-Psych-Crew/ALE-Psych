package core.audio;

import core.interfaces.IMusicObject;
import core.interfaces.IMusicState;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * This class helps connect Conductor to a FlxState with callbacks related to the game's music
 * 
 * It was created to avoid copying and pasting the same code between MusicBeatState and MusicBeatSubState
 */
class MusicStateEventsDispatcher implements IFlxDestroyable
{
    final parent:IMusicState;

    /**
     * This creates the event handler
     * 
     * @param parent State with callbacks
     */
    public function new(parent:IMusicState)
    {
        this.parent = parent;

        Conductor.stepHit?.add(onStepHit);
        Conductor.safeStepHit?.add(onSafeStepHit);

        Conductor.beatHit?.add(onBeatHit);
        Conductor.safeBeatHit?.add(onSafeBeatHit);

        Conductor.sectionHit?.add(onSectionHit);
        Conductor.safeSectionHit?.add(onSafeSectionHit);

        Conductor.musicPlay?.add(onMusicPlay);
        Conductor.musicPause?.add(onMusicPause);
        Conductor.musicResume?.add(onMusicResume);
        Conductor.musicStop?.add(onMusicStop);
        Conductor.musicComplete?.add(onMusicComplete);
        Conductor.musicResync?.add(onMusicResync);
    }

    public function destroy()
    {
        Conductor.stepHit?.remove(onStepHit);
        Conductor.safeStepHit?.remove(onSafeStepHit);

        Conductor.beatHit?.remove(onBeatHit);
        Conductor.safeBeatHit?.remove(onSafeBeatHit);

        Conductor.sectionHit?.remove(onSectionHit);
        Conductor.safeSectionHit?.remove(onSafeSectionHit);

        Conductor.musicPlay?.remove(onMusicPlay);
        Conductor.musicPause?.remove(onMusicPause);
        Conductor.musicResume?.remove(onMusicResume);
        Conductor.musicStop?.remove(onMusicStop);
        Conductor.musicComplete?.remove(onMusicComplete);
        Conductor.musicResync?.remove(onMusicResync);
    }

    function objectDispatch(callback:IMusicObject->Void):Void
    {
        function dispatch(obj:Dynamic):Void
        {
            if (obj is IMusicObject)
            {
                callback(cast obj);

                return;
            }

            if (obj is FlxTypedGroup)
            {
                cast(obj, FlxTypedGroup<Dynamic>).forEachAlive(dispatch);

                return;
            }
        }

        parent.forEachAlive(dispatch);
    }

    function onStepHit(step:Int):Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.stepHit != null) m.stepHit(step));

        parent.stepHit(step);
    }

    function onSafeStepHit(step:Int):Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.safeStepHit != null) m.safeStepHit(step));

        parent.safeStepHit(step);
    }

    function onBeatHit(beat:Int):Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.beatHit != null) m.beatHit(beat));

        parent.beatHit(beat);
    }

    function onSafeBeatHit(beat:Int):Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.safeBeatHit != null) m.safeBeatHit(beat));

        parent.safeBeatHit(beat);
    }

    function onSectionHit(section:Int):Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.sectionHit != null) m.sectionHit(section));

        parent.sectionHit(section);
    }

    function onSafeSectionHit(section:Int):Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.safeSectionHit != null) m.safeSectionHit(section));

        parent.safeSectionHit(section);
    }

    function onMusicPlay():Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.musicPlay != null) m.musicPlay());

        parent.musicPlay();
    }

    function onMusicPause():Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.musicPause != null) m.musicPause());

        parent.musicPause();
    }

    function onMusicResume():Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.musicResume != null) m.musicResume());

        parent.musicResume();
    }

    function onMusicStop():Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.musicStop != null) m.musicStop());

        parent.musicStop();
    }

    function onMusicComplete():Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.musicComplete != null) m.musicComplete());

        parent.musicComplete();
    }

    function onMusicResync():Void
    {
        if (!parent.updating)
            return;

        objectDispatch(m -> if (m.musicResync != null) m.musicResync());

        parent.musicResync();
    }
}