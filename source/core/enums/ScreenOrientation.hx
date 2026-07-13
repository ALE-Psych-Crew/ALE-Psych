package core.enums;

#if mobile
import extension.eightsines.EsOrientation;
#end

enum abstract ScreenOrientation(String) from String to String
{
    var PORTRAIT = 'portrait';
    var LANDSCAPE = 'landscape';
    var UNSPECIFIED = 'unspecified';

    public function toEsOrientation():Int
    {
        #if mobile
        return switch (cast(this, ScreenOrientation))
        {
            case PORTRAIT:
                EsOrientation.ORIENTATION_PORTRAIT;
            case LANDSCAPE:
                EsOrientation.ORIENTATION_LANDSCAPE;
            case UNSPECIFIED:
                EsOrientation.ORIENTATION_UNSPECIFIED;
        }
        #else
        return -1;
        #end
    }
}