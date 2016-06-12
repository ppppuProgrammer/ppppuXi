package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_WFTrainingMenu extends MusicMod 
	{
		
		public function M_WFTrainingMenu() 
		{
			musicName = "WF Training Menu";
			sourceSound = new BGM_WFTrainingMenu;
			displayInfo = "Training Menu - Wii Fit";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = ConvertSamplesToMilliseconds(1415850) + startTime;
			endLoopTime = (ConvertSamplesToMilliseconds(3527735) + startTime);
			
		}
		
	}

}