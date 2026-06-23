package funkin.substates;

import ale.ui.UIUtils;

class CustomSubState extends ScriptedSubState
{
    public final name:String;

    public function new(name:String, ?globalArgs:Array<Dynamic> #if ALLOW_HSCRIPT , ?haxeArgs:Array<Dynamic> #end #if ALLOW_LUA , ?luaArgs:Array<Dynamic> #end)
    {
        super(globalArgs, haxeArgs, luaArgs);

        this.name = name;
    }

    override public function create()
    {
        allowCamerasConfig = false;

        super.create();

        scriptsManager.load('scripts/substates/' + name);
        scriptsManager.load('scripts/substates/global');

        scriptsManager.loadFolder('scripts/substates/' + name);
        scriptsManager.loadFolder('scripts/global');

        openCallback = function() {
            scriptsManager.callback(ON, 'Open');

            scriptsManager.callback(POST, 'Open');
        };

        closeCallback = function() {
            scriptsManager.callback(ON, 'Close');

            scriptsManager.callback(POST, 'Close');
        };

        scriptsManager.callback(ON, 'Create');

        initCameras();

        scriptsManager.callback(POST, 'Create');
    }

    override function initCameras()
    {
        if (scriptsManager.callback(ON, 'CamerasInit'))
            super.initCameras();

        scriptsManager.callback(POST, 'CamerasInit');
    }

    override public function update(elapsed:Float)
    {
        if (scriptsManager.callback(ON, 'Update', [elapsed]))
            super.update(elapsed);

        if (Controls.BACK && CoolVars.meta.developerMode && !UIUtils.usingInputs)
            close();

        scriptsManager.callback(POST, 'Update', [elapsed]);
    }

    override public function destroy()
    {
        scriptsManager.callback(ON, 'Destroy');

        super.destroy();

        scriptsManager.callback(POST, 'Destroy');

        scriptsManager.destroy();
    }

    override public function draw()
    {
        if (scriptsManager.callback(ON, 'Draw'))
            super.draw();

        scriptsManager.callback(POST, 'Draw');
    }

    override public function stepHit(curStep:Int)
    {
        if (scriptsManager.callback(ON, 'StepHit', [curStep]))
            super.stepHit(curStep);

        scriptsManager.callback(POST, 'StepHit', [curStep]);
    }

    override public function beatHit(curBeat:Int)
    {
        if (scriptsManager.callback(ON, 'BeatHit', [curBeat]))
            super.beatHit(curBeat);

        scriptsManager.callback(POST, 'BeatHit', [curBeat]);
    }

    override public function sectionHit(curSection:Int)
    {
        if (scriptsManager.callback(ON, 'SectionHit', [curSection]))
            super.sectionHit(curSection);

        scriptsManager.callback(POST, 'SectionHit', [curSection]);
    }

    override public function safeStepHit(safeStep:Int)
    {
        if (scriptsManager.callback(ON, 'SafeStepHit', [safeStep]))
            super.safeStepHit(safeStep);

        scriptsManager.callback(POST, 'SafeStepHit', [safeStep]);
    }

    override public function safeBeatHit(safeBeat:Int)
    {
        if (scriptsManager.callback(ON, 'SafeBeatHit', [safeBeat]))
            super.safeBeatHit(safeBeat);

        scriptsManager.callback(POST, 'SafeBeatHit', [safeBeat]);
    }

    override public function safeSectionHit(safeSection:Int)
    {
        if (scriptsManager.callback(ON, 'SafeSectionHit', [safeSection]))
            super.safeSectionHit(safeSection);

        scriptsManager.callback(POST, 'SafeSectionHit', [safeSection]);
    }

    override public function musicPlay()
    {
        if (scriptsManager.callback(ON, 'MusicPlay'))
            super.musicPlay();

        scriptsManager.callback(POST, 'MusicPlay');
    }

    override public function musicPause()
    {
        if (scriptsManager.callback(ON, 'MusicPause'))
            super.musicPause();

        scriptsManager.callback(POST, 'MusicPause');
    }

    override public function musicResume()
    {
        if (scriptsManager.callback(ON, 'MusicResume'))
            super.musicResume();

        scriptsManager.callback(POST, 'MusicResume');
    }

    override public function musicStop()
    {
        if (scriptsManager.callback(ON, 'MusicStop'))
            super.musicStop();

        scriptsManager.callback(POST, 'MusicStop');
    }

    override public function musicComplete()
    {
        if (scriptsManager.callback(ON, 'MusicComplete'))
            super.musicComplete();

        scriptsManager.callback(POST, 'MusicComplete');
    }

    override public function musicResync()
    {
        if (scriptsManager.callback(ON, 'MusicResync'))
            super.musicResync();

        scriptsManager.callback(POST, 'MusicResync');
    }

    override public function onFocus()
    {
        if (scriptsManager.callback(ON, 'OnFocus'))
            super.onFocus();

        scriptsManager.callback(POST, 'OnFocus');
    }

    override public function onFocusLost()
    {
        if (scriptsManager.callback(ON, 'OnFocusLost'))
            super.onFocusLost();

        scriptsManager.callback(POST, 'OnFocusLost');
    }
}