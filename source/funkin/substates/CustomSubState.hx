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

        if (FlxG.keys.justPressed.ESCAPE && CoolVars.data.developerMode && !UIUtils.usingInputs)
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