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
			startLoopTime = ConvertSamplesToMilliseconds(190538+576);
			endLoopTime = -(ConvertSamplesToMilliseconds(618) + startTime);
			
		}
		
	}

}