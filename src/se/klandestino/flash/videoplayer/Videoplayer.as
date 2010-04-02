package se.klandestino.flash.videoplayer {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import se.klandestino.flash.debug.Debug;
	import se.klandestino.flash.events.NetStreamClientEvent;
	import se.klandestino.flash.net.NetStreamClient;
	import se.klandestino.flash.videoplayer.events.VideoplayerEvent;

	/**
	 *	Sprite sub class description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 10.0
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

			this.postConnectActions = new Array ();
			this.postLoadActions = new Array ();

			this.setupVideo ();
		}

		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------

		private var _buffer:uint = 2;
		private var bufferFull:Boolean = false;
		private var connection:NetConnection;
		private var _duration:Number = 0;
		private var _loaded:Boolean;
		private var playbackStop:Boolean = true;
		private var postConnectActions:Array;
		private var postLoadActions:Array;
		private var preload:Boolean = false;
		private var _repeat:Boolean = false;
		private var stream:NetStream;
		private var streamClient:NetStreamClient;
		private var _url:String = '';
		private var video:Video;
		private var _videoHeight:Number;
		private var _videoWidth:Number;

		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------

		public function get buffer ():uint {
			return this._buffer;
		}

		public function set buffer (val:uint):void {
			this._buffer = val;
		}

		public function get connected ():Boolean {
			if (this.connection != null) {
				return this.connection.connected;
			}

			return false;
		}

		public function get duration ():Number {
			return this._duration;
		}

		override public function get height ():Number {
			return this.video != null ? this.video.height : super.height;
		}

		override public function set height (val:Number):void {
			Debug.debug ('Setting new height for video by ' + width);

			if (this.video != null) {
				this.video.height = val;
			}
		}

		public function get loaded ():Boolean {
			return (this._loaded && this.stream);
		}

		public function get repeat ():Boolean {
			return this._repeat;
		}

		public function set repeat (val:Boolean):void {
			this._repeat = val;
		}

		public function get url ():String {
			return this._url;
		}

		override public function get width ():Number {
			return this.video != null ? this.video.width : super.width;
		}

		override public function set width (val:Number):void {
			Debug.debug ('Setting new width for video by ' + width);

			if (this.video != null) {
				this.video.width = val;
			}
		}

		public function get videoHeight ():Number {
			return this._videoHeight > 0 ? this._videoHeight : this.height;
		}

		public function get videoWidth ():Number {
			return this._videoWidth > 0 ? this._videoWidth : this.width;
		}

		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		public function connect (url:String = null):void {
			Debug.debug ('Connecting to ' + url);

			if (this.connection != null) {
				this.connection.removeEventListener (NetStatusEvent.NET_STATUS, this.connectionStatusHandler);
				this.connection = null;
			}

			this.connection = new NetConnection ();
			this.connection.addEventListener (NetStatusEvent.NET_STATUS, this.connectionStatusHandler, false, 0, true);
			this.connection.connect (url);
		}

		public function load (url:String):void {
			if (this.connection.connected) {
				if (this.url != url) {
					Debug.debug ('Loading new video from ' + url);

					this.unload ();

					this.stream = new NetStream (this.connection);
					this.stream.addEventListener (NetStatusEvent.NET_STATUS, this.streamNetStatusHandler, false, 0, true);
					this.stream.addEventListener (IOErrorEvent.IO_ERROR, this.streamIoErrorHandler, false, 0, true);

					this.streamClient = new NetStreamClient ();
					this.streamClient.addEventListener (NetStreamClientEvent.CUE_POINT, this.streamCuePointHandler, false, 0, true);
					this.streamClient.addEventListener (NetStreamClientEvent.IMAGE_DATA, this.streamImageDataHandler, false, 0, true);
					this.streamClient.addEventListener (NetStreamClientEvent.META, this.streamMetaHandler, false, 0, true);
					this.streamClient.addEventListener (NetStreamClientEvent.PLAY_STATUS, this.streamPlayStatusHandler, false, 0, true);
					this.streamClient.addEventListener (NetStreamClientEvent.TEXT_DATA, this.streamTextDataHandler, false, 0, true);
					this.streamClient.addEventListener (NetStreamClientEvent.XMP_DATA, this.streamXmpDataHandler, false, 0, true);

					this.stream.client = this.streamClient;
					this._url = url;
					this.video.attachNetStream (this.stream);

					this.preload = true;
					this.stream.receiveAudio (false);
					this.stream.receiveVideo (false);
					this.stream.play (url);
				} else {
					Debug.warn ('Already loading/loaded video from ' + url);
				}
			} else {
				this.addPostConnectAction (this.load, url);
			}
		}

		public function play ():void {
			Debug.debug ('Playing video from ' + this.url);

			if (this.loaded) {
				this.stream.seek (0);
				this.stream.resume ();
			} else {
				this.addPostLoadAction (this.play);
			}
		}

		public function pause ():void {
			Debug.debug ('Pausing video from ' + this.url);

			if (this.loaded) {
				this.stream.pause ();
			} else {
				this.addPostLoadAction (this.pause);
			}
		}

		public function resume ():void {
			Debug.debug ('Resuming video from ' + this.url);

			if (this.loaded) {
				this.stream.resume ();
			} else {
				this.addPostLoadAction (this.resume);
			}
		}

		public function seek (sec:uint):void {
			Debug.debug ('Seek by ' + sec);

			if (this.loaded) {
				if (sec < this.duration) {
					this.stream.seek (sec);
				} else {
					Debug.warn (sec + ' is higher than duration ' + this.duration);
				}
			}
		}

		public function stop ():void {
			Debug.debug ('Stopping video from ' + this.url);

			if (this.loaded) {
				this.stream.close ();
			} else {
				this.addPostLoadAction (this.stop);
			}
		}

		public function setSizeByVideo ():void {
			this.width = this.videoWidth;
			this.height = this.videoHeight;
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		private function connectionStatusHandler (event:NetStatusEvent):void {
			Debug.debug (event.info.code);

			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					this.dispatchEvent (new VideoplayerEvent (VideoplayerEvent.CONNECTED));
					this.execPostConnectActions ();
				break;
			}
		}

		private function streamCuePointHandler (event:NetStreamClientEvent):void {
			var data:String = 'Cue Point';

			for (var key:String in event.info) {
				data += "\n" + key + ': ' + event.info [key];
			}

			Debug.debug (data);
		}

		private function streamImageDataHandler (event:NetStreamClientEvent):void {
			var data:String = 'Image Data';

			for (var key:String in event.info) {
				data += "\n" + key + ': ' + event.info [key];
			}

			Debug.debug (data);
		}

		private function streamIoErrorHandler (event:IOErrorEvent):void {
			Debug.error ('I/O Error');
		}

		private function streamMetaHandler (event:NetStreamClientEvent):void {
			var data:String = 'Meta';

			for (var key:String in event.info) {
				data += "\n" + key + ': ' + event.info [key];

				switch (key) {
					case 'duration':
						this._duration = event.info [key];
						break;
					case 'width':
						if (!isNaN (parseInt (event.info [key]))) {
							this._videoWidth = parseInt (event.info [key]);
							Debug.debug ('Width found, setting video width to ' + this._videoWidth);
						} else {
							Debug.warn ('Width found, but not as an integer ' + event.info [key]);
						}
						break;
					case 'height':
						if (!isNaN (parseInt (event.info [key]))) {
							this._videoHeight = parseInt (event.info [key]);
							Debug.debug ('Height found, setting video height to ' + this._videoHeight);
						} else {
							Debug.warn ('Height found, but not as an integer ' + event.info [key]);
						}
						break;
				}
			}

			if (this._videoWidth > 0 && this._videoHeight > 0) {
				Debug.debug ('New size found, dispatch resize event');
				this.dispatchEvent (new Event (Event.RESIZE));
			}

			Debug.debug (data);

			if (this.preload) {
				this.donePreload ();
			}
		}

		private function streamNetStatusHandler (event:NetStatusEvent):void {
			Debug.debug (event.info.code);

			switch (event.info.code) {
				case 'NetStream.Play.Start':
					this.playbackStop = false;
					this.bufferFull = false;
					this.dispatchEvent (new VideoplayerEvent (VideoplayerEvent.PLAY));
					break;

				case 'NetStream.Play.Stop':
					this.playbackStop = true;

					if (this.bufferFull) {
						Debug.debug ('Still data in buffer, waiting to stop until buffer is empty');
					} else if (this.buffer > this.duration) {
						Debug.debug ('Buffer (' + this.buffer + ') is longer than duration (' + this.duration + ')');
						if (this.repeat) {
							Debug.debug ('Repeating');
							this.seek (0);
						} else {
							this.stop ();
							this.dispatchEvent (new VideoplayerEvent (VideoplayerEvent.STOP));
						}
					}

					break;
				case 'NetStream.Buffer.Empty':
					this.bufferFull = false;

					if (this.playbackStop) {
						if (this.repeat) {
							Debug.debug ('Playback stopped, repeating playback');
							this.playbackStop = false;
							this.seek (0);
						} else {
							Debug.debug ('Playback stopped, stopping playback');
							this.stop ();
							this.dispatchEvent (new VideoplayerEvent (VideoplayerEvent.STOP));
						}
					} else {
						this.dispatchEvent (new VideoplayerEvent (VideoplayerEvent.BUFFER_EMPTY));
					}
					break;
				case 'NetStream.Buffer.Full':
					this.bufferFull = true;
					this.dispatchEvent (new VideoplayerEvent (VideoplayerEvent.BUFFER_FULL));
					break;
				case 'NetStream.Play.FileStructureInvalid':
					//
					break;
			}
		}

		private function streamPlayStatusHandler (event:NetStreamClientEvent):void {
			var data:String = 'Play Status';

			for (var key:String in event.info) {
				data += "\n" + key + ': ' + event.info [key];
			}

			Debug.debug (data);
		}

		private function streamTextDataHandler (event:NetStreamClientEvent):void {
			var data:String = 'Text Data';

			for (var key:String in event.info) {
				data += "\n" + key + ': ' + event.info [key];
			}

			Debug.debug (data);
		}

		private function streamXmpDataHandler (event:NetStreamClientEvent):void {
			var data:String = 'XMP Data';

			for (var key:String in event.info) {
				data += "\n" + key + ': ' + event.info [key];
			}

			Debug.debug (data);
		}

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		private function setupVideo ():void {
			if (this.video == null) {
				this.video = new Video ();
				this.addChild (this.video);
			}
		}

		private function unload ():void {
			if (this.loaded) {
				this.stop ();

				this.streamClient.removeEventListener (NetStreamClientEvent.CUE_POINT, this.streamCuePointHandler);
				this.streamClient.removeEventListener (NetStreamClientEvent.IMAGE_DATA, this.streamImageDataHandler);
				this.streamClient.removeEventListener (NetStreamClientEvent.META, this.streamMetaHandler);
				this.streamClient.removeEventListener (NetStreamClientEvent.PLAY_STATUS, this.streamPlayStatusHandler);
				this.streamClient.removeEventListener (NetStreamClientEvent.TEXT_DATA, this.streamTextDataHandler);
				this.streamClient.removeEventListener (NetStreamClientEvent.XMP_DATA, this.streamXmpDataHandler);

				this.streamClient = null;
				this.stream = null;
			}
		}

		private function donePreload ():void {
			Debug.debug ('Preloading, meta data found, pausing stream');
			this.preload = false;
			this.stream.receiveAudio (true);
			this.stream.receiveVideo (true);
			this.stream.pause ();
			this.stream.seek (0);
			this._loaded = true;
			this.dispatchEvent (new VideoplayerEvent (VideoplayerEvent.LOADED));
			this.execPostLoadActions ();
		}

		private function addPostConnectAction (func:Function, ... args):void {
			this.postConnectActions.push ({func: func, args: args});
		}

		private function addPostLoadAction (func:Function, ... args):void {
			this.postLoadActions.push ({func: func, args: args});
		}

		private function execPostConnectActions ():void {
			for (var i:int = 0, l:int = this.postConnectActions.length; i < l; i++) {
				if (this.postConnectActions [i].args.length > 0) {
					this.postConnectActions [i].func (this.postConnectActions [i].args);
				} else {
					this.postConnectActions [i].func ();
				}
			}

			this.postConnectActions = new Array ();
		}

		private function execPostLoadActions ():void {
			for (var i:int = 0, l:int = this.postLoadActions.length; i < l; i++) {
				if (this.postLoadActions [i].args.length > 0) {
					this.postLoadActions [i].func (this.postLoadActions [i].args);
				} else {
					this.postLoadActions [i].func ();
				}
			}

			this.postLoadActions = new Array ();
		}

	}
}