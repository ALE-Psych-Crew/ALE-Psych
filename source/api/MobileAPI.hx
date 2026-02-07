package api;

#if mobile
import extension.eightsines.EsOrientation;
#end

import core.enums.ScreenOrientation;

class MobileAPI
{
    public static var orientation:ScreenOrientation = LANDSCAPE;

    public static function setOrientation(type:ScreenOrientation)
    {
        #if mobile
        EsOrientation.setScreenOrientation(type.toEsOrientation());
        #end

        orientation = type;
    }
}