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
			if ("modData" in this)
			{
				modData.modMajorVersion = 1;
				modData.modMinorVersion = 0;
			}
			sourceSound = new BeepBlockSkyway;
			musicName = "Beep Block Skyway";
			//displayInfo = "Beep Block Skyway";
			//Start the typical mp3 encoded delay (576 samples) into the song.
			startTime = ConvertSamplesToMilliseconds(576);
			//8 seconds+11421 samples
			startLoopTime = ConvertSamplesToMilliseconds((8*44100)/*+11421*/);
			//1m:28s+14767 samples
			endLoopTime = -1;// ConvertSamplesToMilliseconds((88 * 44100) + 14767);
		}
		
	}

}