var videoplayer = {
	pattern: '*[data_videoplayer]',
	swf: 'videoplayer.swf',
	width: 320,
	height: 240,

	init: function () {
		if (typeof (window ['swfobject']) != 'undefined' && typeof (window ['jQuery']) != 'undefined') {
			$(document).ready (videoplayer.hook);
		}
	},

	hook: function () {
		$(videoplayer.pattern).ready (videoplayer.generate);
	},

	generate: function () {
		var jElm = $(videoplayer.pattern);

		var id = new String (jElm.attr ('id'));
		if (id.length <= 0 || id == 'undefined') {
			var count = 0;
			id = 'videoplayer' + count;
			while (document.getElementById (id)) {
				count++;
				id = 'videoplayer' + count;
			}
		}

		var params = {
			url: jElm.attr ('data_videoplayer'),
			repeat: jElm.attr ('data_repeat'),
			autoplay: jElm.attr ('data_autoplay')
		};

		jElm.replaceWith ('<div id="' + id + '"></div>');
		swfobject.embedSWF (
			videoplayer.swf, id,
			jElm.attr ('width') != null ? jElm.attr ('width') : videoplayer.width,
			jElm.attr ('height') != null ? jElm.attr ('height') : videoplayer.height,
			'10.0.0', null, params
		);

		if (params.callback != null) {
			eval (params.callback + '("started", {id:"' + id + '"});');
		}
	}
}

videoplayer.init ();