package funkin.modchart;

import funkin.visuals.game.Strum;

class ModchartUtil
{
    public static var modifiers:Map<String, Strum -> ModchartModifier> = [];

    public static function init()
        modifiers ??= [];

    public static function destroy()
        modifiers?.clear();

    public static function registerModifier(id:String, factory:Strum -> ModchartModifier)
        modifiers[id] = factory;
}