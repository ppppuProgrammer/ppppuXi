package 
{
	import modifications.MusicMod;
	/**
	 * ...
	 * @author 
	 */
	public class M_BeepBlockSkyway extends MusicMod
	{
		
		public function M_BeepBlockSkyway() 
		{
			sourceSound = new BeepBlockSkyway;
			musicName = "Beep Block Skyway";
			//displayInfo = "Beep Block Skyway";
			//Start 5 frames ((frames / framerate) * samplerate) + mp3 encoded delay (576 samples) into the song.
			startTime = ConvertSamplesToMilliseconds(((7.0/30.0)*44100)+576);
			//8 seconds+11421 samples
			startLoopTime = ConvertSamplesToMilliseconds((8*44100)+11421);
			//1m:28s+14767 samples
			endLoopTime = ConvertSamplesToMilliseconds((88*44100)+14767);
		}
		
	}

}