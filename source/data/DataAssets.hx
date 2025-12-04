package data;

import openfl.utils.Assets;
import openfl.utils.AssetType;

class DataAssets
{
	/**
	 * Retrieves a list of data files from a data folder.
	 * @param path The name of the data folder to retrieve the assets from.
	 * @param suffix The suffix/file extension of the data (default: ".json").
	 * @return A list of data file IDs (without folder and extension).
	 */
	public static function listAssetsFromPath(path:String, suffix:String = ".json"):Array<String>
	{
		var dataFolder:String = Paths.data(path) + "/";

		// List all text assets
		var allTextAssets = Assets.list(AssetType.TEXT);

		// Filter to only those inside the folder + with correct suffix
		var filtered = allTextAssets.filter(function(s:String)
		{
			return s.startsWith(dataFolder) && s.endsWith(suffix);
		});

		// Convert full paths → entry ids (strip folder + extension)
		return filtered.map(function(dataPath:String)
		{
			var withoutSuffix = dataPath.substring(0, dataPath.length - suffix.length);
			var pathNoPrefix = withoutSuffix.substring(dataFolder.length);

			var split = pathNoPrefix.split("/");
			return split[split.length - 1];
		});
	}
}
