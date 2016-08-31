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
			startTime = ConvertSamplesToMilliseconds(1440);
			//Around 46s, 24116 samples
			startLoopTime = 44000; //44 seconds
			//The end of the song is the end loop point
			endLoopTime= -1;
		}
		
	}

}