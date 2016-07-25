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
			displayInfo = "Cutie Mark Crusaders Go Crusading";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = ConvertSamplesToMilliseconds((37*44100)+22119); //Around 37s+22119 (give or take 750 samples)
			endLoopTime = ConvertSamplesToMilliseconds((142*44100)+33000); // Around 2:22+33000
			
		}
		
	}

}