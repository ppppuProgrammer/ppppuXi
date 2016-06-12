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
			startLoopTime = ConvertSamplesToMilliseconds(90252+576);
			endLoopTime = (ConvertSamplesToMilliseconds(3967612+576) /*+ startTime*/);
			
		}
		
	}

}