package funkin.states;

import ale.ui.UIUtils;

class CustomState extends ScriptedState
{
    public final scriptName:String;

    var haxeArguments:Array<Dynamic>;

    public function new(scriptName:String, ?haxeArguments:Array<Dynamic>)
    {
        super();

        this.scriptName = scriptName;

        this.haxeArguments = haxeArguments;
    }

    override function create()
    {
        super.create();

        loadScript('scripts/states/' + scriptName, haxeArguments);
        
        loadScript('scripts/states/global', haxeArguments);
        
        scriptCallbackCall(ON, 'Create');
        
        scriptCallbackCall(POST, 'Create');
    }
    
    override public function update(elapsed:Float)
    {
        if (scriptCallbackCall(ON, 'Update', [elapsed]))
            super.update(elapsed);

        if (Controls.RESET && CoolVars.meta.developerMode && !UIUtils.usingInputs)
            reset();

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

    override public function openSubState(substate:flixel.FlxSubState):Void
    {
        if (scriptCallbackCall(ON, 'OpenSubState', null, [substate]))
            super.openSubState(substate);

        scriptCallbackCall(POST, 'OpenSubState', null, [substate]);
    }

    override public function closeSubState():Void
    {
        if (scriptCallbackCall(ON, 'CloseSubState'))
            super.closeSubState();

        scriptCallbackCall(POST, 'CloseSubState');
    }

    override public function reset()
    {
        allowMemoryCleaning = false;

        CoolUtil.switchState(new CustomState(scriptName, haxeArguments), true, true);

        debugTrace('Current State: ' + scriptName, RESET_STATE);
    }
}