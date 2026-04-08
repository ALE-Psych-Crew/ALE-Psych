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
import flixel.input.keyboard.*;
import flixel.input.*;

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
import funkin.visuals.shaders.*;

import ale.ui.*;

import utils.*;

private typedef FlxDrawItem = flixel.graphics.tile.FlxDrawQuadsItem;

private typedef LimeAssetLibrary = lime.utils.AssetLibrary;

class Extensible {}

// Flixel

class ScriptedFlxBasic extends FlxBasic implements RuleScriptedClass {}
class ScriptedFlxObject extends FlxObject implements RuleScriptedClass {}
class ScriptedFlxGroup extends FlxGroup implements RuleScriptedClass {}
class ScriptedFlxSpriteGroup extends FlxSpriteGroup implements RuleScriptedClass {}

class ScriptedFlxTimer extends FlxTimer implements RuleScriptedClass {}
class ScriptedFlxSound extends FlxSound implements RuleScriptedClass {}
class ScriptedFlxRect extends FlxRect implements RuleScriptedClass {}

class ScriptedFlxButton extends FlxButton implements RuleScriptedClass {}
class ScriptedFlxBar extends FlxBar implements RuleScriptedClass {}
class ScriptedFlxGraphic extends FlxGraphic implements RuleScriptedClass {}

class ScriptedFlxSprite extends FlxSprite implements RuleScriptedClass {}
class ScriptedFlxAnimate extends FlxAnimate implements RuleScriptedClass {}
class ScriptedFlxBackdrop extends FlxBackdrop implements RuleScriptedClass {}
class ScriptedFlxRuntimeShader extends FlxRuntimeShader implements RuleScriptedClass {}

class ScriptedFlxText extends FlxText implements RuleScriptedClass {}
class ScriptedFlxBitmapText extends FlxBitmapText implements RuleScriptedClass {}
class ScriptedFlxTextFormat extends FlxTextFormat implements RuleScriptedClass {}

class ScriptedFlxCamera extends FlxCamera implements RuleScriptedClass {}

class ScriptedFlxKeyList extends FlxKeyList implements RuleScriptedClass {}
class ScriptedFlxBaseKeyList extends FlxBaseKeyList implements RuleScriptedClass {}

// OpenFL

@:forceOverride class ScriptedOpenFLSprite extends Sprite implements RuleScriptedClass {}

@:forceOverride class ScriptedOpenFLTextField extends TextField implements RuleScriptedClass {}

// ALE Psych

#if LUA_ALLOWED
class ScriptedLuaPresetBase extends LuaPresetBase implements RuleScriptedClass {}
#end

#if HSCRIPT_ALLOWED
class ScriptedHScriptPresetBase extends HScriptPresetBase implements RuleScriptedClass {}
#end

class ScriptedFunkinSprite extends FunkinSprite implements RuleScriptedClass {}
class ScriptedCharacter extends Character implements RuleScriptedClass {}
class ScriptedIcon extends Icon implements RuleScriptedClass {}

class ScriptedFXCamera extends FXCamera implements RuleScriptedClass {}
class ScriptedCamera extends Camera implements RuleScriptedClass {}

class ScriptedRuntimeShader extends RuntimeShader implements RuleScriptedClass {}
class ScriptedFXShader extends FXShader implements RuleScriptedClass {}

// ALE UI

class ScriptedMouseSprite extends MouseSprite implements RuleScriptedClass {}

class ScriptedUISprite extends UISprite implements RuleScriptedClass {}
