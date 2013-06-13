/*
 * Load the page passed as the first argument.
 */

var page = require('webpage').create(),
    sys = require('system');

page.open(sys.args[1], function(status) {
	if (status !== 'success') {
		console.log("failed to load " + sys.args[1]);
	}
	phantom.exit();
});
