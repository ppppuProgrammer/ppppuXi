- ppppuX interactive (ppppuXi) Version 1.0 Read Me -

-- Preface --
ppppuXi is a modified version of minus 8's ppppu flash animation designed to facilitate adding new assets, such as characters and music, which are added through the use of "mod" swf files. The mod system is intended to allow greater customization of ppppu, encourage new content creation, and decouple content from the main program which was causing issues as more and mroe characters were being added. Included in this zip is ppppuXi.swf, the main flash program that should be run by the flash player, and various mods, the 2 original characters done by minus8 and a majority of the others being character mods that were created by GeneralScot, and MusicPack.swf, an archive containing various music that have been included in ppppu edits made by GeneralScot. Also included is a helper program, Xi Log Reader.swf, which will load the log file for ppppuXi and output it onto your screen.

-- Starting up --
Once you've downloaded the zip containing ppppuXi.swf and at least 1 animated character mod, extract the contents of the zips and any other related files into a folder of your choice. Open the modsList.txt to make set any mod content you want enable or disable (more on this in the "How to load mods" section). Now play ppppuXi.swf in a flash player of your choice (such as a web browser or standalone like Adobe's or baka loader).

-- Help --
If there is a feature you don't understand, forgot what keys do what, or perhaps wondering what version of ppppuXi you currently have, hit the help button (default: H) to bring up the help screen and use the next help page button (Default: Z) to see more helpful information.

-- Mods --
Mods are swf files made to contain a specific type of content to be added into ppppuXi. Here is a list of the various types of mods that are accepted by ppppuXi.

Mod Type				Prefix		Description
Animation				ANIM		Adds one or more animations for a specified character.
Music					M			Adds a new song to be played by the music player.
AnimatedCharacter		ACHAR		Adds a new character for with one or more animations.
Archive					ARCH		Contains various mods of any of the above types.

