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
			displayInfo = "Turnabout Sisters 2001";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = -1;
			endLoopTime= -1;
		}
		
	}

}