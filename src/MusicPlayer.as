package  
{
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.events.Event; 
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import mx.logging.*;
	import flash.events.UncaughtErrorEvent;
	
	public class MusicPlayer 
	{
		private var m_canPlayMusic:Boolean = true; //If music is allowed to play at all
		//private var m_characterMusic:Vector.<Sound>; //Holds the various Sound objects that are used as a character's background music.
		
		//Holds various, unique Music objects that contain a character's background music and the logic needed to play it.
		private var m_musicCollection:Vector.<Music>; 
		//Keep track of the name - Id relation of the music added to the player
		private var m_musicIdLookup:Dictionary;
		private var initialMusicSetUsed:Boolean = false;
		
		private var m_currentlyPlayingMusicId:int = -1; //-1 means no song has been played yet, any other corresponds to an index for an object in m_characterMusic
		public var m_mainSoundChannel:SoundChannel; //Sound channel used by the currently playing Sound

		//Time in milliseconds between the character switch transition. Used for music time rounding purposes to keep it in sync with the animation.
		private const MUSICSEGMENTTIMEMILLI:int = 4000;
		
		//The logging object for this class
		private var logger:ILogger;
		
		//Sets up the vectors in the music manager. This should be done after all characters have been added and locked in.
		public function MusicPlayer()
		{
			//Create the logger object that's used by this class to output messages.
			logger = Log.getLogger("MusicPlayer");
			logger.info("Initializing Music Player");
			m_musicCollection = new Vector.<Music>();

			m_musicIdLookup = new Dictionary();
		}
		
		public function AddMusic(soundData:Sound, musicName:String, musicInfo:String, loopStartTimeMs:Number=0, loopEndTimeMs:Number=0, musicStartTimeMs:Number=0):Boolean
		{
			if(soundData != null)
			{
				if(soundData.bytesTotal == 0)
				{
					logger.warn("Music \"" + musicName + "\" was not added as it contained no data");
					return false;//Sound did not load, do not add it to the character music vector
				}
				
				//Values lower than 0 mean to calculate the loop end point by adding the [negative] given loop end point's value to the bgm's length.
				if (loopEndTimeMs < 0.0)
				{
					loopEndTimeMs = soundData.length + loopEndTimeMs;
				}
				var MusicObj:Music = new Music(soundData, musicName, musicInfo, loopStartTimeMs, loopEndTimeMs, musicStartTimeMs);
				
				for (var i:int = 0, l:int = m_musicCollection.length; i < l; ++i) 
				{
					if (m_musicCollection[i] != null)
					{
						//Music checking only cares that 2 songs don't have to same name.
						if (m_musicCollection[i].GetMusicInfo().toLowerCase() == musicName.toLowerCase())
						{
							logger.warn("Music \"" + musicName + "\" was not added as music with the same name was already added.");
							return false;
						}
					}
				}
				
				var musicId:int = m_musicCollection.length;
				m_musicCollection[musicId] = MusicObj;
				m_musicIdLookup[musicName] = musicId;
				return true;
			}
			logger.warn("Music \"" + musicName + "\" was not added as it contained no data");
			return false;
		}
		
		//A one shot function. Sets the music id to start the music player with. After that this function is unusable
		//as the PlayMusic function should be used.
		public function SetInitialMusicToPlay(musicId:int):void
		{
			if (initialMusicSetUsed == false)
			{
				m_currentlyPlayingMusicId = musicId;
				initialMusicSetUsed = true;
			}
		}
		
		/*Attempts to play a certain music track based on it's id.
		 * currentTimeIntoAnimation - the amount of time that the current animation has completed. Expects animations to last for 4 seconds.
		 * if musicId is -2 then it invokes a context based action involving whether music can play or not.
		 * if Music can play then it will resume playing music based on the currentplayingmusicid. If music playing isn't allowed then it'll
		 * stop playing the currently playing music but not set it to -1, which indicates that no music has been selected.
		 * */
		
		//public function PlayMusic( musicId:int, currentFrame:uint /*, characterId:int=-1,*/):String
		public function PlayMusic( musicId:int, currentTimeIntoAnimation:Number):String
		{
			//trace("time:" + currentTimeIntoAnimation);
			//If music is allowed to play and the music id given is already playing then exit the function.
			//Return null as there were no changes to the music 
			if (musicId == m_currentlyPlayingMusicId && musicId > -1 && m_canPlayMusic == true) { return null; }
			
			var bgm:Music;
			var playheadPosition:Number;
			
			if (musicId > -1 && musicId < m_musicCollection.length && m_canPlayMusic == true)
			{
				//stop music
				if (m_currentlyPlayingMusicId > -1)
				{
					StopMusic();

					m_currentlyPlayingMusicId = -1;
				}
				
				bgm = m_musicCollection[musicId];
				
				//currentAnimationFrame = currentFrame;
				/*To keep the animation and music synced, do a check to see what part of the 4 second "block"
				 * the music was stopped on. If it was before the frame (out of 120) that the animation is on now, just set the music forward a bit to match the position.
				 * If it was on or after the frame the animation is on, move to the next "block" for the music and then set the playhead's position to match that position.
				 * [1][2][3][4][5][6]
				 * If animation was on frame 4 when music changed, music's last frame was 4. 
				 * Later on, the music is set back when the animation is on frame 2.
				 * Because of this, the music will advance 118 frames worth of time to be in the right place
				 * If the animation was instead on frame 6, the music would only need to advance 2 frames worth of time.*/
				
				//last frame the music was played is less than the frame the animation is in, advance the music just enough to match
				playheadPosition = bgm.GetPlayheadPosition();
				//Round down the playhead position to the last frame.
				var musicPositionInAnimation:Number = playheadPosition % MUSICSEGMENTTIMEMILLI;
				//Here's how to visualize how animation and music timing works. [] represents a 4 second blocks of time for the music
				//[0-4][4-8][8-12][12-16][16-20]
				//Animation time is how far into a 4 second block that an animation is in.
				if (musicPositionInAnimation <= currentTimeIntoAnimation)
				{
					//Music's (last) position into the animation is less than the current time the animation is into.
					//Only need to move up the music's position a bit. To help visualize:
					//[0-4][4-8][8-12][12-16][16-20]
					//Music was last at 2.5s when the play was requested, animation is 3 seconds done.
					//Music just needs to be set to be in the same time as the animation in it's current block
					//so music is set to be at 3 seconds in (this does not include the time skipped due to the start point for music)
					bgm.SetPlayheadPosition(playheadPosition + (currentTimeIntoAnimation - musicPositionInAnimation));
				}
				else
				{
					//Music's (last) position is after the time that the animation is in. Need to skip to the next 4 second
					//section for the music then set it to match the time into animation. To help visualize:
					//[0-4][4-8][8-12][12-16][16-20]
					//Music was last at 2.5 seconds, Animation is 1.5 seconds done
					//The music should not rewind to match the position of the animation. So it must be set to its next block.
					//Music is now changed to the 4-8 second block, starting at 4 seconds. Then the amount of time the animation
					//has completed is added, making the music be 5.5 seconds in.
					//playheadPosition = (Math.ceil(playheadPosition / 4.0) * 4.0) + currentTimeIntoAnimation;
					bgm.SetPlayheadPosition((Math.round(playheadPosition / MUSICSEGMENTTIMEMILLI) * MUSICSEGMENTTIMEMILLI) + currentTimeIntoAnimation);
				}
				m_mainSoundChannel = bgm.Play();
				m_currentlyPlayingMusicId = musicId;	
			}
			else if(musicId == -2)
			{
				//resuming the last music that played
				if (m_canPlayMusic && m_currentlyPlayingMusicId > -1)
				{
					bgm = m_musicCollection[m_currentlyPlayingMusicId];

					playheadPosition = bgm.GetPlayheadPosition();
					var musicPositionInAnimation:Number = playheadPosition % MUSICSEGMENTTIMEMILLI;
					if (musicPositionInAnimation <= currentTimeIntoAnimation)
					{
						bgm.SetPlayheadPosition(playheadPosition + (currentTimeIntoAnimation - musicPositionInAnimation));
					}
					else
					{
						bgm.SetPlayheadPosition((Math.round(playheadPosition / MUSICSEGMENTTIMEMILLI) * MUSICSEGMENTTIMEMILLI) + currentTimeIntoAnimation);
					}
					m_mainSoundChannel = bgm.Play();
				}
				else //Stop the currently playing song but don't change m_currentlyPlayingMusicId
				{
					if (m_currentlyPlayingMusicId > -1)
					{
						m_musicCollection[m_currentlyPlayingMusicId].Stop();
					}
					if (m_mainSoundChannel)
					{
						m_mainSoundChannel.stop();
						m_mainSoundChannel = null;
					}
				}
			}
			else 
			{
				if (m_currentlyPlayingMusicId > -1)
				{
					m_musicCollection[m_currentlyPlayingMusicId].Stop();
				}
				if (m_mainSoundChannel != null)
				{
					m_mainSoundChannel.stop();
					m_mainSoundChannel = null;
				}
				//If music can't play then don't change the currently playing music
				//m_currentlyPlayingMusicId = -1;
			}

			if (m_canPlayMusic == true)
			{
				if (m_currentlyPlayingMusicId == -1)
				{
					return "No Music Selected";
				}
				else
				{
					return m_musicCollection[m_currentlyPlayingMusicId].GetMusicInfo();
				}
			}
			else
			{
				return "Music Off";
			}
		}
		
		//public function StopMusic(currentFrame:uint):void
		public function StopMusic():void
		{
			if (m_currentlyPlayingMusicId > -1)
			{
				m_mainSoundChannel.stop();
				m_musicCollection[m_currentlyPlayingMusicId].Stop();
				m_mainSoundChannel = null;
			}
		}
		//Adjusts the volume of the sound globally.
		public function ControlVolume(musicVolume:Number):void
		{
			var soundT:SoundTransform = new SoundTransform();
			soundT.volume = musicVolume;
			SoundMixer.soundTransform = soundT;
		}
		
		public function ChangeToPrevMusic(animationTime:Number):String
		{
			var prevMusicId:int = m_currentlyPlayingMusicId - 1;
			if (prevMusicId < 0) { prevMusicId = m_musicCollection.length - 1; }
			
			return PlayMusic(prevMusicId, animationTime);
		}
		
		public function ChangeToNextMusic(animationTime:Number):String
		{
			var nextMusicId:int = m_currentlyPlayingMusicId + 1;
			if (nextMusicId >= m_musicCollection.length) { nextMusicId = 0; }
			
			return PlayMusic(nextMusicId, animationTime);
		}
		
		public function GetMusicIdByName(name:String):int
		{
			for (var i:int = 0, l:int = m_musicCollection.length; i < l;++i )
			{
				if (name == m_musicCollection[i].GetMusicName())
				{
					return i;
				}
			}
			//Didn't find the name
			return -1;
		}
		
		//returns whether any music is allowed to be played/heard
		public function IsMusicPlaying() : Boolean
		{
			return m_canPlayMusic;
		}
		
		public function SetIfMusicIsEnabled(musicEnabled:Boolean):Boolean
		{
			m_canPlayMusic = musicEnabled;
			return m_canPlayMusic;
		}
		
		public function GetNameOfCurrentMusic():String
		{
			if (m_currentlyPlayingMusicId < 0 || m_currentlyPlayingMusicId > m_musicCollection.length){return "Music not found";}
			return m_musicCollection[m_currentlyPlayingMusicId].GetMusicName();
		}
		
		public function GetCurrentlyPlayingMusicTitle():String
		{
			if (m_currentlyPlayingMusicId < 0 || m_currentlyPlayingMusicId > m_musicCollection.length){return "Music not found";}
			return m_musicCollection[m_currentlyPlayingMusicId].GetMusicInfo();
		}
		//Debug functions
		public function DEBUG_GoToMusicLastSection(currentTimeIntoAnimation:Number):void
		{
			if(m_currentlyPlayingMusicId > -1)
			{
				var bgm:Music = m_musicCollection[m_currentlyPlayingMusicId];
				var musicPlayTime:Number = bgm.GetLoopEnd() - bgm.GetMusicStartTime();
				var playheadPosition:Number = musicPlayTime - (MUSICSEGMENTTIMEMILLI * 2);
				//trace("playhead's base position " + playheadPosition);
				//bgm.SetPlayheadPosition(playheadPosition);
				//trace("music position jumping to " + musicPlayTime);
				//Round down the playhead position to the last frame.
				var musicPositionInAnimation:Number = playheadPosition % MUSICSEGMENTTIMEMILLI;
				//trace("time animation has completed " + currentTimeIntoAnimation);
				//trace(musicPositionInAnimation);
				
				
				if (musicPositionInAnimation <= currentTimeIntoAnimation)
				{
					trace((currentTimeIntoAnimation - musicPositionInAnimation));
					bgm.SetPlayheadPosition(bgm.GetMusicStartTime() + playheadPosition + (currentTimeIntoAnimation - musicPositionInAnimation));
				}
				else
				{
					bgm.SetPlayheadPosition(bgm.GetMusicStartTime() + (Math.round(playheadPosition / MUSICSEGMENTTIMEMILLI) * MUSICSEGMENTTIMEMILLI) + currentTimeIntoAnimation);
				}
				//trace(bgm.GetPlayheadPosition());
				//trace(m_mainSoundChannel.position);
			}
			
		}
	}
}