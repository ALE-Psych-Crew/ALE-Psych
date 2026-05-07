package core.assets;

import openfl.utils.Assets;

class Paths
{
    public static var assets:Null<String> = null;
    public static var mods:Null<String> = null;

    public static var mod:Null<String> = null;

    public static var library(get, never):RootsLibrary;
    static function get_library():RootsLibrary
        return cast Assets.getLibrary('default');

    public static function init()
    {
        assets = 'assets';
        mods = 'mods';

        Assets.registerLibrary('default', new RootsLibrary([for (root in [mod == null || mods == null ? null : mods + '/' + mod, #if switch 'romfs:/' + #end assets, '']) if (root != null) root]));
    }
}