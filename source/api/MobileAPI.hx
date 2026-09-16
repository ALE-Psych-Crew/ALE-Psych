package api;

#if mobile
import extension.eightsines.EsOrientation;
#end

import core.enums.ScreenOrientation;

class MobileAPI
{
    public static var orientation(default, set):ScreenOrientation = LANDSCAPE;

    static function set_orientation(type:ScreenOrientation)
    {
        #if mobile
        EsOrientation.setScreenOrientation(type.toEsOrientation());
        #end

        return orientation = type;
    }
}