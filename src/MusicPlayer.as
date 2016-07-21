package  
{
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.events.Event; 
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	//import ppppu.Music;
	
	public class MusicPlayer 
	{
		private var m_canPlayMusic:Boolean = true; //If music is allowed to play at all
		//private var m_characterMusic:Vector.<Sound>; //Holds the various Sound objects that are used as a character's background music.
		
		//Holds various, unique Music objects that contain a character's background music and the logic needed to play it.
		private var m_musicCollection:Vector.<Music>; 
		//Keep track of the name - Id relation of the music added to the player
		private var m_musicIdLookup:Dictionary;
		private var initialMusicSetUsed:Boolean = false;
		//private var m_globalMusicId:int = -1;
		//private var m_characterDefaultMusicId:Vector.<int>;
		//private var m_playGlobalMusic:Boolean = false;
		/*Holds the value of the last frame to be played for the music of a certain id. Used to keep the music
		* synced with the animation as it can be determined whether to go to the next 4 second block of music
		* or to jump the play head forward a bit in the case of the music being switched from then switched back within the same 4 second block.
		* -1 indicates that the music has not been played at all.*/
		private var m_musicLastPlayedFrame:Vector.<uint>; 
		//private var m_selectedMusicForCharacter:Vector.<int>; 
		/*Indicates which music by id to play when a character is in music select mode.
		This is indicated by the bool in m_playCharacterMusic[charId] being set to false*/
		
		private var m_currentlyPlayingMusicId:int = -1; //-1 means no song has been played yet, any other corresponds to an index for an object in m_characterMusic
		private var m_mainSoundChannel:SoundChannel; //Sound channel used by the currently playing Sound

		//Time in milliseconds between the character switch transition. Used for music time rounding purposes to keep it in sync with the animation.
		private const MUSICSEGMENTTIMEMILLI:int = 4000;
		
		//private var appCurrentFrame:int;
		//public const DEFAULTSONGTITLE:String = "Beep Block Skyway";
		//Sets up the vectors in the music manager. This should be done after all characters have been added and locked in.
		public function MusicPlayer()
		{
			m_musicCollection = new Vector.<Music>();
			//m_characterDefaultMusicId = new Vector.<int>();
			//m_selectedMusicForCharacter = new Vector.<int>();
			m_musicLastPlayedFrame = new Vector.<uint>();
			m_musicIdLookup = new Dictionary();
			/*for (var j:int = 0; j < numberOfCharacters; ++j) 
			{
				m_selectedMusicForCharacter[j] = -1;
				m_characterDefaultMusicId[j] = -1;
			}*/
		}
		
		public function AddMusic(soundData:Sound, musicName:String, musicInfo:String, loopStartTimeMs:Number=0, loopEndTimeMs:Number=0, musicStartTimeMs:Number=0):void
		{
			if(soundData != null)
			{
				if(soundData.bytesTotal == 0)
				{
					return;//Sound did not load, do not add it to the character music vector
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
							return;
						}
						
						//Old same music checking
						/*if (m_musicCollection[i].Equals(MusicObj) == true)
						{
							m_characterDefaultMusicId[characterId] = i;
							m_selectedMusicForCharacter[characterId] = i;
							return;
						}*/
					}
				}
				
				//m_playCharacterMusic[characterId] = true;
				var musicId:int = m_musicCollection.length;
				m_musicCollection[musicId] = MusicObj;
				m_musicIdLookup[musicName] = musicId;
				m_musicLastPlayedFrame[musicId] = 0;
				//m_syncingSoundChannels[musicId] = null;
				//m_characterDefaultMusicId[characterId] = musicId;
				//m_selectedMusicForCharacter[characterId] = musicId;
			}
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
		 * CurrentFrame - the total amount of frames that the program has been run for.
		 * if musicId is -2 then it invokes a context based action involving whether music can play or not.
		 * if Music can play then it will resume playing music based on the currentplayingmusicid. If music can't play then it'll
		 * stop playing the currently playing music but not set it to -1, which indicates that no music has been selected.
		 * */
		public function PlayMusic( musicId:int, currentFrame:uint /*, characterId:int=-1,*/):String
		{
			//If music is allowed to play and the music id given is already playing then exit the function.
			//Return null as there were no changes to the music 
			if (musicId == m_currentlyPlayingMusicId && musicId > -1 && m_canPlayMusic == true) { return null; }
			
			/*if (m_currentlyPlayingMusicId > -1)
			{
				m_musicLastPlayedFrame[m_currentlyPlayingMusicId] = currentFrame;
				m_mainSoundChannel.stop();
				m_musicCollection[m_currentlyPlayingMusicId].Stop();
				m_mainSoundChannel = null;
				m_currentlyPlayingMusicId = -1;
			}*/
			
			var bgm:Music;
			var currentAnimationFrame:int;
			var lastAnimationFrame:int;
			var playheadPosition:Number;
			var roundFactor:Number = 1000.0 / 30.0;
			var jumpAheadTime:Number;
			if (musicId > -1 && musicId < m_musicCollection.length && m_canPlayMusic == true)
			{
				//stop music
				if (m_currentlyPlayingMusicId > -1)
				{
					m_musicLastPlayedFrame[m_currentlyPlayingMusicId] = currentFrame;
					m_mainSoundChannel.stop();
					m_musicCollection[m_currentlyPlayingMusicId].Stop();
					m_mainSoundChannel = null;
					m_currentlyPlayingMusicId = -1;
				}
				
				bgm = m_musicCollection[musicId];
				//If music hasn't started yet, set the playhead position to be at the start time.
				if (bgm.GetPlayheadPosition() == 0)
				{
					bgm.SetPlayheadPosition(bgm.GetMusicStartTime());
				}
				currentAnimationFrame = (currentFrame % 120)+1;
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
				playheadPosition = Math.floor(playheadPosition / roundFactor) * roundFactor;
				lastAnimationFrame = (m_musicLastPlayedFrame[musicId] % 120) + 1;
				
				if (lastAnimationFrame <= currentAnimationFrame)
				{
					jumpAheadTime = (currentAnimationFrame - lastAnimationFrame) * roundFactor;
					bgm.SetPlayheadPosition(playheadPosition + jumpAheadTime);
				}
				else //Last frame the music was played on is greater than the frame the animation is in, need to jump to the next 4 second block for the music.
				{
					jumpAheadTime = (120 - currentAnimationFrame) * roundFactor;
					bgm.SetPlayheadPosition(playheadPosition + jumpAheadTime );
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
					//If music hasn't started yet, set the playhead position to be at the start time.
					if (bgm.GetPlayheadPosition() == 0)
					{
						bgm.SetPlayheadPosition(bgm.GetMusicStartTime());
					}
					currentAnimationFrame = (currentFrame % 120)+1;
					
					//last frame the music was played is less than the frame the animation is in, advance the music just enough to match
					playheadPosition = bgm.GetPlayheadPosition();
					//Round down the playhead position to the last frame.
					playheadPosition = Math.floor(playheadPosition / roundFactor) * roundFactor;
					lastAnimationFrame = (m_musicLastPlayedFrame[m_currentlyPlayingMusicId] % 120) + 1;
					if (lastAnimationFrame <= currentAnimationFrame)
					{
						jumpAheadTime = (currentAnimationFrame - lastAnimationFrame) * roundFactor;
						bgm.SetPlayheadPosition(playheadPosition + jumpAheadTime);
					}
					else //Last frame the music was played on is greater than the frame the animation is in, need to jump to the next 4 second block for the music.
					{
						jumpAheadTime = (120 - currentAnimationFrame) * roundFactor;
						bgm.SetPlayheadPosition(playheadPosition + jumpAheadTime );
					}
					m_mainSoundChannel = bgm.Play();
				}
				else //Stop the currently playing song but don't change m_currentlyPlayingMusicId
				{
					if (m_currentlyPlayingMusicId > -1)
					{
						m_musicLastPlayedFrame[m_currentlyPlayingMusicId] = currentFrame;
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
					m_musicLastPlayedFrame[m_currentlyPlayingMusicId] = currentFrame;
					m_musicCollection[m_currentlyPlayingMusicId].Stop();
				}
				m_mainSoundChannel.stop();
				m_mainSoundChannel = null;
				//If music can't play then don't change the currently playing music
				m_currentlyPlayingMusicId = -1;
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
		
		public function StopMusic(currentFrame:uint):void
		{
			if (m_currentlyPlayingMusicId > -1)
			{
				m_musicLastPlayedFrame[m_currentlyPlayingMusicId] = currentFrame;
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
		
		/*public function ToggleMusicSelectionMode(currentCharId:int, animationFrame:int):void //Toggles between the selectable music or character specific music playing.
		{
			//m_playCharacterMusic[currentCharId] = !m_playCharacterMusic[currentCharId];
			if(m_playCharacterMusic[currentCharId] == true) //Play the character's default music if true
			{
				m_selectedMusicForCharacter[currentCharId] = m_characterDefaultMusicId[currentCharId];
			}
			PlayMusic(currentCharId, animationFrame);
		}*/
		
		public function ChangeToPrevMusic(animationFrame:int):String
		{
			var prevMusicId:int = m_currentlyPlayingMusicId - 1;
			if (prevMusicId < 0) { prevMusicId = m_musicCollection.length - 1; }
			
			return PlayMusic(prevMusicId, animationFrame);
		}
		
		public function ChangeToNextMusic(animationFrame:int):String
		{
			var nextMusicId:int = m_currentlyPlayingMusicId + 1;
			if (nextMusicId >= m_musicCollection.length) { nextMusicId = 0; }
			
			return PlayMusic(nextMusicId, animationFrame);
		}
		
		/*public function ChangeSelectedMusicForCharacter(charId:int, musicId:int):void
		{
			if (m_playGlobalMusic == false)
			{
				m_selectedMusicForCharacter[charId] = musicId;
			}
			else
			{
				m_globalMusicId = musicId;
			}
		}*/
		
		/*public function ChangeGlobalMusic(musicId:int):void
		{
			m_globalMusicId = musicId;
		}*/
		
		/*public function GetCurrentMusicIdForCharacter(charId:int):int
		{
			return m_selectedMusicForCharacter[charId];
		}*/
		
		/*public function GetGlobalCurrentMusicId():int
		{
			return m_globalMusicId;
		}*/
		
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
		
		/*public function ChangePlayGlobalSongStatus(status:Boolean):void
		{
			m_playGlobalMusic = status;
		}
		public function GetGlobalSongStatus():Boolean
		{
			return m_playGlobalMusic;
		}*/
		
		/* //Obsolete function
		public function ChangeToCurrentMusicForAllCharacters():void
		{
			if (m_currentlyPlayingMusicId < -1 || m_currentlyPlayingMusicId >= m_characterMusic.length)
			{
				return;
			}

			for (var i:int = 0, l:int = m_selectedMusicForCharacter.length; i < l; i++) 
			{
				m_selectedMusicForCharacter[i] = m_currentlyPlayingMusicId;
			}
		}*/
		/*public function ControlDefaultMusicVolume(musicVolume:Number):void
		{
			var soundT:SoundTransform = new SoundTransform();
			soundT.volume = musicVolume;
			m_mainMovieClip.soundTransform = soundT;
		}*/
		
		/*public function ControlCharacterMusicVolume(musicVolume:Number):void
		{
			var soundT:SoundTransform = new SoundTransform();
			soundT.volume = musicVolume;
			m_mainSoundChannel.soundTransform = soundT;
		}
		
		public function ToggleGlobalPlayMusicStatus() : Boolean
		{
			m_playMusic = !m_playMusic;
			var titleToUse:String;
			if (m_playMusic)
			{
				if(m_currentlyPlayingMusicId >= 0 && m_currentlyPlayingMusicId < m_musicCollection.length)
				{
					titleToUse = m_musicCollection[m_currentlyPlayingMusicId].GetMusicTitle();
				}
				else if (m_currentlyPlayingMusicId == -1)
				{
					titleToUse = "Beep Block Skyway";
				}
				else
				{
					titleToUse = "Unknown";
				}
			}
			else 
			{
				titleToUse = "Music off";
			}
			//ChangeDisplayedMusicTitle(titleToUse, !m_playMusic);
			return IsMusicPlaying();
		}*/
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
		/*public function GetPlayCharacterMusicStatus(charId:int):Boolean
		{
			return m_playCharacterMusic[charId];
		}*/
		
		//Changes the text that displays the name of the music playing. By default it can only change when the music is not muted but forceChange can override this behavior
		/*private function ChangeDisplayedMusicTitle(newMusicTitle:String, forceChange:Boolean=false):void
		{
			if (m_playMusic == true || forceChange == true)
			{
				m_musicInfoDisplay.text = newMusicTitle.toLowerCase();
			}
		}*/
		
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
		/*public function DEBUG_GoToMusicLastSection():void
		{
			if(m_currentlyPlayingMusicId > -1)
			{
				var musicToPlay:Music = m_characterMusic[m_currentlyPlayingMusicId];
				musicToPlay.SetPlayheadPosition(musicToPlay.GetLoopEnd() - 4000);
			}
			
		}*/
	}
}