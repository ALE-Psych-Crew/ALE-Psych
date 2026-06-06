package core.substates;

import core.audio.MusicStateEventsDispatcher;

import core.interfaces.IMusicState;

class MusicBeatSubState extends SubState implements IMusicState
{
    var musicEventsDispatcher:MusicStateEventsDispatcher;

    public function new()
    {
        super();

        musicEventsDispatcher = new MusicStateEventsDispatcher(this);
    }

    override function destroy()
    {
        musicEventsDispatcher.destroy();

        super.destroy();
    }

    public function stepHit(curStep:Int) {}
    public function safeStepHit(safeStep:Int) {}

    public function beatHit(curBeat:Int) {}
    public function safeBeatHit(safeBeat:Int) {}

    public function sectionHit(curSection:Int) {}
    public function safeSectionHit(safeSection:Int) {}

    public function musicPlay() {}
    public function musicPause() {}
    public function musicResume() {}
    public function musicStop() {}
    public function musicComplete() {}
    public function musicResync() {}
}