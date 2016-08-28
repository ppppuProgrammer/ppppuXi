package 
{
	import modifications.MusicMod;
	/**
	 * ...
	 * @author 
	 */
	public class M_MarioAdventures extends MusicMod
	{
		public function M_MarioAdventures() 
		{
			musicName = "SML1_1"
			sourceSound = new BGM_MarioAdventures1;
			displayInfo = "Mario Adventures I";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = 16000; //16 seconds
			//endLoopTime = -1;
		}
		
	}

}