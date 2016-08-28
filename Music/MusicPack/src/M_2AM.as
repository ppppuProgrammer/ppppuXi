package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_2AM extends MusicMod 
	{
		
		public function M_2AM() 
		{
			sourceSound = new BGM_2AM;
			musicName = "2 AM";
			displayInfo = "2:00 A.M. - Super Smash Bros. Brawl";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = 8000; //8 seconds
			//endLoopTime = -1;
			
		}
		
	}

}