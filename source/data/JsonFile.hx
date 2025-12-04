package data;

/**
 * A type definition describing the contents
 * and name of a JSON-loaded asset.
 */
typedef JsonFile = {
	/**
	 * The raw JSON text contents.
	 */
	var contents:String;

	/**
	 * The path or filename of the JSON being parsed.
	 */
	var fileName:String;
}
