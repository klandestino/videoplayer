package  {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import se.klandestino.flash.debug.Debug;
	import se.klandestino.flash.debug.loggers.NullLogger;
	import se.klandestino.flash.debug.loggers.TraceLogger;
	import se.klandestino.flash.utils.LoaderInfoParams;
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
			this.videoplayer.repeat = this.repeat;
			this.videoplayer.load (this.url);
			this.addChild (this.videoplayer);

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.addEventListener (Event.RESIZE, this.stageResizeHandler, false, 0, true);
			this.stage.dispatchEvent (new Event (Event.RESIZE));

			if (this.autoplay) {
				Debug.debug ('Autoplay is true, start playing');
				this.videoplayer.play ();
			} else {
				Debug.debug ('Autoplay is false, waiting for interaction to start playing');
			}
		}

		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------

		private var autoplay:Boolean = true;
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
			this.videoplayer.resize (this.stage.stageWidth, this.stage.stageHeight);
		}

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		private function getParams ():void {
			this.autoplay = LoaderInfoParams.getParam (this.stage.loaderInfo, 'autoplay', this.autoplay);
			this.repeat = LoaderInfoParams.getParam (this.stage.loaderInfo, 'repeat', this.repeat);
			this.url = LoaderInfoParams.getParam (this.stage.loaderInfo, 'url', '');
		}

	}
}
