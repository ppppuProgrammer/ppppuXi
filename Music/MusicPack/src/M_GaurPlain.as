package 
{
	import modifications.MusicMod;
	/**
	 * ...
	 * @author 
	 */
	public class M_GaurPlain extends MusicMod
	{
		
		public function M_GaurPlain() 
		{
			sourceSound = new BGM_GaurPlain;
			musicName = "Gaur Plain";
			displayInfo = "Gaur Plain - Xenoblade Chronicles";
			startTime = ConvertSamplesToMilliseconds(576);
			startLoopTime = ConvertSamplesToMilliseconds(0) + startTime;
			endLoopTime= (ConvertSamplesToMilliseconds(0) + startTime);
		}
		
	}

}