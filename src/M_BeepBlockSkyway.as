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
			startLoopTime = -1;// ConvertSamplesToMilliseconds(0);
			endLoopTime = -1;//-(ConvertSamplesToMilliseconds(0) + startTime);
		}
		
	}

}