package  
{
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.events.Event; 
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	//import ppppu.Music;
	
	public class MusicPlayer 
	{
		private var m_playMusic:Boolean = true; //If music is allowed to play at all
		//private var m_characterMusic:Vector.<Sound>; //Holds the various Sound objects that are used as a character's background music.
		
		//Holds various, unique Music objects that contain a character's background music and the logic needed to play it.
		private var m_characterMusic:Vector.<Music>; 
		private var m_globalMusicId:int = -1;
		private var m_characterDefaultMusicId:Vector.<int>;
		private var m_playGlobalMusic:Boolean = false;
		//private var m_playCharacterMusic:Vector.<Boolean>; //Tells whether to play the character's own music only (true) or the selected music(false).
		private var m_selectedMusicForCharacter:Vector.<int>; /*Indicates which music by id to play when a character is in music select mode.
		This is indicated by the bool in m_playCharacterMusic[charId] being set to false*/
		private var m_musicInfoDisplay:TextField; //Used to update the music information display. This is set during the SetupMusicManager function.
		
		private var m_syncingSoundChannels:Vector.<SoundChannel>; 
		//private var m_syncingSoundChannels:Dictionary = new Dictionary();
		
		private var m_currentlyPlayingMusicId:int = -2; //-2 means no song has been played yet, -1 means means to use the default music, any other corresponds to an index for an object in m_characterMusic
		private var m_mainSoundChannel:SoundChannel; //Sound channel used by the currently playing Sound

		private var m_defaultBgmTransform:SoundTransform = null; //Sound transform of the movie clip that contains the beep block skyway song.
		private var m_mainMovieClip:MovieClip = null;
		private var FLASHFRAMERATE:Number;
		//Time in milliseconds between the character switch transition. Used for music time rounding purposes to keep it in sync with the animation.
		private const MUSICSEGMENTTIMEMILLI:int = 4000;
		public const DEFAULTSONGTITLE:String = "Beep Block Skyway";
		//Sets up the vectors in the music manager. This should be done after all characters have been added and locked in.
		public function SetupMusicManager(numberOfCharacters:int, clip:MovieClip, flashFrameRate:Number, playMusicInfoDisplay:TextField):void
		{
			FLASHFRAMERATE = flashFrameRate;
			m_characterMusic = new Vector.<Music>();
			m_syncingSoundChannels = new Vector.<SoundChannel>();
			m_characterDefaultMusicId = new Vector.<int>(numberOfCharacters, true);
			m_selectedMusicForCharacter = new Vector.<int>(numberOfCharacters, true);
			for (var j:int = 0; j < numberOfCharacters; ++j) 
			{
				m_selectedMusicForCharacter[j] = -1;
				m_characterDefaultMusicId[j] = -1;
			}
			m_mainMovieClip = clip;
			m_musicInfoDisplay = playMusicInfoDisplay;
		}
		
		public function AddMusic(characterId:int, characterBGM:Sound, musicTitle:String, loopStartTimeMs:Number=0, loopEndTimeMs:Number=0, musicStartTimeMs:Number=0):void
		{
			if(characterBGM != null)
			{
				if(characterBGM.bytesTotal == 0)
				{
					return;//Sound did not load, do not add it to the character music vector
				}
				
				//Values lower than 0 mean to calculate the loop end point by adding the [negative] given loop end point's value to the bgm's length.
				if (loopEndTimeMs < 0.0)
				{
					loopEndTimeMs = characterBGM.length + loopEndTimeMs;
				}
				var MusicObj:Music = new Music(characterBGM, musicTitle, loopStartTimeMs, loopEndTimeMs, musicStartTimeMs);
				
				for (var i:int = 0, l:int = m_characterMusic.length; i < l; ++i) 
				{
					if (m_characterMusic[i] != null)
					{
						if (m_characterMusic[i].Equals(MusicObj) == true)
						{
							m_characterDefaultMusicId[characterId] = i;
							m_selectedMusicForCharacter[characterId] = i;
							return;
						}
					}
				}
				
				//m_playCharacterMusic[characterId] = true;
				var musicIndex:int = m_characterMusic.length;
				m_characterMusic[musicIndex] = MusicObj;
				m_syncingSoundChannels[musicIndex] = null;
				m_characterDefaultMusicId[characterId] = musicIndex;
				m_selectedMusicForCharacter[characterId] = musicIndex;
			}
		}
		
		/*Attempts to play a certain music track or adjusts the volume of the 2 tracks (default & character) so only 1 is heard.
		musicId indicates the music to play which corresponds to a certain character based on their own id.
		abruptChangeFrameOffset indicates how far into the the character's 120 frame/4 sec animation the flash is.*/
		public function PlayMusic(characterId:int=-1, abruptChangeFrameOffset:int=0):void
		{
			//if there was no sudden character change, go through the held sound channels, stop them and clear the sync sound channels vector.
			if(abruptChangeFrameOffset == 0)
			{
				var currentChannel:SoundChannel;
				var musicForCurrentChannel:Music;
				for (var i:int = 0, l:int = m_syncingSoundChannels.length; i < l; i++) 
				{
					currentChannel = m_syncingSoundChannels[i];
					if(currentChannel != null)
					{
						musicForCurrentChannel = m_characterMusic[i];
						//music timing adjustment
						var position:Number = musicForCurrentChannel.GetPlayheadPosition();
						currentChannel.stop();
						musicForCurrentChannel.Stop();
						var rounded:Number = Math.round(position / MUSICSEGMENTTIMEMILLI);
						musicForCurrentChannel.SetPlayheadPosition((rounded * MUSICSEGMENTTIMEMILLI)+musicForCurrentChannel.GetMusicStartTime());
					}
					m_syncingSoundChannels[i] = null;
				}
			}
			var musicId:int;
			if (m_playGlobalMusic)
			{
				musicId = m_globalMusicId;
			}
			else
			{
				if (characterId < 0)
				{
					musicId = -1;
				}
				else
				{
					musicId = m_selectedMusicForCharacter[characterId];
				}
			}

			if(musicId == -1) //play default song
			{
				if(m_currentlyPlayingMusicId > -1) //A character song is currently playing
				{	
					ControlCharacterMusicVolume(0.0);
					
					if(abruptChangeFrameOffset > 0)
					{
						m_syncingSoundChannels[m_currentlyPlayingMusicId] = m_mainSoundChannel;
					}
					else
					{
						var currentMusic:Music = m_characterMusic[m_currentlyPlayingMusicId];
						m_mainSoundChannel.stop();
						currentMusic.Stop();
						m_mainSoundChannel = null;
					}
					m_currentlyPlayingMusicId = -1;
					ChangeDisplayedMusicTitle("beep block skyway");
					ControlDefaultMusicVolume(1.0);
				}
				else if (m_currentlyPlayingMusicId == -2) //Nothing is currently playing
				{
					m_currentlyPlayingMusicId = -1;
					ChangeDisplayedMusicTitle("beep block skyway");
				}
			}
			else if(musicId >= 0)
			{
				var musicToPlay:Music = m_characterMusic[musicId];
				if(musicToPlay != null)
				{
					if(m_currentlyPlayingMusicId == musicId) //same song
					{
					}
					else if(m_currentlyPlayingMusicId != musicId) //different song
					{
						if(m_currentlyPlayingMusicId > -1)
						{
							if(m_characterMusic[m_currentlyPlayingMusicId] == musicToPlay)
							{
								m_currentlyPlayingMusicId = musicId;
								return;
							}
						}
						if(abruptChangeFrameOffset > 0)
						{
							if(m_mainSoundChannel != null && m_currentlyPlayingMusicId > -1)
							{
								//currently playing sound channel needs to be passed into the sync s. channel vector
								ControlCharacterMusicVolume(0.0);
								m_syncingSoundChannels[m_currentlyPlayingMusicId] = m_mainSoundChannel;
							}
							if(m_syncingSoundChannels[musicId] == null) //First time switch to a song was an abrupt one
							{
								/*The line below attempts to keep the music synced with the animation in the case of an abrupt character switch.
								abruptChangeFrameOffset(ACFO) has 0.5 taken from it due to the assumption of being mid way into the frame when the switch occured*/
								musicToPlay.SetPlayheadPosition(musicToPlay.GetPlayheadPosition() + (1000.0 / FLASHFRAMERATE) * (Number(abruptChangeFrameOffset) - 0.5));
							}
						}
						else
						{
							if(m_mainSoundChannel != null && m_currentlyPlayingMusicId > -1)
							{
								ControlCharacterMusicVolume(0.0);
								m_mainSoundChannel.stop();
								m_characterMusic[m_currentlyPlayingMusicId].Stop();
								m_mainSoundChannel = null;
							}
						}
						//Check if a sound channel for the desired sound is already available
						if(m_syncingSoundChannels[musicId] != null)
						{
							m_mainSoundChannel = m_syncingSoundChannels[musicId];
							m_syncingSoundChannels[musicId] = null;
							ChangeDisplayedMusicTitle(m_characterMusic[musicId].GetMusicTitle());
						}
						else
						{
							m_mainSoundChannel = musicToPlay.Play();
							ChangeDisplayedMusicTitle(musicToPlay.GetMusicTitle());
						}
						m_currentlyPlayingMusicId = musicId;
						//TODO Strongly consider having bbb.mp3 played via as3 instead of timeline and get rid of the default and character volumes concept
						if(m_currentlyPlayingMusicId > -1)
						{
							ControlCharacterMusicVolume(1.0);
							ControlDefaultMusicVolume(0.0);
						}
						else
						{
							ControlCharacterMusicVolume(0.0);
							ControlDefaultMusicVolume(1.0);
						}
					}
					
				}
			}
		}
		
		//Adjusts the volume of the sound globally.
		public function ControlGlobalVolume(musicVolume:Number):void
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
		
		public function ChangeToNextMusic(currentCharId:int, animationFrame:int):void
		{
			if (m_playGlobalMusic == false)
			{
				if (m_selectedMusicForCharacter[currentCharId] + 1 >= m_characterMusic.length)
				{
					m_selectedMusicForCharacter[currentCharId] = -1;
				}
				else
				{
					++m_selectedMusicForCharacter[currentCharId];
				}
				PlayMusic(currentCharId, animationFrame);
			}
			else
			{
				if (m_globalMusicId + 1 >= m_characterMusic.length)
				{
					m_globalMusicId = -1;
				}
				else
				{
					++m_globalMusicId;
				}
				PlayMusic(m_globalMusicId, animationFrame);
			}
		}
		
		public function ChangeSelectedMusicForCharacter(charId:int, musicId:int):void
		{
			if (m_playGlobalMusic == false)
			{
				m_selectedMusicForCharacter[charId] = musicId;
			}
			else
			{
				m_globalMusicId = musicId;
			}
		}
		
		public function ChangeGlobalMusic(musicId:int):void
		{
			m_globalMusicId = musicId;
		}
		
		public function GetCurrentMusicIdForCharacter(charId:int):int
		{
			return m_selectedMusicForCharacter[charId];
		}
		
		public function GetGlobalCurrentMusicId():int
		{
			return m_globalMusicId;
		}
		
		public function GetMusicIdByTitle(title:String):int
		{
			if (title == DEFAULTSONGTITLE) { return -1;}
			for (var i:int = 0, l:int = m_characterMusic.length; i < l;++i )
			{
				if (title == m_characterMusic[i].GetMusicTitle())
				{
					return i;
				}
			}
			//Didn't find the title, fall back to Beep Block Skyway
			return -1;
		}
		
		public function ChangePlayGlobalSongStatus(status:Boolean):void
		{
			m_playGlobalMusic = status;
		}
		public function GetGlobalSongStatus():Boolean
		{
			return m_playGlobalMusic;
		}
		public function ChangeToPrevMusic(currentCharId:int, animationFrame:int):void
		{
			if (!m_playGlobalMusic)
			{
				if (m_selectedMusicForCharacter[currentCharId] - 1 < -1)
				{
					m_selectedMusicForCharacter[currentCharId] = m_characterMusic.length-1;
				}
				else
				{
					--m_selectedMusicForCharacter[currentCharId];
				}
				PlayMusic(currentCharId, animationFrame);
			}
			else
			{
				if (m_globalMusicId - 1 < -1)
				{
					m_globalMusicId = m_characterMusic.length-1;
				}
				else
				{
					--m_globalMusicId;
				}
				PlayMusic(m_globalMusicId, animationFrame);
			}
		}
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
		public function ControlDefaultMusicVolume(musicVolume:Number):void
		{
			var soundT:SoundTransform = new SoundTransform();
			soundT.volume = musicVolume;
			m_mainMovieClip.soundTransform = soundT;
		}
		
		public function ControlCharacterMusicVolume(musicVolume:Number):void
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
				if(m_currentlyPlayingMusicId >= 0 && m_currentlyPlayingMusicId < m_characterMusic.length)
				{
					titleToUse = m_characterMusic[m_currentlyPlayingMusicId].GetMusicTitle();
				}
				else if (m_currentlyPlayingMusicId == -1)
				{
					titleToUse = "beep block skyway";
				}
				else
				{
					titleToUse = "unknown";
				}
			}
			else 
			{
				titleToUse = "music off";
			}
			ChangeDisplayedMusicTitle(titleToUse, !m_playMusic);
			return IsMusicPlaying();
		}
		//returns whether any music is allowed to be played/heard
		public function IsMusicPlaying() : Boolean
		{
			return m_playMusic;
		}
		/*public function GetPlayCharacterMusicStatus(charId:int):Boolean
		{
			return m_playCharacterMusic[charId];
		}*/
		
		//Changes the text that displays the name of the music playing. By default it can only change when the music is not muted but forceChange can override this behavior
		private function ChangeDisplayedMusicTitle(newMusicTitle:String, forceChange:Boolean=false):void
		{
			if (m_playMusic == true || forceChange == true)
			{
				m_musicInfoDisplay.text = newMusicTitle.toLowerCase();
			}
		}
		
		public function GetCurrentlyPlayingMusicTitle():String
		{
			if (m_currentlyPlayingMusicId < 0 || m_currentlyPlayingMusicId > m_characterMusic.length){return DEFAULTSONGTITLE;}
			return m_characterMusic[m_currentlyPlayingMusicId].GetMusicTitle();
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