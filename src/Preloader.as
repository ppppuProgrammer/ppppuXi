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
	import mx.logging.*;
	/**
	 * ...
	 * @author 
	 */
	public class Preloader extends MovieClip 
	{
		public const MIN_SUPPORTED_FLASH_MAJOR_VER:int = 11;
		public const MIN_SUPPORTED_FLASH_MINOR_VER:int = 2;
		
		private var startupMods:Array = [];
		
		//Loader related
		private var modsListLoader:LoaderMax = new LoaderMax( { name:"ModsListLoader", onComplete:ReadModsList, onError:ModsListLoaderErrorHandler} );
		private var swfPreloader:LoaderMax = new LoaderMax({name:"SWFPreloader", onChildComplete:FinishedLoadingMod, onComplete:LoadingFinished,
			onProgress:Progress, onError:SWFLoaderErrorHandler});
		private const modLoadList:String = "ModsList.txt";
		
		//The logging object for this class
		private var logger:ILogger;
		
		public function Preloader() 
		{
			//Initialize the logger for the program.
			var logWriter:LogWriter = new LogWriter("ppppuXi_Log");
			logWriter.level = LogEventLevel.INFO;
			logWriter.includeDate = true;
			logWriter.includeTime = true;
			logWriter.includeCategory = true;
			logWriter.includeLevel = true;
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
			var majorVer:int = int(playerVersion.substring(playerVersion.indexOf(" ") + 1, majorVerCommaIndex));
			var minorVer:int = int(playerVersion.substring(majorVerCommaIndex + 1, minorVerCommaIndex));
			var osUsed:String = playerVersion.substring(0, 3);
			var mobileDevice:Boolean = (osUsed == "IOS" || osUsed == "AND")?true:false;
			var flashPlayerIsSupported:Boolean = false;
			logger.info("Flash Player Info: Version " + majorVer + "." + minorVer + ", Operating System: " + osUsed);
			
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
				modsListLoader.append(new DataLoader(modLoadList));
				//loaderInfo.addEventListener(ProgressEvent.PROGRESS, Progress);
				//loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOError);
				
				// TODO show loader
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
			else
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
				errorDisplay.text = "Flash Player " + MIN_SUPPORTED_FLASH_MAJOR_VER + "." + MIN_SUPPORTED_FLASH_MINOR_VER +
					" or greater is required to run this flash application. \nYour current Flash Player version is " + majorVer + "." + minorVer +
					"\nPlease update your Flash Player to a supported version and try again.";
				logger.error(errorDisplay.text);
				addChild(errorDisplay);
			}
		}
		
		private function ModsListLoaderErrorHandler(e:LoaderEvent):void 
		{
			//trace(e.text);
			if (e.data is Error)
			{
				logger.error("Error encountered when loading modsList: " + e.data.getStackTrace());
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
				logger.error("Error encountered loading mods: " + e.data.getStackTrace());
			}
			else
			{
				logger.error("Error encountered loading mods: " + e.text);
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
			var mod:Mod = (e.target.content.rawContent as Mod);
			if (mod == null)
			{
				logger.warn(e.target.url + " is not a ppppuXi mod. Content loaded type is " + getQualifiedClassName(e.target.content.rawContent));
			}
			else
			{
				var classType:String = getQualifiedSuperclassName(mod);
				classType = classType.substring(classType.lastIndexOf(":")+1);
				if (mod.GetModType() >= 0)
				{
					logger.info("Successfully loaded " + classType + ": " + getQualifiedClassName(mod));
					addChild(mod);
					startupMods[startupMods.length] = mod;
					removeChild(mod);
				}
				else
				{
					logger.warn(getQualifiedClassName(mod) + " is not a valid mod (Super class is " + classType + ")");
				}
			}
		}
		
		private function ReadModsList(e:LoaderEvent):void
		{
			var listText:String = e.target.content[0] as String;
			//var modsToLoad:Array = [];
			
			var rawSplitStrings:Array = listText.split("\r\n");
			//Feed the mods to load array into the modLoader
			for (var i:int = 0, l:int = rawSplitStrings.length; i < l; ++i)
			{
				var line:String = rawSplitStrings[i] as String;
				if (line.length > 0 && line.charAt(0) != "#")
				{
					//modsToLoad[modsToLoad.length] = rawSplitStrings[i];
					swfPreloader.append(new SWFLoader(rawSplitStrings[i]));
				}
			}
			logger.info("Loaded ModsList.txt (size: " + e.target.bytesLoaded / 1024 + "KB) and found " + swfPreloader.numChildren + " files to load");
			swfPreloader.maxConnections = 1;
			swfPreloader.load();
			
		}
		//Catches any uncaught errors and logs them
		private function PreloaderErrorCatcher(e:UncaughtErrorEvent):void
		{
			logger.error(e.error.getStackTrace());
		}
	}
	
}