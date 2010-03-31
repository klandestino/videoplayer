package {

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import se.klandestino.flash.debug.Debug;
	import se.klandestino.flash.debug.loggers.NullLogger;
	import se.klandestino.flash.debug.loggers.TraceLogger;

	/**
	 *	Sprite sub class description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author spurge
	 *	@since  2010-03-31
	 */
	public class Videoplayer extends Sprite {

		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------

		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		/**
		 *	@constructor
		 */
		public function Videoplayer () {
			super ();

			Debug.addLogger (new TraceLogger ());
			//Debug.addLogger (new NullLogger ());

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.addEventListener (Event.RESIZE, this.init);
		}

		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------

		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		private function init (event:Event = null):void {
			this.stage.removeEventListener (Event.RESIZE, this.init);
		}
	}
}