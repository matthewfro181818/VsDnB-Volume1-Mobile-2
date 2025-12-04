package graphics.video;

import flixel.FlxG;
import hxvlc.flixel.FlxVideo;

/**
 * Handler for managing loading, and playing videos.
 */
class VideoManager
{
	/**
	 * Plays a video.
	 * @param videoPath The path of the video.
	 * @return The video being played.
	 */
	{
		var video = new FlxVideo();

		video.onEndReached.add(() ->
		{

			video.dispose();
			FlxG.removeChild(video);
		});
		video.load(videoPath);
		FlxG.addChildBelowMouse(video);
		video.play();

		return video;
	}
}
