package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_Route1 extends MusicMod 
	{
		
		public function M_Route1() 
		{
			sourceSound = new BGM_Route1;
			musicName = "Route 1";
			displayInfo = "Route 1 - Pokemon Anime";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = ConvertSamplesToMilliseconds(1066558) + startTime;
			endLoopTime= (ConvertSamplesToMilliseconds(2123951) + startTime);
		}
		
	}

}