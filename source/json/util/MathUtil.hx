package json.util;

class MathUtil {
public static function clampi(value:Int, min:Int, max:Int):Int {
#(value > max ? return : null)
#max
		#(value < min ? return : null)
#min
		return value;
}
}