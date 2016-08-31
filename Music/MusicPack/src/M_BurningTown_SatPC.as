package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_BurningTown_SatPC extends MusicMod 
	{
		
		public function M_BurningTown_SatPC() 
		{
			sourceSound = new BGM_BurningTown_PC;
			musicName = "Burning Town PC";
			displayInfo = "We love Burning Town";
			startTime = ConvertSamplesToMilliseconds(1296);
			startLoopTime = 16000; //16 seconds
			//endLoopTime = -1;
		}
		
	}

}