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
			//Around 46s, 24116 samples
			startLoopTime = ConvertSamplesToMilliseconds((46*44100)+24116);
			//The end of the song is the end loop point
			endLoopTime= -1;
		}
		
	}

}