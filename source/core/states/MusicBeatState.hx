package core.states;

import core.audio.MusicStateEventsDispatcher;

import core.interfaces.IMusicState;

class MusicBeatState extends State implements IMusicState
{
    var musicEventsDispatcher:MusicStateEventsDispatcher;

    override function create()
    {
        musicEventsDispatcher = new MusicStateEventsDispatcher(this);

        super.create();
    }

    override function destroy()
    {
        super.destroy();
        
        musicEventsDispatcher.destroy();
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