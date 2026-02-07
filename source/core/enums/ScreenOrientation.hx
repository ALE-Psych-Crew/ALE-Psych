package core.enums;

import extension.eightsines.EsOrientation;

enum abstract ScreenOrientation(String) from String to String
{
    var PORTRAIT = 'portrait';
    var LANDSCAPE = 'landscape';
    var UNSPECIFIED = 'unspecified';

    public function toEsOrientation():Int
    {
        return switch (cast(this, ScreenOrientation))
        {
            case PORTRAIT:
                EsOrientation.ORIENTATION_PORTRAIT;
            case LANDSCAPE:
                EsOrientation.ORIENTATION_LANDSCAPE;
            case UNSPECIFIED:
                EsOrientation.ORIENTATION_UNSPECIFIED;
        }
    }
}