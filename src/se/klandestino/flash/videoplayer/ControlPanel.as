package se.klandestino.flash.videoplayer {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import se.klandestino.flash.debug.Debug;
	import se.klandestino.flash.net.MultiLoader;
	import se.klandestino.flash.utils.CoordinationTools;
	import se.klandestino.flash.utils.StringUtil;
	import se.klandestino.flash.videoplayer.events.VideoplayerEvent;
	import se.klandestino.flash.videoplayer.Videoplayer;

	/**
	 *	Sprite sub class description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author spurge
	 *	@since  2010-04-02
	 */
	public class ControlPanel extends Sprite {

		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------

		public static const POSITION_BOTTOM:String = 'bottom';
		public static const POSITION_CENTER:String = 'center';
		public static const POSITION_LEFT:String = 'left';
		public static const POSITION_RIGHT:String = 'right';
		public static const POSITION_TOP:String = 'top';
		public static const SETUP_MOUSE:String = 'mouse';
		public static const SETUP_PAUSE:String = 'pause';
		public static const SETUP_PLAY:String = 'play';
		public static const SHOW_ALWAYS:String = 'always';
		public static const SHOW_MOUSE:String = 'mouse';
		public static const SHOW_PAUSE:String = 'pause';
		public static const SHOW_PLAY:String = 'play';

		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------

		/**
		 *	@constructor
		 */
		public function ControlPanel () {
			super ();
			this.visible = false;
			this.loader = new MultiLoader ();
			this.loader.addEventListener (Event.COMPLETE, this.loaderCompleteHandler, false, 0, true);
		}

		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------

		private var _currentSetup:String = ControlPanel.SETUP_PAUSE;
		private var loader:MultiLoader;
		private var pausebutton:Object;
		private var playbutton:Object;
		private var _videoplayer:Videoplayer;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------

		public function get currentSetup ():String {
			return this._currentSetup;
		}

		public function get videoplayer ():Videoplayer {
			return this._videoplayer;
		}

		public function set videoplayer (videoplayer:Videoplayer):void {
			if (this._videoplayer != null) {
				this._videoplayer.removeEventListener (Event.ENTER_FRAME, this.videoEnterFrameHandler);
				this._videoplayer.removeEventListener (Event.RESIZE, this.videoResizeHandler);
				this._videoplayer.removeEventListener (VideoplayerEvent.LOADED, this.videoLoadedHandler);
				this._videoplayer.removeEventListener (VideoplayerEvent.PAUSE, this.videoPauseHandler);
				this._videoplayer.removeEventListener (VideoplayerEvent.PLAY, this.videoPlayHandler);
				this._videoplayer.removeEventListener (VideoplayerEvent.RESUME, this.videoResumeHandler);
				this._videoplayer.removeEventListener (VideoplayerEvent.STOP, this.videoStopHandler);
			}

			this._videoplayer = videoplayer;
			this._videoplayer.addEventListener (Event.ENTER_FRAME, this.videoEnterFrameHandler, false, 0, true);
			this._videoplayer.addEventListener (Event.RESIZE, this.videoResizeHandler, false, 0, true);
			this._videoplayer.addEventListener (VideoplayerEvent.LOADED, this.videoLoadedHandler, false, 0, true);
			this._videoplayer.addEventListener (VideoplayerEvent.PAUSE, this.videoPauseHandler, false, 0, true);
			this._videoplayer.addEventListener (VideoplayerEvent.PLAY, this.videoPlayHandler, false, 0, true);
			this._videoplayer.addEventListener (VideoplayerEvent.RESUME, this.videoResumeHandler, false, 0, true);
			this._videoplayer.addEventListener (VideoplayerEvent.STOP, this.videoStopHandler, false, 0, true);

			if (this.videoplayer.loaded) {
				this.visible = true;
			}
		}

		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		public function init ():void {
			this.loader.load ();
		}

		public function setup (setup:String):void {
			Debug.debug ('Settng up control panel to ' + setup);

			switch (setup) {
				case ControlPanel.SETUP_MOUSE:
					this._currentSetup = ControlPanel.SETUP_MOUSE;
					break;
				case ControlPanel.SETUP_PAUSE:
					this._currentSetup = ControlPanel.SETUP_PAUSE;
					break;
				case ControlPanel.SETUP_PLAY:
					this._currentSetup = ControlPanel.SETUP_PLAY;
					break;
				default:
					Debug.warn ('There is no setup with name ' + setup);
					return;
			}

			this.setupButton (this.pausebutton);
			this.setupButton (this.playbutton);
		}

		public function setPauseButton (url:String, params:Object = null):void {
			Debug.debug ('Setting pause button to ' + url);
			this.hideButton (this.pausebutton);
			this.pausebutton = new Object ();
			this.pausebutton.url = url;
			this.pausebutton.show = params ? (params.show ? params.show : ControlPanel.SHOW_MOUSE) : ControlPanel.SHOW_MOUSE;
			this.pausebutton.hide = params ? (params.hide ? params.hide : ControlPanel.SHOW_PLAY) : ControlPanel.SHOW_PLAY;
			this.pausebutton.x = params ? (params.x ? params.x : '') : '';
			this.pausebutton.y = params ? (params.y ? params.y : '') : '';
			this.pausebutton.sprite = new Sprite ();
			this.addChild (this.pausebutton.sprite);

			this.loader.add (this.pausebutton.url, 'pause', this.pausebutton.sprite);
		}

		public function setPlayButton (url:String, params:Object = null):void {
			Debug.debug ('Setting play button to ' + url);
			this.hideButton (this.playbutton);
			this.playbutton = new Object ();
			this.playbutton.url = url;
			this.playbutton.show = params ? (params.show ? params.show : ControlPanel.SHOW_PAUSE) : ControlPanel.SHOW_PAUSE;
			this.playbutton.hide = params ? (params.hide ? params.hide : '') : '';
			this.playbutton.x = params ? (params.x ? params.x : '') : '';
			this.playbutton.y = params ? (params.y ? params.y : '') : '';
			this.playbutton.sprite = new Sprite ();
			this.addChild (this.playbutton.sprite);

			this.loader.add (this.playbutton.url, 'play', this.playbutton.sprite);
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		private function buttonClickHandler (event:MouseEvent):void {
			if (this.pausebutton != null && this.videoplayer != null) {
				if (event.target === this.pausebutton.sprite) {
					Debug.debug ('Pause button clicked');
					this.videoplayer.pause ();
				}
			}

			if (this.playbutton != null && this.videoplayer != null) {
				if (event.target === this.playbutton.sprite) {
					Debug.debug ('Play button clicked');
					this.videoplayer.resume ();
				}
			}
		}

		private function loaderCompleteHandler (event:Event):void {
			Debug.debug ('Loading buttons complete');
			this.setup (this.currentSetup);
		}

		private function videoEnterFrameHandler (event:Event):void {
			/*var point:Point = CoordinationTools.localToLocal (this.videoplayer, this);
			this.x = point.x;
			this.y = point.y;*/
		}

		private function videoLoadedHandler (event:VideoplayerEvent):void {
			Debug.debug ('Handling loaded event from video');
			this.visible = true;
		}

		private function videoPauseHandler (event:VideoplayerEvent):void {
			Debug.debug ('Handling pause event from video');
			this.setup (ControlPanel.SETUP_PAUSE);
		}

		private function videoPlayHandler (event:VideoplayerEvent):void {
			Debug.debug ('Handling play event from video');
			this.setup (ControlPanel.SETUP_PLAY);
		}

		private function videoResizeHandler (event:Event):void {
			Debug.debug ('Handling resize event from video ' + this.videoplayer.width + 'x' + this.videoplayer.height);
			this.setup (this.currentSetup);
		}

		private function videoResumeHandler (event:VideoplayerEvent):void {
			Debug.debug ('Handling resume event from video');
			this.setup (ControlPanel.SETUP_PLAY);
		}

		private function videoStopHandler (event:VideoplayerEvent):void {
			Debug.debug ('Handling pause event from video');
			this.setup (ControlPanel.SETUP_PAUSE);
		}

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		private function hideButton (button:Object):void {
			if (button != null) {
				button.sprite.removeEventListener (MouseEvent.CLICK, this.buttonClickHandler);
				button.sprite.visible = false;
			}
		}

		private function showButton (button:Object):void {
			button.sprite.mouseChildren = false;
			button.sprite.buttonMode = true;
			button.sprite.addEventListener (MouseEvent.CLICK, this.buttonClickHandler, false, 0, true);
			this.setupButtonPositions (button);
			button.sprite.visible = true;
		}

		private function setupButton (button:Object):void {
			if (button != null) {
				switch (this.currentSetup) {
					case ControlPanel.SETUP_MOUSE:
						if (button.hide == ControlPanel.SHOW_MOUSE) {
							this.hideButton (button);
						} else if (button.show == ControlPanel.SHOW_MOUSE || button.show == ControlPanel.SHOW_ALWAYS) {
							this.showButton (button);
						} else {
							this.hideButton (button);
						}
						break;
					case ControlPanel.SETUP_PAUSE:
						if (button.hide == ControlPanel.SHOW_PAUSE) {
							this.hideButton (button);
						} else if (button.show == ControlPanel.SHOW_PAUSE || button.show == ControlPanel.SHOW_ALWAYS) {
							this.showButton (button);
						} else {
							this.hideButton (button);
						}
						break;
					case ControlPanel.SETUP_PLAY:
						if (button.hide == ControlPanel.SHOW_PLAY) {
							this.hideButton (button);
						} else if (button.show == ControlPanel.SHOW_PLAY || button.show == ControlPanel.SHOW_ALWAYS) {
							this.showButton (button);
						} else {
							this.hideButton (button);
						}
						break;
				}
			}
		}

		private function setupButtonPositions (button:Object):void {
			if (button != null && this.videoplayer) {
				var x:Number = (this.videoplayer.width - button.sprite.width) / 2;
				var y:Number = (this.videoplayer.height - button.sprite.height) / 2;

				if (!StringUtil.isEmpty (button.x)) {
					if (!isNaN (parseFloat (button.x))) {
						x = parseFloat (button.x);
					} else {
						switch (button.x) {
							case ControlPanel.POSITION_LEFT:
								x = 0;
								break;
							case ControlPanel.POSITION_RIGHT:
								x = this.videoplayer.width - button.sprite.width;
								break;
							default:
								Debug.warn ('There x is no position by value ' + button.x);
						}
					}
				}

				if (!StringUtil.isEmpty (button.y)) {
					if (!isNaN (parseFloat (button.y))) {
						y = parseFloat (button.y);
					} else {
						switch (button.y) {
							case ControlPanel.POSITION_BOTTOM:
								y = this.videoplayer.height - button.sprite.height;;
								break;
							case ControlPanel.POSITION_TOP:
								y = 0;
								break;
							default:
								Debug.warn ('There y is no position by value ' + button.x);
						}
					}
				}

				Debug.debug ('Setting up button positions to ' + x + 'x' + y);

				button.sprite.x = x;
				button.sprite.y = y;
			}
		}

	}
}