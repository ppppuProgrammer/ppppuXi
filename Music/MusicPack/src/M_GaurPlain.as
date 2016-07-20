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
			startLoopTime = -1;
			endLoopTime= -1;
		}
		
	}

}