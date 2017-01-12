package modifications 
{
	import flash.media.Sound;
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class MusicMod extends Mod implements IModdable
	{
		//Contains the audio data that will be played.
		protected var sourceSound:Sound=null;
		//Time in milliseconds to start playing the music from on the inital playback.
		protected var startTime:Number=0;
		//Time in milliseconds of where to set the playhead when the endLoopTime is reached.
		protected var startLoopTime:Number = 0;
		//Time in milliseconds of where  the end loop of the music is. Upon reaching this, the playhead will be set to the start loop time.
		protected var endLoopTime:Number = -1;
		/*The name used to refer to the music instance. This is used by characters to denote their preferred song. Checks involving the name
		 * are case insensitive, so 2 different music mods named "BgM" and "BGM" will conflict and the first one loaded will only be used.*/
		protected var musicName:String = "";
		//The text to display on the music player when the music is playing
		protected var displayInfo:String = "";
		
		
		public function MusicMod() 
		{
			modType = Mod.MOD_MUSIC;
		}
		/*Used to create a music mod when a mp3 is loaded into the program. Limited in the fact
		 * that seamless loop points can not be set.*/
		public static function CreateMusicModFromMP3(sound:Sound, musicName:String):MusicMod
		{
			var musicMod:MusicMod = null;
			if (sound && musicName)
			{
				musicMod = new MusicMod();
				musicMod.sourceSound = sound;
				musicMod.musicName = musicName;
				musicMod.displayInfo = musicName.substring(0, musicName.lastIndexOf("."));
			}
			return musicMod;
		}
		override protected function FirstFrame(e:Event):void
		{
			super.FirstFrame(e);
			if (displayInfo == null || displayInfo.length == 0)
			{
				displayInfo = musicName;
			}
		}
		
		public function OutputModDetails():String
		{
			return "Music Name: " + musicName + ", Display Title: " + displayInfo;
		}
		
		public override function Dispose():void
		{
			super.Dispose();
			sourceSound = null;
			displayInfo = null;
			musicName = null;
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
			return (sampleNum / 44.1);
		}
	}
}