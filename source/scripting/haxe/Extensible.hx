package scripting.haxe;

import rulescript.scriptedClass.RuleScriptedClass;

import flixel.*;
import flixel.util.*;
import flixel.text.*;
import flixel.math.*;
import flixel.group.*;
import flixel.ui.*;
import flixel.graphics.*;
import flixel.addons.display.*;

import openfl.display.*;
import openfl.text.*;

import scripting.lua.*;

import funkin.visuals.*;
import funkin.visuals.objects.*;
import funkin.visuals.mobile.*;

private typedef FlxDrawItem = flixel.graphics.tile.FlxDrawQuadsItem;

class Extensible {}

// Flixel

class ScriptBasic extends FlxBasic implements RuleScriptedClass {}
class ScriptObject extends FlxObject implements RuleScriptedClass {}
class ScriptGroup extends FlxGroup implements RuleScriptedClass {}
class ScriptSpriteGroup extends FlxSpriteGroup implements RuleScriptedClass {}

class ScriptTimer extends FlxTimer implements RuleScriptedClass {}
class ScriptSound extends FlxSound implements RuleScriptedClass {}
class ScriptRect extends FlxRect implements RuleScriptedClass {}

class ScriptButton extends FlxButton implements RuleScriptedClass {}
class ScriptBar extends FlxBar implements RuleScriptedClass {}
class ScriptGraphic extends FlxGraphic implements RuleScriptedClass {}

class ScriptSprite extends FlxSprite implements RuleScriptedClass {}
class ScriptBackdrop extends FlxBackdrop implements RuleScriptedClass {}
class ScriptRuntimeShader extends FlxRuntimeShader implements RuleScriptedClass {}

class ScriptText extends FlxText implements RuleScriptedClass {}
class ScriptBitmapText extends FlxBitmapText implements RuleScriptedClass {}
class ScriptTextFormat extends FlxTextFormat implements RuleScriptedClass {}

class ScriptCamera extends FlxCamera implements RuleScriptedClass {}

// OpenFL

@:forceOverride class ScriptOpenFLSprite extends Sprite implements RuleScriptedClass {}

@:forceOverride class ScriptOpenFLTextField extends TextField implements RuleScriptedClass {}

// ALE Psych

#if LUA_ALLOWED
class ScriptLuaPresetBase extends LuaPresetBase implements RuleScriptedClass {}
#end