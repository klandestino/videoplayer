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
			callback: 'videoplayer.generateCallback ("' + id + '")',
			url: jElm.attr ('data_videoplayer'),
			autoplay: jElm.attr ('data_autoplay'),
			autoplay: jElm.attr ('data_autosize'),
			repeat: jElm.attr ('data_repeat')
		};

		jElm.replaceWith ('<div id="' + id + '"></div>');
		swfobject.embedSWF (videoplayer.swf, id, '100%', '100%', '10.0.0', null, params);
		jQuery ('#' + id).width (jElm.attr ('width') != null ? jElm.attr ('width') : videoplayer.width);
		jQuery ('#' + id).height (jElm.attr ('height') != null ? jElm.attr ('height') : videoplayer.height);

		if (params.callback != null) {
			eval (params.callback + '("started", "' + id + '");');
		}
	},

	generateCallback: function (id) {
		return function (type, args) {
			switch (type) {
				case 'resize':
					jQuery ('#' + id).width (args [0]);
					jQuery ('#' + id).height (args [1]);
					break;
			}
		}
	}
}

videoplayer.init ();