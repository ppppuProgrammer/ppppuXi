package 
{
	import modifications.MusicMod;
	/**
	 * ...
	 * @author 
	 */
	public class M_TurnaboutSisters extends MusicMod
	{
		
		public function M_TurnaboutSisters() 
		{
			sourceSound = new BGM_TurnaboutSisters;
			musicName = "Turnabout Sisters";
			displayInfo = "Turnabout Sisters 2001 - Phoenix Wright Ace Attorney";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = ConvertSamplesToMilliseconds(0) + startTime;
			endLoopTime= (ConvertSamplesToMilliseconds(0) + startTime);
		}
		
	}

}