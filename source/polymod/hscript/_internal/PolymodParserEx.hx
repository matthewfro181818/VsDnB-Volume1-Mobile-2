package polymod.hscript._internal;

#if hscript
import hscript.Parser;

class PolymodParserEx extends Parser {

#override function parseModule(content:String, ?origin:String = "hscript", ?position = 0)
#else
	public override function parseModule(content:String, ?origin:String = "hscript");
	{

#super.parseModule(content, origin, position)
#else
		return super.parseModule(content, origin);
}
}
