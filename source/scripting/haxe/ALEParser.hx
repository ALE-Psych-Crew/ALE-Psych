package scripting.haxe;

import rulescript.parsers.HxParser;
using rulescript.Tools;

import hscript.Expr;

using StringTools;

class ALEParser extends HxParser
{
	public var scriptName:String = 'ALEScript.hx';
	
	override public function new(scriptName:String)
	{
		this.scriptName = scriptName.replace('.', '/') + '.hx';
		
		super();
	}

	override public function parse(code:String):Expr
	{
		parser.line = 1;
		return mode == DEFAULT ? parser.parseString(code, scriptName, 0) : Tools.moduleDeclsToExpr(parser.parseModule(code, scriptName, 0));
	}

	override public function parseModule(code:String):Array<ModuleDecl>
	{
		parser.line = 1;
		return parser.parseModule(code, scriptName, 0);
	}
}