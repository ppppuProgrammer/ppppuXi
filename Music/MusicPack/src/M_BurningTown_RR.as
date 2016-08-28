package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_BurningTown_RR extends MusicMod 
	{
		
		public function M_BurningTown_RR() 
		{
			sourceSound = new BGM_BurningTown_RR;
			musicName = "Burning Town RR";
			displayInfo = "Burning Town - Risky's Revenge";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = 24000; //24 seconds
			//endLoopTime = -1;
		}
		
	}

}