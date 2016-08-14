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
			//around 10728 samples
			startLoopTime = ConvertSamplesToMilliseconds(10728);
			//Around 1m,3s,40796samples
			endLoopTime= ConvertSamplesToMilliseconds((63*44100)+40796);
		}
		
	}

}