package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_GerudoValley extends MusicMod 
	{
		
		public function M_GerudoValley() 
		{
			sourceSound = new BGM_GerudoValley;
			musicName = "Gerudo Valley";
			displayInfo = "Gerudo Valley (Remix) - Smash 4";
			startTime = ConvertSamplesToMilliseconds(1440);
			startLoopTime = 16000;
			//endLoopTime = -1;
			
		}
		
	}

}