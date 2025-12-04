package util;

/**
 * A utility for providing useful functions relating to Strings.
 */
class StringUtil
{
	/**
	 * Formats a string in spaced uppercase format.
	 * ex. `Formatted Song`
	 * @param string The string to format.
	 * @param separator The separator the string is using.
	 * @return A newly formatted string.
	 */
	public static function format(string:String, separator:String):String
	{
		var split = string.split(separator);
		var formattedString = "";

		for (i in 0...split.length)
		{
			var piece = split[i];
			if (piece.length == 0) continue;

			var first = piece.substr(0, 1).toUpperCase();
			var rest = piece.substr(1);
			var newPiece = first + rest;

			if (i != split.length - 1)
				newPiece += " ";

			formattedString += newPiece;
		}

		return formattedString;
	}

	/**
	 * Properly formats a list of strings to be used as one string.
	 * "A, B and C"
	 * "A and B"
	 * "A"
	 */
	public static function formatStringList(array:Array<String>):String
	{
		if (array == null || array.length == 0)
			return "";

		if (array.length == 1)
			return array[0];

		if (array.length == 2)
			return array[0] + " and " + array[1];

		// For 3+ items: "A, B, C and D"
		var full = "";

		for (i in 0...array.length)
		{
			full += array[i];

			var lastIndex = array.length - 1;

			if (i < lastIndex - 1)
			{
				// "A, B, C, "
				full += ", ";
			}
			else if (i == lastIndex - 1)
			{
				// second to last → "and"
				full += " and ";
			}
		}

		return full;
	}
}
