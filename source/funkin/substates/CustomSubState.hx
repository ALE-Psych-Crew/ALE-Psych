package funkin.substates;

import ale.ui.UIUtils;

class CustomSubState extends ScriptedSubState
{
    public var scriptName:String = '';

    var haxeArguments:Array<Dynamic>;

    override public function new(script:String, ?haxeArguments:Array<Dynamic>)
    {
        super();

        scriptName = script;

        this.haxeArguments = haxeArguments;
    }

    override public function create()
    {        
        super.create();

        loadScript('scripts/substates/' + scriptName, haxeArguments);
        
        loadScript('scripts/substates/global', haxeArguments);

        openCallback = function() {
            scriptCallbackCall(ON, 'Open');

            scriptCallbackCall(POST, 'Open');
        };

        closeCallback = function() {
            scriptCallbackCall(ON, 'Close');

            scriptCallbackCall(POST, 'Close');
        };

        scriptCallbackCall(ON, 'Create');

        scriptCallbackCall(POST, 'Create');
    }

    override public function update(elapsed:Float)
    {
        if (scriptCallbackCall(ON, 'Update', [elapsed]))
            super.update(elapsed);

        if (Controls.BACK && CoolVars.meta.developerMode && !UIUtils.usingInputs)
            close();

        scriptCallbackCall(POST, 'Update', [elapsed]);
    }

    override public function destroy()
    {
        scriptCallbackCall(ON, 'Destroy');

        super.destroy();

        scriptCallbackCall(POST, 'Destroy');

        destroyScripts();
    }

    override public function stepHit(curStep:Int)
    {
        if (scriptCallbackCall(ON, 'StepHit', [curStep]))
            super.stepHit(curStep);

        scriptCallbackCall(POST, 'StepHit', [curStep]);
    }

    override public function beatHit(curBeat:Int)
    {
        if (scriptCallbackCall(ON, 'BeatHit', [curBeat]))
            super.beatHit(curBeat);

        scriptCallbackCall(POST, 'BeatHit', [curBeat]);
    }

    override public function sectionHit(curSection:Int)
    {
        if (scriptCallbackCall(ON, 'SectionHit', [curSection]))
            super.sectionHit(curSection);

        scriptCallbackCall(POST, 'SectionHit', [curSection]);
    }

    override public function safeStepHit(safeStep:Int)
    {
        if (scriptCallbackCall(ON, 'SafeStepHit', [safeStep]))
            super.safeStepHit(safeStep);

        scriptCallbackCall(POST, 'SafeStepHit', [safeStep]);
    }

    override public function safeBeatHit(safeBeat:Int)
    {
        if (scriptCallbackCall(ON, 'SafeBeatHit', [safeBeat]))
            super.safeBeatHit(safeBeat);

        scriptCallbackCall(POST, 'SafeBeatHit', [safeBeat]);
    }

    override public function safeSectionHit(safeSection:Int)
    {
        if (scriptCallbackCall(ON, 'SafeSectionHit', [safeSection]))
            super.safeSectionHit(safeSection);

        scriptCallbackCall(POST, 'SafeSectionHit', [safeSection]);
    }

    override public function onFocus()
    {
        if (scriptCallbackCall(ON, 'OnFocus'))
            super.onFocus();

        scriptCallbackCall(POST, 'OnFocus');
    }

    override public function onFocusLost()
    {
        if (scriptCallbackCall(ON, 'OnFocusLost'))
            super.onFocusLost();

        scriptCallbackCall(POST, 'OnFocusLost');
    }
}