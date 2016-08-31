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
			startTime = ConvertSamplesToMilliseconds(2160);
			startLoopTime = 4000; //4 seconds
			//1m8s
			//endLoopTime= -1;
		}
		
	}

}