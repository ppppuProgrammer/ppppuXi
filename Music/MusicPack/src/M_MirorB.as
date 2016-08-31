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
			startTime = ConvertSamplesToMilliseconds(2160);
			startLoopTime = 20000; // 20 seconds
			//endLoopTime= (ConvertSamplesToMilliseconds(2989939) + startTime);
			
		}
		
	}

}