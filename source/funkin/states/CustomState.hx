package;

import ale.ui.UIUtils;

class CustomState extends ScriptState
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
        {
            super.update(elapsed);

            if (Controls.RESET && CoolVars.data.developerMode && !UIUtils.usingInputs)
                resetCustomState();
        }

        scriptCallbackCall(POST, 'Update', [elapsed]);
    }
}