The typically naming format for a mod is (prefix)_(mod name).swf and you can load the mod on its own to get information on its contents (mods created with certain older modding kit versions won't have this information available).

Make sure that you trust the source of a mod before you have it loaded by ppppuXi.	

-- How to load mods --
In order to load a mod, you must edit modsList.txt that's should be in the same directory that ppppuXi.swf is in. This text file is read by ppppuXi during start up initialization to find the location on your filesystem of the mods that you wish to be loaded. Each line should contain the path to the mod to be loaded. Further information can be found in the modsList file.

Here are a few examples on adding a mod depending on where it is in relation to the main swf. For these examples, ppppuXi.swf will be in the directory "C:\ppppuXi\"
Example 1: If the mod "M_testMod.swf" ("C:\ppppuXi\M_testMod.swf") is in the same folder that ppppuXi.swf ("C:\ppppuXi\ppppuXi.swf") is in, edit modsList.txt to contain "M_testMod.swf". 
Example 2: If the mod "M_testMod.swf" is contained within a "MusicMods" folder ("C:\ppppuXi\MusicMods\M_testMod.swf") that's in the same folder that ppppuXi.swf ("C:\ppppuXi\ppppuXi.swf") is in, edit modsList.txt to contain "MusicMods\M_testMod.swf". 

Mods are loaded and processed in order from top to bottom and load order does matter. Animation mods should be listed after Character mods as they will not be loaded if the character they are meant for were not loaded at the time the animation mod is processed. Also the listed placement in modsList.txt for Archive mods should be done with care as they could contain animations that rely on a specific character to be loaded already. Consult the readme or whatever information is available for an archive mod to be aware of what content is within it so you can edit your modsList accordingly.

Also as of version 0.3.5, mp3 files can be loaded the same way you would add a mod and added to the music player as if a music mod was loaded. Music added via mp3 will not have the option to have seamless looping set up though.

-- Creating mods --
If you are interested in creating a mod of your own, you can find the guide on creating them at ppppuProgrammer.tumblr.com/modsGuide. There you can find information on creating them, mod requirements and specifications, tips for the various mod types, and the source files necessary for mod creation.

-- Where to find mods --
You can find mods at the ppppuXi discord group, located at https://discord.gg/zmQx6am. swfchan and the 7chan /fl/ thread are also likely places to find mods by chance.

-- Where are the settings saved? --
ppppuXi makes use of Flash's Shared Objects to save user settings (ppppuXi_Settings.sol) and a log (ppppuXi_Log.sol) containing message pertaining to events that happened during the latest execution of the program. 

!WARNING! Do note that Shared Objects ARE NOT SAVED when playing the flash FROM A BROWSER IN INCOGNITO OR OTHER PRIVATE MODES.

If for some reason you need to clear the user settings or need to send the log file to help track down an issue, here are the directories that the Flash Player stores Shared Objects in:

Operating System				Location

Windows 2000 to 8.1				%APPDATA%/Macromedia/Flash Player/#SharedObjects/
	Chrome on Windows			%localappdata%\Google\Chrome\User Data\Default\Pepper Data\Shockwave Flash\WritableRoot\#SharedObjects
	
Macintosh OS X					~/Library/Preferences/Macromedia/Flash Player/#SharedObjects/
	Chrome on Mac OS X			~/Library/Application Support/Google/Chrome/Default/Pepper Data/Shockwave Flash/WritableRoot/#SharedObjects/
	
Linux/Unix						~/.macromedia/Flash_Player/#SharedObjects/
	Chrome on Linux				~/.config/google-chrome/Default/Pepper Data/Shockwave Flash/WritableRoot/#SharedObjects/

Note: For the Chrome using paths, "Default" refers to the profile name. If the profile you use is not named Default, edit the path to refer to your profile name.

After navigating to the proper directory, enter one of the randomly named folders Flash generates then go into the localhost folder. In this folder you should find "ppppuXi_Settings.sol" and "ppppuXi_Log.sol". If they aren't there something is not allowing the Flash Player to create shared objects. Make sure your Flash player is allowed to save shared objects locally with sufficient file size privilege and that if you play ppppuXi in a browser that it is not in private mode/incognito.

-- Flash Player 23+ Warning --
Due to changes made by Adobe, Flash Player version 23 and higher will no longer allows browsers to have a swf load other local swf files. In order to force local files to be loaded, you must tell Flash Player to trust the folder/files that you wish to be loaded.

For Internet Explorer, Edge, Firefox, Opera and Safari:
On the affected system, go to the Flash Player Settings Manager:
• Mac: System Preferences > Flash Player
• Windows: Control Panel > Flash Player
* Linux (Ubuntu tested solution): Open terminal > enter in the following (without quotes): "flash-player-properties" 
Select the Advanced tab
In the Developer Tools section, click the Trusted Location Settings button
Click the "Add..." button and add relevant files and folders to the list
 
For Google Chrome (and similar PPAPI browsers):
Navigate to the Settings Manager page (http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager02.html)
Choose Edit Locations > Add Locations from the popup list
In the text field that appears, type or paste the file/folder path that you'd like to trust
Click the "Confirm" button

The alternative is to use a stand alone flash projector, here are ones provided by Adobe at https://www.adobe.com/support/flashplayer/debug_downloads.html

-- Bug Reporting --
There is a log created that records various events and errors that happened for the last time the program was ran. If you feel that there was a bug or some other problem, close the flash and DO NOT reopen it. 

For easy access to the log you can run "Xi Log Reader.swf", which will read the contents of the log shared object and output it on the flash player's display. Press space bar to copy the log to your clipboard. From that point you have many options of sending the log to me but I'd prefer if you paste the log contents into a pastebin and link me to the pastebin on the Discord group or my tumblr.

The older method is no longer necessary for logs but still necessary for reporting the settings. Navigate to the folder where the Flash Player saves Shared Objects (The flash Player's "cookie") for ppppuXi and look for "ppppuXi_Log.sol". I'd make a copy of it just to make sure that it won't get overwritten by accident. Upload the Log file somewhere and when you go to report the issue you encountered, include a link to the log to help diagnose the problem. Alternatively, you can use a Shared Object reader with AMF3 capabilities such as those listed here (https://en.wikipedia.org/wiki/Local_shared_object#Editors_and_toolkits) to read the log yourself and include the text from it in your report or a link to a pastebin with the log's contents.

-- Contact --
If you need to contact me to report an issue or send a suggestion (don't ask me to create a character though, I'm not capable of doing this), then you can message me or send me an ask on my tumblr (ppppuProgrammer.tumblr.com), ask on the discord group (https://discord.gg/zmQx6am) or post on the 7chan /fl/ thread (http://7chan.org/fl/res/18154.html at the time of writing)