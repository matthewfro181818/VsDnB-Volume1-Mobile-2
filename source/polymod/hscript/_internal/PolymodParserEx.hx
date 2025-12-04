package polymod.hscript._internal;

#if hscript
import hscript.Parser;

class PolymodParserEx extends Parser {
##(hscript > "2.5.0" ? public : null)
#override function parseModule(content:String, ?origin:String = "hscript", ?position = 0)
#else
	public override function parseModule(content:String, ?origin:String = "hscript");
	#{
##(hscript > "2.5.0" ? return : null)
#super.parseModule(content, origin, position)
#else
		return super.parseModule(content, origin);
}
}
#