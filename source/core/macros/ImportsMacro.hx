package core.macros;

import haxe.macro.Context;
import haxe.macro.Compiler;

class ImportsMacro
{
	public static function include()
	{
        var packs:Array<String> = [
            #if COMPILE_ALL_CLASSES
            'sys',
            'sys.io',
            
            'openfl',
            'openfl.net',

            'flixel.util',
            'flixel.ui',
            'flixel.tweens',
            'flixel.tile',
            'flixel.text',
            'flixel.sound',
            'flixel.path',
            'flixel.math',
            'flixel.input',
            'flixel.group',
            'flixel.graphics',
            'flixel.effects',
            'flixel.effects.particles',
            'flixel.animation',

            'flixel.addons.api',
            'flixel.addons.display',
            'flixel.addons.display.shapes',
            'flixel.addons.effects',
            'flixel.addons.ui',
            'flixel.addons.plugin',
            'flixel.addons.text',
            'flixel.addons.tile',
            'flixel.addons.transition',
            'flixel.addons.util',
            'flixel.addons.editors.ogmo',

            'flixel.sound.filters',
            'flixel.sound.filters.effects',

            'flixel.away3d',

            'animate',

            'away3d.animators',
            'away3d.animators.data',
            'away3d.animators.nodes',
            'away3d.animators.states',
            'away3d.animators.transitions',
            'away3d.bounds',
            'away3d.cameras',
            'away3d.cameras.lenses',
            'away3d.containers',
            'away3d.controllers',
            'away3d.core.base',
            'away3d.core.partition',
            'away3d.core.pick',
            'away3d.core.render',
            'away3d.core.sort',
            'away3d.debug',
            'away3d.entities',
            'away3d.events',
            'away3d.library',
            'away3d.library.assets',
            'away3d.lights',
            'away3d.lights.shadowmaps',
            'away3d.loaders',
            'away3d.loaders.misc',
            'away3d.loaders.parsers',
            'away3d.materials',
            'away3d.materials.compilation',
            'away3d.materials.methods',
            'away3d.materials.passes',
            'away3d.primitives',
            'away3d.textures',
            'away3d.tools.helpers',

            'ale.ui',

            'haxe.crypto',
            'haxe.display',
            'haxe.exceptions',
            'haxe.extern',
            'haxe.ds',
            'haxe.sys',
            'haxe.sys.io',
            'haxe.runtime',
            #end

            'funkin.visuals.objects',
            'funkin.states',
            'funkin.substates',
            //'funkin.editors'
        ];

        for (pack in packs)
            Compiler.include(pack);
	}
}