package modifications 
{
	import flash.media.Sound;
	import modifications.Mod;
	/**
	 * ...
	 * @author 
	 */
	public class MusicMod extends Mod
	{
		//Contains the audio data that will be played.
		protected var sourceSound:Sound=null;
		//Where to start playing the music from on the inital playback.
		protected var startTime:Number=0;
		//Time in milliseconds of where to set the playhead when the endLoopTime is reached.
		protected var startLoopTime:Number = 0;
		//Time in milliseconds of where  the end loop of the music is. Upon reaching this, the playhead will be set to the start loop time.
		protected var endLoopTime:Number = -1;
		/*The name used to refer to the music instance. This is used by characters to denote their default song. Checks involving the name
		 * are case insensitive, so 2 different music mods named "BgM" and "BGM" will conflict and the first one loaded will only be used.*/
		protected var musicName:String = "";
		//The text to display on the music player when the music is playing
		protected var displayInfo:String = "";
		
		public function MusicMod() 
		{
			modType = Mod.MOD_MUSIC;
		}
		
		public function GetMusicData():Sound
		{
			return sourceSound;
		}
		public function GetStartTime():Number
		{
			return startTime;
		}
		public function GetStartLoopTime():Number
		{
			return startLoopTime;
		}
		public function GetEndLoopTime():Number
		{
			return endLoopTime;
		}
		public function GetName():String
		{
			return musicName;
		}
		public function GetDisplayInformation():String
		{
			return displayInfo;
		}
		
		//Helper function to convert samples to milliseconds, assuming a sample rate of 44100 hz
		protected function ConvertSamplesToMilliseconds(sampleNum:Number):Number
		{
			return (sampleNum / 44100.0) * 1000.0;
		}
	}
}