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
			startTime = ConvertSamplesToMilliseconds(1584);
			startLoopTime = 36000; //36 seconds
			//endLoopTime = -1;
			
		}
		
	}

}