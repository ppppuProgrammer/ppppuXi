package 
{
	import modifications.MusicMod;
	/**
	 * ...
	 * @author 
	 */
	public class M_FE_Spa extends MusicMod
	{
		
		public function M_FE_Spa() 
		{
			sourceSound = new BGM_FE_Spa;
			musicName = "FE Spa";
			displayInfo = "Main Theme (Spa) - Fire Emblem 13";
			startTime = ConvertSamplesToMilliseconds(2016);
			startLoopTime = 16000; //16 seconds
			//endLoopTime = -1;
		}
		
	}

}