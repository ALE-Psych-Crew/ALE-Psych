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

import animate.*;

import openfl.display.*;
import openfl.utils.*;
import openfl.text.*;

import scripting.haxe.*;
import scripting.lua.*;

import funkin.debug.*;
import funkin.visuals.*;
import funkin.visuals.game.*;
import funkin.visuals.objects.*;
import funkin.visuals.mobile.*;

import ale.ui.*;

import utils.*;

private typedef FlxDrawItem = flixel.graphics.tile.FlxDrawQuadsItem;

private typedef LimeAssetLibrary = lime.utils.AssetLibrary;

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
class ScriptAnimate extends FlxAnimate implements RuleScriptedClass {}
class ScriptBackdrop extends FlxBackdrop implements RuleScriptedClass {}
class ScriptRuntimeShader extends FlxRuntimeShader implements RuleScriptedClass {}

class ScriptText extends FlxText implements RuleScriptedClass {}
class ScriptBitmapText extends FlxBitmapText implements RuleScriptedClass {}
class ScriptTextFormat extends FlxTextFormat implements RuleScriptedClass {}

class ScriptCamera extends FlxCamera implements RuleScriptedClass {}

class ScriptALECamera extends ALECamera implements RuleScriptedClass {}

// OpenFL

@:forceOverride class ScriptOpenFLSprite extends Sprite implements RuleScriptedClass {}

@:forceOverride class ScriptOpenFLTextField extends TextField implements RuleScriptedClass {}

// ALE Psych

#if LUA_ALLOWED
class ScriptLuaPresetBase extends LuaPresetBase implements RuleScriptedClass {}
#end

#if HSCRIPT_ALLOWED
class ScriptHScriptPresetBase extends HScriptPresetBase implements RuleScriptedClass {}
#end

// @:forceOverride class ScriptDebugField extends DebugField implements RuleScriptedClass {}

class ScriptHealthIcon extends HealthIcon implements RuleScriptedClass {}
class ScriptCharacter extends Character implements RuleScriptedClass {}

// ALE UI

class ScriptALEMouseSprite extends ALEMouseSprite implements RuleScriptedClass {}

class ScriptALEUISprite extends ALEUISprite implements RuleScriptedClass {}