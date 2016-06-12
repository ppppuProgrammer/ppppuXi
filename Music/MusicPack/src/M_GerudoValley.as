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
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = ConvertSamplesToMilliseconds(723190+576);
			endLoopTime =- (ConvertSamplesToMilliseconds(647) + startTime);
			
		}
		
	}

}