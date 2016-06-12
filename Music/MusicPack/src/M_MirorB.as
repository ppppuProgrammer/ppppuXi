package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_MirorB extends MusicMod 
	{
		
		public function M_MirorB() 
		{
			sourceSound = new BGM_MirorB;
			musicName = "Miror B";
			displayInfo = "Miror B. Battle - Pokemon XD";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = ConvertSamplesToMilliseconds(871773) + startTime;
			endLoopTime= (ConvertSamplesToMilliseconds(2989939) + startTime);
			
		}
		
	}

}