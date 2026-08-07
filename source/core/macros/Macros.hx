package core.macros;

class Macros
{
    public static function init()
    {
        FieldsMacro.init();
        ImportsMacro.init();
        TypedefsMacro.init();

        #if !ALE_HSCRIPT
        ExtensibleMacro.init();
        #end
    }
}