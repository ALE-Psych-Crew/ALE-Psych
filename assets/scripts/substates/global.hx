//import ale.ui.ALEUIUtils;

function onUpdate(elapsed:Float)
{
    if (FlxG.keys.justPressed.ESCAPE && CoolVars.data.developerMode /*&& !ALEUIUtils.usingInputs*/)
        close();
}