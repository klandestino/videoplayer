package se.klandestino.flash.videoplayer.events {
	import flash.events.Event;
	
	/**
	 *	Event subclass description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 10.0
	 *
	 *	@author spurge
	 *	@since  02.04.2010
	 */
	public class VideoplayerEvent extends Event {

		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------

		public static const BUFFER_EMPTY:String = 'buffer empty';
		public static const BUFFER_FULL:String = 'buffer full';
		public static const CONNECTED:String = 'connected';
		public static const LOADED:String = 'loaded';
		public static const PAUSE:String = 'pause';
		public static const PLAY:String = 'play';
		public static const RESUME:String = 'resume';
		public static const STOP:String = 'stop';

		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		/**
		 *	@constructor
		 */
		public function VideoplayerEvent (type:String, bubbles:Boolean = true, cancelable:Boolean = false) {
			super (type, bubbles, cancelable);
		}

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------

		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		override public function clone ():Event {
			return new VideoplayerEvent (type, bubbles, cancelable);
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

	}
}