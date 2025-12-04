package polymod.hscript._internal;

#if hscriptPos
class ErrorEx {
/**
	 * The line number the error occurred on.
	 */
	public var line:Int;

	public var e:ErrorDefEx;
	public var pmin:Int;
	public var pmax:Int;
	public var origin:String;

	public function new(e, pmin, pmax, origin, line) {
this.e = e;
		this.pmin = pmin;
		this.pmax = pmax;
		this.origin = origin;
		this.line = line;
}

	public function toString():String {
return PolymodPrinterEx.errorExToString(this);
}
}

enum ErrorDefEx {
#else
enum ErrorEx {
// Original error types.
EInvalidChar(c:Int);
EUnexpected(s:String);
EUnterminatedString;
EUnterminatedComment;
EInvalidPreprocessor(msg:String);
EUnknownVariable(v:String);
EInvalidIterator(v:String);
EInvalidOp(op:String);
EInvalidAccess(f:String);
// Polymod-specific error types.
EInvalidModule(m:String);
EBlacklistedModule(m:String);
EInvalidScriptedFnAccess(f:String);
EInvalidScriptedVarGet(v:String);
EInvalidScriptedVarSet(v:String);
EClassSuperNotCalled;
EClassUnresolvedSuperclass(c:String, r:String); // superclass and reason
EScriptThrow(v:Dynamic); // Script called "throw"
EScriptCallThrow(v:Dynamic); // Script called a function which threw
// Fallback error type.
ECustom(msg:String);
} class ErrorExUtil {
public static function toErrorEx(err:hscript.Expr.Error):ErrorEx {
#if hscriptPos
		switch (err.e)
#else
		switch (err)
		{
case EInvalidChar(c):
#if hscriptPos
				return new ErrorEx(EInvalidChar(c), err.pmin, err.pmax, err.origin, err.line);
#else
				return EInvalidChar(c);
			case EUnexpected(s):
#if hscriptPos
				return new ErrorEx(EUnexpected(s), err.pmin, err.pmax, err.origin, err.line);
#else
				return EUnexpected(s);
			case EUnterminatedString:
#if hscriptPos
				return new ErrorEx(EUnterminatedString, err.pmin, err.pmax, err.origin, err.line);
#else
				return EUnterminatedString;
			case EUnterminatedComment:
#if hscriptPos
				return new ErrorEx(EUnterminatedComment, err.pmin, err.pmax, err.origin, err.line);
#else
				return EUnterminatedComment;
			case EInvalidPreprocessor(msg):
#if hscriptPos
				return new ErrorEx(EInvalidPreprocessor(msg), err.pmin, err.pmax, err.origin, err.line);
#else
				return EInvalidPreprocessor(msg);
			case EUnknownVariable(v):
#if hscriptPos
				return new ErrorEx(EUnknownVariable(v), err.pmin, err.pmax, err.origin, err.line);
#else
				return EUnknownVariable(v);
			case EInvalidIterator(v):
#if hscriptPos
				return new ErrorEx(EInvalidIterator(v), err.pmin, err.pmax, err.origin, err.line);
#else
				return EInvalidIterator(v);
			case EInvalidOp(op):
#if hscriptPos
				return new ErrorEx(EInvalidOp(op), err.pmin, err.pmax, err.origin, err.line);
#else
				return EInvalidOp(op);
			case EInvalidAccess(f):
#if hscriptPos
				return new ErrorEx(EInvalidAccess(f), err.pmin, err.pmax, err.origin, err.line);
#else
				return EInvalidAccess(f);
			case ECustom(msg):
#if hscriptPos
				return new ErrorEx(ECustom(msg), err.pmin, err.pmax, err.origin, err.line);
#else
				return ECustom(msg);
}
		throw "Unimplemented error type " + err;
}
}
}











