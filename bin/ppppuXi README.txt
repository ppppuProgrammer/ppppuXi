- ppppuX interactive (ppppuXi) Version 0.3.0 RC4 Read Me -

-- Preface --
ppppuXi is a modified version of minus 8's ppppu flash animation designed to facilitate adding new assets, such as characters and music, which are added through the use of "mod" swf files. The mod system is intended to allow greater customization of ppppu, encourage new content creation, and decouple content from the main program which was causing issues as more and mroe characters were being added. Included in this zip is ppppuXi.swf, the main flash program that should be run by the flash player, and various mods, the majority of which are character mods that were created by GeneralScot, and MusicPack.swf, an archive containing various music that have been included in ppppu edits made by GeneralScot.

-- Help --
If there is a feature you don't understand, forgot what keys do what, or perhaps wondering what version of ppppuXi you currently have, hit the help button (default: H) to bring up the help screen and use the next help page button (Default: Z) to see more helpful information.

-- Mods --
Mods are swf files made to contain a specific type of content to be added into ppppuXi. Here is a list of the various types of mods that are accepted by ppppuXi.

Mod Type				Prefix		Description
Animation				ANIM		Adds one or more animations for a specified character.
Music					M			Adds a new song to be played by the music player.
AnimatedCharacter		ACHAR		Adds a new character for with one or more animations.
Archive					ARCH		Contains various mods of any of the above types.

The typically naming format for a mod is (prefix)_(mod name).swf

Make sure that you trust the source of a mod before you have it loaded by ppppuXi.	

-- How to load mods --
In order to load a mod, you must edit modsList.txt that's should be in the same directory that ppppuXi.swf is in. This text file is read by ppppuXi during start up initialization to find the location on your filesystem of the mods that you wish to be loaded. Each line should contain the path to the mod to be loaded. Further information can be found in the modsList file.

Here are a few examples on adding a mod depending on where it is in relation to the main swf. For these examples, ppppuXi.swf will be in the directory "C:\ppppuXi\"
Example 1: If the mod "M_testMod.swf" ("C:\ppppuXi\M_testMod.swf") is in the same folder that ppppuXi.swf ("C:\ppppuXi\ppppuXi.swf") is in, edit modsList.txt to contain "M_testMod.swf". 
Example 2: If the mod "M_testMod.swf" is contained within a "MusicMods" folder ("C:\ppppuXi\MusicMods\M_testMod.swf") that's in the same folder that ppppuXi.swf ("C:\ppppuXi\ppppuXi.swf") is in, edit modsList.txt to contain "MusicMods\M_testMod.swf". 

Mods are loaded and processed in order from top to bottom and load order does matter. Animation mods should be listed after Character mods as they will not be loaded if the character they are meant for were not loaded at the time the animation mod is processed. Also the listed placement in modsList.txt for Archive mods should be done with care as they could contain animations that rely on a specific character to be loaded already. Consult the readme or whatever information is available for an archive mod to be aware of what content is within it so you can edit your modsList accordingly.

-- Creating mods --
If you are interested in creating a mod of your own, you can find the guide on creating them at ppppuProgrammer.tumblr.com/modsGuide. There you can find information on creating them, mod requirements and specifications, tips for the various mod types, and the source files necessary for mod creation.

-- Where to find mods --
Currently there is no site dedicated for the hosting of mods. swfchan and the 7chan /fl/ thread are the likely places to find a mod.

-- Where are the settings saved? --
ppppuXi makes use of Flash's Shared Objects to save user settings (ppppuXi_Settings.sol) and a log (ppppuXi_Log.sol) containing message pertaining to events that happened during the latest execution of the program. WARNING: Do note that Shared Objects ARE NOT SAVED when playing the flash FROM A BROWSER IN INCOGNITO OR OTHER PRIVATE MODES. If for some reason you need to clear the user settings or need to send the log file to help track down an issue,  here are the directories that the Flash Player stores Shared Objects in:

Operating System				Location

Windows 2000 to 8.1				%APPDATA%/Macromedia/Flash Player/#SharedObjects/
	Chrome on Windows			%localappdata%\Google\Chrome\User Data\Default\Pepper Data\Shockwave Flash\WritableRoot\#SharedObjects
	
Macintosh OS X					~/Library/Preferences/Macromedia/Flash Player/#SharedObjects/
	Chrome on Mac OS X			~/Library/Application Support/Google/Chrome/Default/Pepper Data/Shockwave Flash/WritableRoot/#SharedObjects/
	
Linux/Unix						~/.macromedia/Flash_Player/#SharedObjects/
	Chrome on Linux				~/.config/google-chrome/Default/Pepper Data/Shockwave Flash/WritableRoot/#SharedObjects/

Note: For the Chrome using paths, "Default" refers to the profile name. If the profile you use is not named Default, edit the path to refer to your profile name.


After navigating to the proper directory, enter one of the randomly named folders Flash generates then go into the localhost folder. Enter the ppppuX interactive and enter any folders encountered until you are in the folder with "ppppuXi_Settings.sol" and "ppppuXi_Log.sol".

-- Bug Reporting --
There is a log created that records various events and errors that happened for the last time the program was ran. If you feel that there was a bug or some other problem, close the flash and DO NOT reopen it. Navigate to the folder where the Flash Player saves Shared Objects (The flash Player's "cookie") for ppppuXi and look for "ppppuXi_Log.sol". I'd make a copy of it just to make sure that it won't get overwritten by accident. Upload the Log file somewhere and when you go to report the issue you encountered, include a link to the log to help diagnose the problem. Alternatively, you can use a Shared Object reader with AMF3 capabilities such as those listed here (https://en.wikipedia.org/wiki/Local_shared_object#Editors_and_toolkits) to read the log yourself and include the text from it in your report or a link to a pastebin with the log's contents.

-- Contact --
If you need to contact me to report an issue or send a suggestion (don't ask me to create a character though, I'm not capable of doing this), then you can message me or send me an ask on my tumblr (ppppuProgrammer.tumblr.com) or post on the 7chan /fl/ thread (http://7chan.org/fl/res/18154.html at the time of writing)