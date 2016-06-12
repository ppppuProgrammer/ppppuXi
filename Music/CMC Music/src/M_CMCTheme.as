package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_CMCTheme extends MusicMod 
	{
		
		public function M_CMCTheme() 
		{
			sourceSound = new BGM_CMCGC;
			musicName = "CMC GC"
			displayInfo = "Cutie Mark Crusaders Go Crusading - MLP FiM";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = ConvertSamplesToMilliseconds(0);
			endLoopTime = -(ConvertSamplesToMilliseconds(0) + startTime);
			
		}
		
	}

}