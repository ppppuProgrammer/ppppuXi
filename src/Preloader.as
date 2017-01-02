package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.media.Sound;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.system.Capabilities;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import logging.LogWriter;
	import modifications.Mod;
	import com.greensock.loading.*;
	import com.greensock.events.LoaderEvent;
	import modifications.MusicMod;
	import mx.logging.*;
	/**
	 * The entry way into the program. First checks that the Flash Player version can support
	 * the program then it reads the ModsList text file to know what mods to load.
	 * @author 
	 */
	public class Preloader extends MovieClip 
	{
		public const MIN_SUPPORTED_FLASH_MAJOR_VER:int = 11;
		public const MIN_SUPPORTED_FLASH_MINOR_VER:int = 8;
		
		private var startupMods:Array = [];
		
		//Loader related
		private var modsListLoader:LoaderMax = new LoaderMax( { name:"ModsListLoader", onComplete:ReadModsList, onError:ModsListLoaderErrorHandler} );
		private var swfPreloader:LoaderMax = new LoaderMax({name:"SWFPreloader", onChildComplete:FinishedLoadingMod, onComplete:LoadingFinished,
			onProgress:Progress, onError:SWFLoaderErrorHandler } );
			
		CONFIG::release
		private const modLoadList:String = "ModsList.txt" ;
		
		CONFIG::debug
		private const modLoadList:String = "DebugModsList.txt" ;
		
		private var majorVer:int;
		private var minorVer:int;
		
		//The logging object for this class
		private var logger:ILogger;

		//private const appDirectory:String = root.loaderInfo.loaderURL;
		public function Preloader() 
		{
			//Initialize the logger for the program.
			var logWriter:LogWriter = new LogWriter("ppppuXi_Log");
			if (Capabilities.isDebugger)
			{
				//Have the logger record up to debug level messages (essentially all messages).
				logWriter.level = LogEventLevel.DEBUG;
			}
			else
			{
				//Have the logger only record up to Info level messages.
				logWriter.level = LogEventLevel.INFO;
			}
			logWriter.includeDate = true;
			logWriter.includeTime = true;
			logWriter.includeCategory = true;
			logWriter.includeLevel = true;
			logWriter.outputTraceWhenDebugging = false;
			Log.addTarget(logWriter);
			
			//Create the logger object that's used by this class to output messages.
			logger = Log.getLogger("Preloader");
			//Preliminary start up message detailing what version of the program this is.
			logger.info("ppppuXi Beta Version " + Version.VERSION + " Build " + Version.BUILDNUMBER + " Build Date: " + Version.BUILDDATE);
			
			//Allow any errors not caught by an event handler to be caught so they can be logged.
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, PreloaderErrorCatcher, false, 0);
			
			if (stage) {
				//stage.scaleMode = StageScaleMode.NO_SCALE;
				//stage.align = StageAlign.TOP_LEFT;
			}
			var playerVersion:String = Capabilities.version;
			var majorVerCommaIndex:int = playerVersion.indexOf(",");
			var minorVerCommaIndex:int = playerVersion.indexOf(",", majorVerCommaIndex + 1);
			//Set the variables for flash version
			majorVer = int(playerVersion.substring(playerVersion.indexOf(" ") + 1, majorVerCommaIndex));
			minorVer = int(playerVersion.substring(majorVerCommaIndex + 1, minorVerCommaIndex));
			var osUsed:String = playerVersion.substring(0, 3);
			//if (osUsed != "WIN") { txtFilelineEnding = "\n";}
			var mobileDevice:Boolean = (osUsed == "IOS" || osUsed == "AND")?true:false;
			var flashPlayerIsSupported:Boolean = false;
			logger.info("Flash Player Info: Version " + majorVer + "." + minorVer + ", Operating System: " + osUsed);
			logger.info("Application URL: " + root.loaderInfo.loaderURL);
			
			if (mobileDevice == false)
			{
				if (majorVer > MIN_SUPPORTED_FLASH_MAJOR_VER)
				{
					flashPlayerIsSupported = true;
				}
				else if (majorVer == MIN_SUPPORTED_FLASH_MAJOR_VER)
				{
					if (minorVer >= MIN_SUPPORTED_FLASH_MINOR_VER)
					{
						flashPlayerIsSupported = true;
					}
				}
			}
			else
			{
				//Mobile seems to be fine with FP versions before 11.2 since right click code hasn't caused errors for its users.
				flashPlayerIsSupported = true;
			}
			
			if(flashPlayerIsSupported)
			{
				addEventListener(Event.ENTER_FRAME, CheckFrame);
				modsListLoader.autoLoad = true;
				try
				{
					modsListLoader.append(new DataLoader(modLoadList));
					mouseEnabled = false;
					//Add background
					var preloaderBackground:MovieClip = new PlanetBackground();
					preloaderBackground.x = (stage.stageWidth - 480)/2;
					addChild(preloaderBackground);
					var loadBorder:LoadBarBorder = new LoadBarBorder();
					var loadBar:LoadBar = new LoadBar();
					loadBorder.x = loadBar.x = (preloaderBackground.x + 132.5);
					loadBorder.y = loadBar.y = 360;
					addChild(loadBorder);
					addChild(loadBar);
				}
				catch (e:SecurityError)
				{
					logger.error(e.message + "\n" + e.getStackTrace());
					if (e.errorID == 2148 && majorVer >= 23)
					{
						var fp23ErrorMsg:String = "Changes by Adobe have caused Flash Player 23 and higher to no longer allow a flash application, when played in a browser, to load other files. ppppuXi is reliant on being able to load files to start. Please consult the \"Flash Player 23+ Warning\" section of the Readme file for the solution to this issue.";
						StopPreloaderAndDisplayErrorMessage(fp23ErrorMsg);
					}
				}	
			}
			else
			{
				var notSupportedFPmsg:String = "Flash Player " + MIN_SUPPORTED_FLASH_MAJOR_VER + "." + MIN_SUPPORTED_FLASH_MINOR_VER +
					" or greater is required to run this flash application. \nYour current Flash Player version is " + majorVer + "." + minorVer +
					"\nPlease update your Flash Player to a supported version and try again.";
				StopPreloaderAndDisplayErrorMessage(notSupportedFPmsg);
			}
		}
		
		private function ModsListLoaderErrorHandler(e:LoaderEvent):void 
		{
			//trace(e.text);
			if (e.data is Error)
			{
				logger.error("Error encountered when loading modsList: " + e.data.message + "\n" + e.data.getStackTrace());
			}
			else
			{
				logger.error("Error encountered loading modsList: " + e.text);
			}
		}
		
		private function SWFLoaderErrorHandler(e:LoaderEvent):void 
		{
			//trace(e.text);
			if (e.data is Error)
			{
				logger.error("Error encountered loading mods: " + e.data.message + "\n" + e.data.getStackTrace());
			}
			else
			{
				logger.error("Error encountered loading mods" + (e.data.errorID == 2032 ? ", a file was not found. Full error message: " : ": ") + e.text);
			}
		}
		
		private function Progress(e:LoaderEvent):void 
		{
			// TODO update loader
			//var loaded:uint = e.targetloaderInfo.bytesLoaded;
			//var total:uint = loaderInfo.bytesTotal;
			(getChildAt(this.numChildren - 1)).scaleX = e.target.progress;
			//var percentLoaded:Number = Math.floor((loaded / total) * 100);
			//var percentLoaded:Number =  loaded / total;
		}
		
		private function CheckFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				stop();
				//LoadingFinished(null);
			}
		}
		
		private function LoadingFinished(e:LoaderEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, CheckFrame);
			swfPreloader.removeEventListener(LoaderEvent.PROGRESS, Progress);
			logger.info("Finished loading all mods");
			//loaderInfo.removeEventListener(ProgressEvent.PROGRESS, Progress);
			//loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, IOError);
			
			// TODO hide loader
			removeChildren();
			Startup();
		}
		
		private function Startup():void 
		{
			var main:Main = new Main();
			//var mainClass:Class = getDefinitionByName("Main") as Class;
			//var main:mainClass = new mainClass();
			if (startupMods.length > 0)
			{
				main.SetModsContent(startupMods);
			}
			/*swfPreloader.dispose();
			modsListLoader.dispose();
			modsListLoader.unload();
			swfPreloader.unload();*/
			modsListLoader.empty(true, true);
			modsListLoader.dispose();
			modsListLoader.unload();
			modsListLoader = null;
			swfPreloader.empty(true, true);
			swfPreloader.dispose();
			swfPreloader.unload();
			swfPreloader = null;
			//Preloader's job is done, so remove the error listener. 
			loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, PreloaderErrorCatcher, false);
			addChild(main as DisplayObject);
		}
		
		private function FinishedLoadingMod(e:LoaderEvent):void
		{
			var mod:Mod;
			//First check if the file is an mp3
			if (e.target is MP3Loader)
			{
				//logger.info("Opening " + e.target.content.url);
				var musicMod:MusicMod = MusicMod.CreateMusicModFromMP3(e.target.content as Sound, (e.target as MP3Loader).url);
				mod = musicMod;
				if (mod != null)
				{
					logger.info("Successfully created music mod from " + e.target.url);
				}
			}
			else
			{
				mod = (e.target.content.rawContent as Mod);
			}
			
			if (mod == null)
			{
				logger.warn(e.target.url + " is not a ppppuXi mod. Content loaded type is " + getQualifiedClassName(e.target.content.rawContent));
			}
			else
			{
				var classType:String = getQualifiedSuperclassName(mod);
				classType = classType.substring(classType.lastIndexOf(":") + 1);
				mod.UrlLoadedFrom = e.target.url;
				if (mod.GetModType() >= 0)
				{
					var modVersion:String = mod.GetModVersion();
					var modLoadedMessage:String;
					if (e.target is SWFLoader)
					{
						modLoadedMessage = "Successfully loaded " + classType + ": " + getQualifiedClassName(mod) + " (" + e.target.url +" ver " + modVersion + ")"
					}
					else if (e.target is MP3Loader && mod.GetModType() == Mod.MOD_MUSIC)
					{
						modLoadedMessage = "Successfully added MusicMod created from " + e.target.url;
					}
					logger.info(modLoadedMessage);
					addChild(mod);
					startupMods[startupMods.length] = mod;
					removeChild(mod);
				}
				else
				{
					logger.warn(getQualifiedClassName(mod) +"(" + e.target.url +")" + " is not a valid mod (Super class is " + classType + ")");
				}
			}
		}
		
		private function ReadModsList(e:LoaderEvent):void
		{
			var listText:String = e.target.content[0] as String;
			//var modsToLoad:Array = [];
			//By default, assume the line ending used is CR LF (Windows)
			var txtFilelineEnding:String="\r\n";
			//Check for the line ending used in the mods list file and then split the contents of it based on the ending.
			if (listText.indexOf("\r") != -1 && listText.indexOf("\n") == -1) { txtFilelineEnding = "\r"; } //CR
		else if	(listText.indexOf("\r") == -1 && listText.indexOf("\n") != -1){txtFilelineEnding = "\n";} //LF
			var rawSplitStrings:Array = listText.split(txtFilelineEnding);
			//Feed the mods to load array into the modLoader
			for (var i:int = 0, l:int = rawSplitStrings.length; i < l; ++i)
			{
				var line:String = rawSplitStrings[i] as String;
				var extensionStart:int = line.lastIndexOf(".");
				if (line.length > 0 && line.charAt(0) != "#")
				{
					if (line.indexOf(".swf", extensionStart) != -1)
					{
					//modsToLoad[modsToLoad.length] = rawSplitStrings[i];
						swfPreloader.append(new SWFLoader(rawSplitStrings[i]));
					}
					else if (line.indexOf(".mp3", extensionStart) != -1)
					{
						swfPreloader.append(new MP3Loader(rawSplitStrings[i]));
					}
				}
			}
			logger.info("Loaded ModsList.txt (size: " + e.target.bytesLoaded / 1024 + "KB) and found " + swfPreloader.numChildren + " files to load");
			logger.info("ModsList contents:\n\n\t"+rawSplitStrings.join("\n\t")/*listText*/+"\n");
			swfPreloader.maxConnections = 1;
			swfPreloader.load();
			
		}
		//Catches any uncaught errors and logs them
		private function PreloaderErrorCatcher(e:UncaughtErrorEvent):void
		{
			logger.error(e.error.message + "\n" + e.error.getStackTrace());
		}
		
		private function StopPreloaderAndDisplayErrorMessage(errorMsg:String):void
		{
			//The flash is not to continue
			stop();
			//Create text field to display the error message
			var errorDisplay:TextField = new TextField();
			errorDisplay.autoSize = TextFieldAutoSize.LEFT;
			var errorTxtFormat:TextFormat = errorDisplay.getTextFormat();
			errorTxtFormat.size = 16;
			errorDisplay.defaultTextFormat=errorTxtFormat;
			errorDisplay.textColor = 0xFFFFFF;
			errorDisplay.text = errorMsg;
			logger.error(errorMsg);
			addChild(errorDisplay);
		}
	}
	
}