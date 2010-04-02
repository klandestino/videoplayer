package  {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import se.klandestino.flash.debug.Debug;
	import se.klandestino.flash.debug.loggers.NullLogger;
	import se.klandestino.flash.debug.loggers.TraceLogger;
	import se.klandestino.flash.utils.LoaderInfoParams;
	import se.klandestino.flash.utils.StringUtil;
	import se.klandestino.videoplayer.Videoplayer;

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

		public static const CALLBACK_RESIZE:String = 'resize';

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

			this.getParams ();

			this.videoplayer = new Videoplayer ();
			this.addEventListener (Event.RESIZE, this.videoResizeHandler, true, 0, true);
			this.videoplayer.repeat = this.repeat;
			this.videoplayer.load (this.url);
			this.addChild (this.videoplayer);

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.addEventListener (Event.RESIZE, this.stageResizeHandler, false, 0, true);

			if (this.autoplay) {
				Debug.debug ('Autoplay is true, start playing');
				this.videoplayer.play ();
			} else {
				Debug.debug ('Autoplay is false, waiting for interaction to start playing');
			}

			this.stage.dispatchEvent (new Event (Event.RESIZE));
		}

		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------

		private var autoplay:Boolean = true;
		private var autosize:Boolean = true;
		private var jsCallback:String;
		private var repeat:Boolean = false;
		private var url:String;
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

		private function stageResizeHandler (event:Event):void {
			if (!this.autosize) {
				this.videoplayer.width = this.stage.stageWidth;
				this.videoplayer.height = this.stage.stageHeight;
			}

			this.setupVideoPositions ();
		}

		private function videoResizeHandler (event:Event):void {
			if (this.autosize) {
				Debug.debug ('New size from video and autosize is enabled');
				this.videoplayer.setSizeByVideo ();
				this.sendCallback (Main.CALLBACK_RESIZE, this.videoplayer.videoWidth, this.videoplayer.videoHeight);
			} else {
				Debug.debug ('New size from video but autosize is not enabled');
			}

			this.setupVideoPositions ();
		}

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		private function getParams ():void {
			this.autoplay = LoaderInfoParams.getParam (this.stage.loaderInfo, 'autoplay', this.autoplay);
			this.autosize = LoaderInfoParams.getParam (this.stage.loaderInfo, 'autosize', this.autosize);
			this.jsCallback = LoaderInfoParams.getParam (this.stage.loaderInfo, 'callback', '');
			this.repeat = LoaderInfoParams.getParam (this.stage.loaderInfo, 'repeat', this.repeat);
			this.url = LoaderInfoParams.getParam (this.stage.loaderInfo, 'url', '');
		}

		private function setupVideoPositions ():void {
			this.videoplayer.x = (this.videoplayer.width - this.stage.stageWidth) / 2;
			this.videoplayer.y = (this.videoplayer.height - this.stage.stageHeight) / 2;
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
