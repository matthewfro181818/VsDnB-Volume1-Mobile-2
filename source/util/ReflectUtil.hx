package util;

import Type;
import Type.ValueType;

/**
 * Provides sanitized and blacklisted access to haxe's Reflection functions.
 * Used for sandboxing in scripts.
 */
class ReflectUtil
{
	/**
	 * A list of field names which cannot be retrieved with `getAnonymousField()`
	 */
	static final FIELD_NAME_BLACKLIST:Array<String> = ['_interp'];

	// ----------------------------------------------------------
	// BLACKLISTED (Forbidden) REFLECTION FUNCTIONS
	// ----------------------------------------------------------

	public static function callMethod(obj:Any, name:String, args:Array<Any>):Any
	{
		throw "Function Reflect.callMethod is blacklisted.";
	}

	@SuppressWarnings("checkstyle:FieldDocComment")
	public static function createEmptyInstance(cls:Class<Any>):Any
	{
		throw "Function Type.createEmptyInstance is blacklisted.";
	}

	@SuppressWarnings("checkstyle:FieldDocComment")
	public static function createInstance(cls:Class<Any>, args:Array<Any>):Any
	{
		throw "Function Type.createInstance is blacklisted.";
	}

	@SuppressWarnings("checkstyle:FieldDocComment")
	public static function resolveClass(name:String):Class<Any>
	{
		throw "Function Type.resolveClass is blacklisted.";
	}

	@SuppressWarnings("checkstyle:FieldDocComment")
	public static function resolveEnum(name:String):Enum<Any>
	{
		throw "Function Type.resolveEnum is blacklisted.";
	}

	@SuppressWarnings("checkstyle:FieldDocComment")
	public static function typeof(value:Any):ValueType
	{
		throw "Function Type.typeof is blacklisted.";
	}

	// ----------------------------------------------------------
	// SAFE REFLECTION WRAPPERS
	// ----------------------------------------------------------

	public static function compare(valueA:Any, valueB:Any):Int
	{
		return compareValues(valueA, valueB);
	}

	public static function compareValues(valueA:Any, valueB:Any):Int
	{
		return Reflect.compare(valueA, valueB);
	}

	public static function compareMethods(functionA:Any, functionB:Any):Bool
	{
		return Reflect.compareMethods(functionA, functionB);
	}

	public static function copy(obj:Any):Null<Any>
	{
		return copyAnonymousFieldsOf(obj);
	}

	public static function copyAnonymousFieldsOf(obj:Any):Null<Any>
	{
		return Reflect.copy(obj);
	}

	public static function delete(obj:Any, name:String):Bool
	{
		return deleteAnonymousField(obj, name);
	}

	public static function deleteAnonymousField(obj:Any, name:String):Bool
	{
		return Reflect.deleteField(obj, name);
	}

	public static function field(obj:Any, name:String):Any
	{
		return getAnonymousField(obj, name);
	}

	public static function getField(obj:Any, name:String):Any
	{
		return getAnonymousField(obj, name);
	}

	public static function getAnonymousField(obj:Any, name:String):Any
	{
		if (FIELD_NAME_BLACKLIST.contains(name))
			throw 'Attempted to retrieve blacklisted field "${name}"';

		return Reflect.field(obj, name);
	}

	public static function fields(obj:Any):Array<String>
	{
		return getAnonymousFieldsOf(obj);
	}

	public static function getFieldsOf(obj:Any):Array<String>
	{
		return getAnonymousFieldsOf(obj);
	}

	public static function getAnonymousFieldsOf(obj:Any):Array<String>
	{
		return Reflect.fields(obj);
	}

	public static function getProperty(obj:Any, name:String):Any
	{
		if (FIELD_NAME_BLACKLIST.contains(name))
			throw 'Attempted to retrieve blacklisted field "${name}"';

		return Reflect.getProperty(obj, name);
	}

	public static function hasField(obj:Any, name:String):Bool
	{
		return hasAnonymousField(obj, name);
	}

	public static function hasAnonymousField(obj:Any, name:String):Bool
	{
		if (FIELD_NAME_BLACKLIST.contains(name))
			return false;

		return Reflect.hasField(obj, name);
	}

	public static function isEnumValue(value:Any):Bool
	{
		return Reflect.isEnumValue(value);
	}

	public static function isFunction(value:Any):Bool
	{
		return Reflect.isFunction(value);
	}

	public static function isObject(value:Any):Bool
	{
		return Reflect.isObject(value);
	}

	public static function setField(obj:Any, name:String, value:Any):Void
	{
		setAnonymousField(obj, name, value);
	}

	public static function setAnonymousField(obj:Any, name:String, value:Any):Void
	{
		Reflect.setField(obj, name, value);
	}

	public static function setProperty(obj:Any, name:String, value:Any):Void
	{
		Reflect.setProperty(obj, name, value);
	}

	// ----------------------------------------------------------
	// CLASS / INSTANCE FIELD UTILITIES
	// ----------------------------------------------------------

	public static function getClassFields(cls:Class<Any>):Array<String>
	{
		return Type.getClassFields(cls);
	}

	public static function getClassFieldsOf(obj:Any):Array<String>
	{
		if (obj == null) return [];
		var cls = Type.getClass(obj);
		if (cls == null) return [];
		return Type.getClassFields(cls);
	}

	public static function getInstanceFields(cls:Class<Any>):Array<String>
	{
		return Type.getInstanceFields(cls);
	}

	public static function getInstanceFieldsOf(obj:Any):Array<String>
	{
		if (obj == null) return [];
		var cls = Type.getClass(obj);
		if (cls == null) return [];
		return Type.getInstanceFields(cls);
	}

	public static function getClassName(cls:Class<Any>):String
	{
		return Type.getClassName(cls);
	}

	public static function getClassNameOf(obj:Any):String
	{
		if (obj == null) return "Unknown";
		var cls = Type.getClass(obj);
		if (cls == null) return "Unknown";
		return Type.getClassName(cls);
	}
}
