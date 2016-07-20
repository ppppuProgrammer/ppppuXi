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
			startLoopTime = -1;
			endLoopTime = -1;
			
		}
		
	}

}