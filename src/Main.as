package  {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import se.klandestino.flash.config.ConfigLoader;
	import se.klandestino.flash.debug.Debug;
	import se.klandestino.flash.debug.loggers.NullLogger;
	import se.klandestino.flash.debug.loggers.TraceLogger;
	import se.klandestino.flash.utils.LoaderInfoParams;
	import se.klandestino.flash.utils.StringUtil;
	import se.klandestino.flash.videoplayer.ControlPanel;
	import se.klandestino.flash.videoplayer.events.VideoplayerEvent;
	import se.klandestino.flash.videoplayer.Videoplayer;

	/**
	 *	Sprite sub class description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 10.0
	 *
	 *	@author spurge
	 *	@since  2010-04-01
	 */
	public class Main extends Sprite {

		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------

		[Embed(source="../assets/loader.swf")]
		private var loaderMovieClass:Class;

		public static const CALLBACK_RESIZE:String = 'resize';
		public static const CONFIG_XML_FILE:String = 'videoplayer.xml';
		public static const CONFIG_ZIP_FILE:String = 'videplayer.zip';

		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		/**
		 *	@constructor
		 */
		public function Main () {
			super ();

			Debug.addLogger (new TraceLogger ());
			//Debug.addLogger (new NullLogger ());

			this.loadConfig ();

			this.videoplayer = new Videoplayer ();
			this.videoplayer.addEventListener (Event.RESIZE, this.videoResizeHandler, false, 0, true);
			this.videoplayer.addEventListener (VideoplayerEvent.BUFFER_EMPTY, this.videoBufferEmptyHandler, false, 0, true);
			this.videoplayer.addEventListener (VideoplayerEvent.BUFFER_FULL, this.videoBufferFullHandler, false, 0, true);
			this.videoplayer.addEventListener (VideoplayerEvent.LOADED, this.videoLoadedHandler, false, 0, true);
			this.addChild (this.videoplayer);

			if (!this.videoplayer.loaded) {
				this.setupLoader ();
			}

			this.controlpanel = new ControlPanel ();
			this.controlpanel.videoplayer = this.videoplayer;
			this.addChild (this.controlpanel);

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.addEventListener (Event.RESIZE, this.stageResizeHandler, false, 0, true);

			this.stage.dispatchEvent (new Event (Event.RESIZE));
		}

		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------

		private var autoplay:Boolean = true;
		private var autosize:Boolean = true;
		private var config:ConfigLoader;
		private var controlpanel:ControlPanel;
		private var jsCallback:String = '';
		private var loader:Sprite;
		private var repeat:Boolean = false;
		private var rmtp:String = '';
		private var url:String = '';
		private var videoplayer:Videoplayer;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------

		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		private function configCompleteHandler (event:Event):void {
			Debug.debug ('Config file loaded, adding params to config object');
			this.setParamsToConfig ();
			this.start ();
		}

		private function configErrorHandler (event:Event):void {
			Debug.warn ('Error while loading config file, adding params to config object');
			this.setParamsToConfig ();
			this.start ();
		}

		private function stageResizeHandler (event:Event):void {
			if (!this.autosize) {
				this.videoplayer.width = this.stage.stageWidth;
				this.videoplayer.height = this.stage.stageHeight;
			}

			this.setupVideoPositions ();
			this.setupLoaderPositions ();
		}

		private function videoBufferEmptyHandler (event:VideoplayerEvent):void {
			Debug.debug ('Buffer empty, setting up loader');
			this.setupLoader ();
		}

		private function videoBufferFullHandler (event:VideoplayerEvent):void {
			Debug.debug ('Buffer full, removing loader');
			this.removeLoader ();
		}

		private function videoLoadedHandler (event:VideoplayerEvent):void {
			Debug.debug ('Video loaded, removing loader');
			this.removeLoader ();
		}

		private function videoResizeHandler (event:Event):void {
			if (this.autosize) {
				Debug.debug ('New size from video and autosize is enabled');
				this.sendCallback (Main.CALLBACK_RESIZE, this.videoplayer.videoWidth, this.videoplayer.videoHeight);
			} else {
				Debug.debug ('New size from video but autosize is not enabled');
			}

			this.setupVideoPositions ();
			this.setupLoaderPositions ();
		}

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		private function start ():void {
			this.videoplayer.repeat = this.repeat;
			this.videoplayer.connect (StringUtil.isEmpty (this.rmtp) ? null : this.rmtp);
			this.videoplayer.load (this.url);

			if (this.autoplay) {
				Debug.debug ('Autoplay is true, start playing');
				this.videoplayer.play ();
			} else {
				Debug.debug ('Autoplay is false, waiting for interaction to start playing');
			}
		}

		private function loadConfig ():void {
			if (this.config == null) {
				this.config = new ConfigLoader ();
				this.config.addEventListener (Event.COMPLETE, this.configCompleteHandler, false, 0, true);
				this.config.addEventListener (ErrorEvent.ERROR, this.configErrorHandler, false, 0, true);

				var config:String = LoaderInfoParams.getParam (this.stage.loaderInfo, 'config', '');

				if (!StringUtil.isEmpty (config)) {
					this.config.load (config);
				} else {
					this.config.load (Main.CONFIG_XML_FILE);
				}
			}
		}

		private function setParamsToConfig ():void {
			this.autoplay = LoaderInfoParams.getParam (this.stage.loaderInfo, 'autoplay', this.config.getData ('autoplay.value', this.autoplay));
			this.autosize = LoaderInfoParams.getParam (this.stage.loaderInfo, 'autosize', this.config.getData ('autosize.value', this.autosize));
			this.jsCallback = LoaderInfoParams.getParam (this.stage.loaderInfo, 'callback', this.jsCallback);
			this.repeat = LoaderInfoParams.getParam (this.stage.loaderInfo, 'repeat', this.config.getData ('repeat.value', this.repeat));
			this.rmtp = LoaderInfoParams.getParam (this.stage.loaderInfo, 'rmtp', this.config.getData ('rmtp.value', this.rmtp));
			this.url = LoaderInfoParams.getParam (this.stage.loaderInfo, 'url', this.url);

			this.videoplayer.autosize = this.autosize;

			this.controlpanel.setPlayButton (this.config.getData ('panel.play.src', ''), {
				show: this.config.getData ('panel.play.show', ''),
				hide: this.config.getData ('panel.play.hide', ''),
				x: this.config.getData ('panel.play.x', ''),
				y: this.config.getData ('panel.play.y', '')
			});

			this.controlpanel.setPauseButton (this.config.getData ('panel.pause.src', ''), {
				show: this.config.getData ('panel.pause.show', ''),
				hide: this.config.getData ('panel.pause.hide', ''),
				x: this.config.getData ('panel.pause.x', ''),
				y: this.config.getData ('panel.pause.y', '')
			});

			this.controlpanel.init ();
		}

		private function setupVideoPositions ():void {
			this.videoplayer.x = (this.videoplayer.width - this.stage.stageWidth) / 2;
			this.videoplayer.y = (this.videoplayer.height - this.stage.stageHeight) / 2;
		}

		private function setupLoader ():void {
			if (this.loader == null) {
				this.loader = Sprite (new loaderMovieClass ());
			}

			/*if (this.loader.parent != null) {
				this.removeChild (this.loader);
			}*/

			this.loader.visible = true;
			this.setupLoaderPositions ();

			if (this.loader.parent == null) {
				this.addChild (this.loader);
			}
		}

		private function setupLoaderPositions ():void {
			if (this.loader != null) {
				this.loader.x = (this.stage.stageWidth - this.loader.width) / 2;
				this.loader.y = (this.stage.stageHeight - this.loader.height) / 2;
			}
		}

		private function removeLoader ():void {
			if (this.loader != null) {
				/*if (this.loader.parent != null) {
					this.removeChild (this.loader);
				}*/
				this.loader.visible = false;
			}
		}

		private function sendCallback (type:String, ... args):void {
			if (!(StringUtil.isEmpty (this.jsCallback))) {
				Debug.debug ('Calling ' + this.jsCallback + ' as javascript callback with type ' + type);
				ExternalInterface.call (this.jsCallback, type, args);
			} else {
				Debug.debug ('No javascript callback to call to');
			}
		}

	}
}
