
// 
// CommonJS Client-side Implementation
// 
// Author: James Brumond <james@jbrumond.me> (http://www.jbrumond.me)
// GitHub: https://www.github.com/UmbraEngineering/commonjs-preprocessor
// 

(function(window) {

	var head = document.getElementsByTagName('head')[0];
	
	// 
	// The core module loading function
	// 
	// @param {file} the module path to load
	// @param {from} the module requesting the require
	// 
	var require = window.require = function(file, from) {
		var module = require.lookup(file, from);
		if (! module) {
			var msg = 'Cannot find module "' + file + '"';
			if (from && from.filename) {
				msg += ' in file "' + from.filename +  '"';
			}
			throw new Error(msg);
		}
		if (from) {
			from.children.push(module);
		}
		if (! module.loaded) {
			if (from) {
				module.parent = from;
			}
			module.call();
		}
		return module.exports;
	};

	// 
	// Looks up and returns a module
	// 
	// @param {file} the module path to load
	// @param {from} the module requesting the lookup
	// 
	require.lookup = function(file, from) {
		return require._modules[require.resolve(file, from)];
	};

	// 
	// Paths to search for non-relative modules. By default, that just
	// looks them up from the root JavaScript directory. These should
	// all begin with a slash "/".
	// 
	require.paths = [ '/' ];

	// 
	// The JavaScript source directory, used by {require.load}. If the common.js
	// client is not in the root JavaScript directory, this should be overriden
	// to be accurate.
	// 
	require.dir = (function() {
		var script = document.getElementsByTagName('script');
		script = script[script.length - 1];
		var src = script.getAttribute('src');
		script = null;
		src = src.split('/');
		src.pop();
		return src.join('/');
	}());

	// 
	// Resolves a given {file} path and {from} module to get an exact
	// lookup path for the requested module
	// 
	// @param {file} the module path to load
	// @param {from} the module requesting the resolve
	// 
	require.resolve = function(file, from) {
		if (file.slice(-3) !== '.js') {
			file += '.js';
		}

		switch (file.charAt(0)) {
			// Absolute path (relative to given JavaScript root directory)
			//   eg. require('/module');
			case '/':
				return modulePath(file);
			break;
			
			// Relative path
			//   eg. require('./module');
			case '.':
				file = file.split('/');
				
				var dir = from ? from.dirname : '';
				var segments = dir.split('/');
				
				for (var i = 0, c = file.length; i < c; i++) {
					switch (file[i]) {
						case '.': /* pass */ break;
						case '..': segments.pop(); break;
						default: segments.push(file[i]); break;
					}
				}

				file = segments.join('/');
				return modulePath(file);
			break;
			
			// Just module name
			//   eg. require('module');
			default:
				for (var i = 0, c = require.paths.length; i < c; i++) {
					var dir = require.paths[i];
					if (dir.charAt(dir.length - 1) !== '/') {
						dir += '/';
					}
					var resolved = dir + file;
					if (resolved = modulePath(resolved)) {
						return resolved;
					}
				}
				return null;
			break;
		}

		function modulePath(file) {
			if (require.exists(file)) {
				return file;
			}

			file = file.slice(0, -3) + '/index.js';

			if (require.exists(file)) {
				return file;
			}

			return null;
		}
	};

	// 
	// Loads a JavaScript file async if it is not already loaded. The given
	// {files} must be absolute paths.
	// 
	// @param {files...} the files to load
	// 
	require.load = function() {
		var promise = require.load.defer();
		var files = Array.prototype.slice.call(arguments);
		var toLoad = files.length;

		// Iterate through the files and load each one
		for (var i = 0, c = files.length; i < c; i++) {
			var file = files[i];

			if (file.charAt(0) !== '/') {
				file = '/' + file;
			}

			file = require.dir + file;

			if (file.slice(-3) !== '.js') {
				file += '.js';
			}

			// Create the script tag
			var script = require.load.createScript({
				src: file,
				defer: true,
				async: true
			});

			// Set an onload handler
			script.onload = script.onreadystatechange = function() {
				if (! script.readyState || script.readyState === 'loaded' || script.readyState === 'complete') {
					// Cleanup
					script.onload = script.onreadystatechange = null;
					if (head && script.parentNode) {
						head.removeChild(script);
					}

					// Mark the file as loaded and check if we are done
					if (! --toLoad) {
						promise.resolve();
					}
				}
			};

			// Inject the script
			head.appendChild(script);
		}

		return promise;
	};

	// 
	// Create a deferred
	// 
	require.load.defer = function() {
		var promise = {
			funcs: [ ],
			passed: false,
			then: function(func) {
				if (promise.passed) {
					setTimeout(func, 0);
				} else {
					promise.funcs.push(func);
				}
			},
			resolve: function() {
				promise.passed = true;
				for (var i = 0, c = promise.funcs.length; i < c; i++) {
					setTimeout(promise.funcs[i], 0);
				}
			}
		};

		return promise;
	};

	// 
	// Check if a list of files has been loaded
	// 
	// @param {files} a list of module files to check on
	// 
	require.loaded = function(files) {
		var loaded = true;
		for (var i = 0, c = files.length; i < c; i++) {
			if (! require.resolve(files[i])) {
				loaded = false;
				break;
			}
		}
		return loaded;
	};

	// 
	// This is where modules are stored
	// 
	// require._modules[*] = {
	//   loaded: Bool,
	//   exports: Mixed,
	//   filename: String,
	//   require: Function,
	//   parent: module,
	//   children: [module],
	//   call: Function
	// }
	// 
	require._modules = { };

	// 
	// Determine if the given module exists. We use {hasOwnProperty} here to be extra
	// careful, but it should never actually be an issue as all of the module property
	// names should begin with a slash, and if anyone is defining new prototype properties
	// that start with a slash, they deserve what is coming to them...
	// 
	// @param {file} an absolute module path
	// 
	require.exists = (require._modules.hasOwnProperty
		? function(file) {
			return require._modules.hasOwnProperty(file);
		}
		: function(file) {
			return (file in require._modules[file]);
		});

	// 
	// Return a copy of {require} that is bound to the scope of a module. This is
	// used to create the copy store on modules at {module.require}.
	// 
	// @param {module} the module object to bind to
	// 
	require._bind = function(module) {
		var result = function(file, from) {
			return require(file, from || module);
		};
		result.lookup = function(file, from) {
			return require.lookup(file, from || module);
		};
		result.resolve = function(file, from) {
			return require.resolve(file, from || module);
		};
		result.load = function() {
			return require.load.apply(require, arguments);
		};
		result._modules = require._modules;
		return result;
	};

}(window));
