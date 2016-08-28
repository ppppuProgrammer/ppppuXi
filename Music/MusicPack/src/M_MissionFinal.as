package 
{
	import modifications.MusicMod;
	
	/**
	 * ...
	 * @author 
	 */
	public class M_MissionFinal extends MusicMod 
	{
		
		public function M_MissionFinal() 
		{
			sourceSound = new BGM_MissionFinal;
			musicName = "Mission Final";
			displayInfo = "Mission Final - Metroid Prime";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = 8000; //8 seconds
			//endLoopTime = -1;
		}
		
	}

}