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
			//startLoopTime = ConvertSamplesToMilliseconds(792431+576);
			//endLoopTime = - (ConvertSamplesToMilliseconds(1394) + startTime);
			startLoopTime = ConvertSamplesToMilliseconds(739524 + 576);
			endLoopTime = ConvertSamplesToMilliseconds(3917226+576);
		}
		
	}

}