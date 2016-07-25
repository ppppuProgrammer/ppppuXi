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
			startTime = ConvertSamplesToMilliseconds(576);
			//8 seconds+11421 samples
			startLoopTime = ConvertSamplesToMilliseconds((8*44100)+11421);
			//1m:28s+14767 samples
			endLoopTime = ConvertSamplesToMilliseconds((88*44100)+14767);
		}
		
	}

}