/**
 * JavaScript Library V 1.00.A
 * http://www.openjs.com/scripts/jslibrary/
 */
(function() {
	window.JSL = {
		"_getUserArgs": function(arguments) {
			var user_args = [];
			for (var i=1; i<arguments.length; i++) { //We dont need the first
				user_args.push(arguments[i]);
			}
			return user_args;
		},
		
		/// If a string is passed in for the function, make a function for it (a handy shortcut)
		/// Thanks, jQuery!
		"_makeFunc": function(func, args) {
			if ( typeof func == "string" ) {
				var rtext = "";
				if(!func.indexOf("return") + 1) rtext = "return "; //If the arg don't have return, add it.
				func = eval("false||function("+ args +"){" + rtext + func + "}");
			}
			return func;
		}
	}
})();

//jslib is a global shortcut for JSL.* functions.
var jslib = function() {
	if(typeof arguments[0] == "number") return JSL.number.apply(this, arguments);
	else if(typeof arguments[0] == "object") { //This could be a DOM node or an array/object
		if(typeof arguments[0].parentNode != "undefined" || //For ordinary DOM nodes
			(typeof arguments[0].parent != "undefined" && typeof arguments[0].document != "undefined" )) // For 'window'
				return JSL.dom.apply(this, arguments);
		else if(arguments.length == 1 && (typeof arguments[0].target != "undefined" || typeof arguments[0].srcElement != "undefined")) { //An event is the argument
			return JSL.event.apply(this, arguments);
		}
		return JSL.array.apply(this, arguments);
	}
	else return JSL.dom.apply(this, arguments);
};
// Also, hijack the $ function for ourself.
if(typeof $ != "undefined") $_ =  $;
$ = jslib;
/**
 * Class : JSL.array
 * Handles all the array related functions.
 * Argument: arr - The array on which the operation must be done.
 */
(function() {
	/// Constructor
	function _array_init(arr) {
		this.array = arr;
		
		//Get all the array function in the 'this' element itself - stuff like map(), each
		for(var i in this.array) {
			this[i] = this.array[i];
		}
		this.length = arr.length;
		return this;
	}
	
	_array_init.prototype = {
		/**
		 * This function will loop thru the array and call the given function for each element. 
		 *		The values returned by the user defined function will be used to create a new 
		 *		array/object that is returned by the function at the end. 3 arguments will be passed to
		 *		the user defined function - 
		 *			- current_item - The value of the current element
		 *			- index - The index we are currently at
		 *			- full_array - The entire array
		 *			- user_args - The data provided by the user, if any.
		 *
		 * Argument:
		 *		func - The user function.
		 *		user_args - Custom data passed into the function [OPTIONAL]
		 * Example:
		 *	<pre>var result = JSL.array([4,10,65]).map(function(current_item) {
		 *		return current_item+1;
		 *	});</pre>
		 *	Result will be [5, 11, 66]
		 *
		 *	<pre>var result = JSL.array([4,10,65]).map(function(current_item, x) {
		 *		return current_item + x;
		 *	}, 5);</pre>
		 *	Result will be [9, 15, 70] - 5, the second argument of the map function is passed into the 1st argument function.
		 */
		"map" : function() {
			var func = arguments[0];
			func = JSL._makeFunc(func,"ele,i,all");
			var user_args = JSL._getUserArgs(arguments);
			
			var is_array = this.isList();
			var result = (is_array) ? [] : {};
			
			function _callUserFunction(index, user_args, result) {
				var return_value = func.apply(this, [this.array[index], index, this.array].concat(user_args));
				if(return_value != undefined) {
					if(is_array) result.push(return_value);
					else result[index] = return_value;
				}
				return result;
			}
			
			// I use 2 differnt methods of accessing the array elements based on what kind of data it is - yeah, I hate doing this.
			//		So why am I doing this? To get the small performance boost promised in http://batiste.dosimple.ch/blog/posts/2007-02-27-1/javascript-loop-benchmark.html
			if(is_array) { //This part is for the lists
				array_length = this.array.length;
				for(var index=0; index<array_length; index++) {
					result = _callUserFunction.apply(this, [index, user_args, result]);
				}
			} else { //Prossess the associative arrays/hashes
				for(var index in this.array) {
					if(this.array.hasOwnProperty && !this.array.hasOwnProperty(index)) continue; // Prototype.js library compatiability code.
					result = _callUserFunction.apply(this, [index, user_args, result]);
				}
			}
			this.array = result;
			return this;
		},
		

		/**
		 * This function will loop thru the array and call the given function for each element. 4 arguments will be passed to
		 *		the user defined function - 
		 *			current_item - The value of the current element
		 *			index - The index we are currently at
		 *			full_array - The entire array
		 *			user_args - The data provided by the user, if any, as an array
		 *		If the user function returns anything, the loop will end - returning that value to the calling code.
		 *
		 * Argument:
		 *		func - The user function.
		 *		user_args - Custom data passed into the function [OPTIONAL]
		 * Example:
		 *	JSL.array(document.getElementsByTagName("a")).each(function(ele) {
		 *		ele.onclick = false; //Disable all links
		 *	});
		 */
		"each" : function() {
			var func = arguments[0];
			func = JSL._makeFunc(func,"ele,i,all");
			var is_array = this.isList();
			
			var user_args = JSL._getUserArgs(arguments);
			
			
			if(is_array) { //This part is for the lists
				var array_length = this.array.length;
				for(var index=0; index<array_length; index++) {
					var return_value = func.apply(this, [this.array[index], index, this.array].concat(user_args));
					if(return_value != undefined) return return_value;
				}
			} else {
				for(var index in this.array) {
					if(this.array.hasOwnProperty && !this.array.hasOwnProperty(index)) continue; // Prototype.js library compatiability code.

					var return_value = func.apply(this, [this.array[index], index, this.array].concat(user_args));
					if(return_value != undefined) return return_value;
				}
			}
		},
		
		/**
		 * Function will loop thru the array and collects all the element for which the user function returned a true value.
		 *		This array will be returned as a JSL.array object.
		 * Argument:
		 *		func - The user function.
		 *		user_args - Custom data passed into the function [OPTIONAL].
		 * Example:
		 *	JSL.array(["hello", "world", "virus", "worm", "virus", "trojan"]).filter(function(current_item, i, full_array, bad_word) {
		 *		return current_item !== bad_word; //Removes all the elements that don't say 'virus'
		 *	}, "virus"); //"virus" is the bad_word
		 */
		 "filter" : function() {
		 	var func = arguments[0];
			func = JSL._makeFunc(func,"ele,i,all");
			var user_args = JSL._getUserArgs(arguments);
				 	
			this.map.apply(this, [function(ele, i, arr, user_args) {
				if(func(ele, i, arr, user_args)) return ele; //If the result of the user function is true, that element must be in the return array.
			}, user_args]);
			
			return this;
		},
		
		/**
		 * Searches thru the array until the given element is found - and returns it index.
		 * Argument: The value that must be searched for.
		 * Return : -1 if searched element was not found - or it will return the index of the first found element.
		 * Example:
		 *		JSL.array([2,6,19,34]).indexOf(19); // Returns 2
		 *		JSL.array([2,6,19,34]).indexOf(17); // Returns -1
		 *		JSL.array({"a":2, "b":6, "c":19, "d":34}).indexOf(19); // Returns 'c'
		 */
		"indexOf": function(value) {
			//:TODO: indexOf(searchValue, fromIndex)
			var location = this.each(function(ele, index) {
				if(ele == value) return index;
			});
			if(location != undefined) return location;
			return -1;
		},
		
		/**
		 * Apply a function simultaneously against two values of the array (from left-to-right) as to reduce it to a single value.
		 * Taken from : http://developer.mozilla.org/en/docs/Core_JavaScript_1.5_Reference:Objects:Array:reduce
		 * Return: The Result
		 * Example:
		 * 		//Find the Total of all elements
		 * 		JSL.array([0, 1, 2, 3]).reduce(function(a, b){ return a + b; }); // == 6
		 */
		"reduce": function(func, initial_value) {
			var len = this.array.length;

			func = JSL._makeFunc(func,"a,b");

			//No value to return if no initial value and an empty array
			if (len == 0 && arguments.length == 1) throw new TypeError();
			
			var i = 0;
			if (arguments.length >= 2) {
				var return_value = arguments[1];
			} else {
				do {
					if (i in this.array) {
						return_value = this.array[i++];
						break;
					}
				
					//If array contains no values, no initial value to return
					if (++i >= len) throw new TypeError();
				} while (true);
			}
			
			for (; i < len; i++) {
				if (i in this.array)
					return_value = func.call(null, return_value, this.array[i], i, this.array);
			}
			
			return return_value;
		},
		
		/**
		 * Returns all the elements in the selected array that matches the provided regular expression
		 * Argument:
		 *		regexp - The regular expression that should be matched against all the elements in the array.
		 * Example:
		 *		JSL.array(['hello', 'world', 'hot', 'water']).grep(/^w/);
		 *		//Returns ['world', 'water']
		 */
		"grep": function(regexp) {
			return this.filter(function(ele){return ele.match(regexp);});
		},
		
		/**
		 * Returns the last element of the array.
		 * Return:
		 *      The last element. What did I just say?
		 * Example:
		 *		JSL.array(['hello', 'world', 'hot', 'water']).last();
		 *		//Returns 'water'
		 */
		"last": function() {
			return this.array[this.array.length-1];
		},
		
		/**
		 * Get the number of elements currently seleted.
		 * Return:
		 * 		length(Integer) - The size of the currently selected array
		 */
		"getSize": function() {
			return this.array.length;
		},
		
		/**
		 * Returns the base element - in this case, an array.
		 */
		"get" : function() {
			return this.array;
		},
		
		/**
		 * Checks wether the current array is an Numerical Array(List)  - if so return true. Objects return false.  
		 * Return: Boolean - true if its an numerical array(list) and false if its anything else
		 */
		"isList": function() {
			var arr_obj = this.array;
			return (arr_obj && (arr_obj.propertyIsEnumerable && !(arr_obj.propertyIsEnumerable('length'))) 
				&& typeof arr_obj === 'object' && typeof arr_obj.length === 'number');
		}
	}
	
	window.JSL["array"] = function() {
		//A quick hack to make this possible - JSL.array(3,4,5).each();
		var args = arguments;
		if(arguments.length == 1) args = arguments[0];
		return new _array_init(args);
	}
})();

/*
 * :TODO:
 * array.lastIndexOf()
 * array.difference(another_array)
 * 
 *
 *//**
 * Class : JSL.dom
 * Handles all the DOM functions.
 * Arguments: The argument can be the ID of an element, a DOM node reference or a CSS query.
 * Example:
 * 		JSL.dom("element-id")
 * 		JSL.dom(document.getElementById("element-id"))
 * 		JSL.dom("span a.external-links")
 */
(function() {
	function _dom_init(arguments) {
		var selected_elements = [];
		for(var i=0, args_length = arguments.length; i<args_length; i++) {
			var arg = arguments[i];
			var new_eles;
			
			if(typeof arg == "string") { //The arg is a selector
				this.selector[i] = arg;
				new_eles = this._select(arg);
			
			} else { //The argument is a DOM Node
				new_eles = arg;
			}
			selected_elements = selected_elements.concat(new_eles);
		}
		var elements_count = selected_elements.length;
		this.nodes = JSL.array(selected_elements);

		//If is the user gave us a specific dom node, we must return just that - with our additions
		if(arguments.length == 1 && elements_count == 1) {
			var arg_type = this._getType(arguments[0]);
			if(arg_type == 'node' || arg_type == 'id') {
				var ele = selected_elements[0]; //If an ID was specified, it must be available thru the get as a single element.
				if(!ele) return false; //Invaid element
				
				for(var i in this) {
					if(ele[i]) { //If the function already exists, back it up first.
						ele["_" + i] = ele[i];
					}
					ele[i] = this[i];
				}
				
				if(typeof ele.length == "undefined") ele.length = 1;
				ele.single = selected_elements[0];

				return ele; //Returns the Element - with all our additions
			}
		} else if(arguments.length == 1 && elements_count == 0) { // If the element with the given id does not exist,
			var arg_type = this._getType(arguments[0]);
			if(arg_type == 'node' || arg_type == 'id') {
				var return_vaule = {"return_null":true};
				return return_vaule;
			}
		}
		
		//Get all the array function in the 'this' element itself - stuff like map(), each
		for(var i in this.nodes) {
			if(!this[i]) this[i] = this.nodes[i];
		}
		if(typeof this.length == "undefined") this.length = this.getSize();
		
		return this;
	}
	
	_dom_init.prototype = {
		"selector":[],
		"nodes":[],
		"single":false,
		"valid_tags":["a","abbr","acronym","address","applet","area","b","base","basefont","bdo",
						"big","blockquote","body","br","button","caption","center","cite","code",
						"col","colgroup","dd","del","dir","div","dfn","dl","dt","em","fieldset",
						"font","form","frame","frameset","h1","h2","h3","h4","h5","h6","head","hr",
						"html","i","iframe","img","input","ins","isindex","kbd","label","legend",
						"li","link","map","menu","meta","noframes","noscript","object","ol","optgroup",
						"option","p","param","pre","q","s","samp","script","select","small","span",
						"strike","strong","style","sub","sup","table","tbody","td","textarea","tfoot",
						"th","thead","title","tr","tt","u","ul","var"],
		
		///////////////////////////////// Styles /////////////////////////
		/**
		 * Adds the given class to the currently selected items
		 * Argument: class_name - The class that must be added to the selected elements
		 * Example:
		 *	JSL.dom("a").addClass("external");
		 */
		"addClass": function(class_name) {
			var self = this;
			this.nodes.each(function(ele) {
				self._class._add(ele,class_name);
			});
			return this;
		},
		/**
		 * Removes the said class from all the element the selected list
		 * Argument: class_name - The class that must be removed from all the selected elements
		 * Example: JSL.dom("span.active").removeClass("active");
		 */
		"removeClass": function(class_name) {
			var self = this;
			this.nodes.each(function(ele) {
				self._class._remove(ele,class_name);
			});
			return this;
		},
		/**
		 * Returns true if the class given as the argument is present for the current element.
		 * Argument: class_name - The class name that be checked for in the current element
		 * Return: This function returns true if the class is there in this element and else if the class is not found.
		 * Example: if(JSL.dom("main-link").hasClass("active")) { //...
		 */
		"hasClass": function(class_name) {
			return this._class._has(this.single,class_name);
		},
		
		/**
		 * Get the X,Y coordinates of the given element.
		 * Taken from http://txt.binnyva.com/2007/06/find-elements-position-using-javascript/
		 * Return: An associative array in this format - <code>{"left":leftx,"x":leftx,"top":topy,"y":topy}</code>
		 * Example: var position = JSL.dom("element-id").getPosition();
		 */
		"getPosition": function() {
			var ele = this.nodes.array[0]; //You can have the position for only 1 element.
			var leftx = topy = 0;
			if (ele.offsetParent) {
				leftx = ele.offsetLeft;
				topy = ele.offsetTop;
				while (ele = ele.offsetParent) {
					leftx += ele.offsetLeft;
					topy += ele.offsetTop;
				}
			}

			return {"left":leftx,"x":leftx,"top":topy,"y":topy};
		},
		
		/// Shortcut function for getStyle and setStyle
		"css":function(property, value) {
			if(typeof value == "undefined" && typeof property == "string") return this.getStyle(property);
			return this.setStyle(property, value); 
		},

		/**
		 * Get the specified style of the active element.
		 * Inspired by http://www.quirksmode.org/dom/getstyles.html
		 * Argument: property - The name of the property that must be fetched.
		 * Example: JSL.dom("element-id").getStyle("width");
		 */
		"getStyle": function(property) {
			var ele = this.nodes.array[0];
			if (ele.currentStyle) {
				var alt_property_name = property.replace(/\-(\w)/g,function(m,c){return c.toUpperCase();});//background-color becomes backgroundColor
				var value = ele.currentStyle[property]||ele.currentStyle[alt_property_name];
			
			} else if (window.getComputedStyle) {
				property = property.replace(/([A-Z])/g,"-$1").toLowerCase();//backgroundColor becomes background-color

				var value = document.defaultView.getComputedStyle(ele,null).getPropertyValue(property);
			}
			
			//Some properties are special cases
			if(property == "opacity" && ele.filter) value = (parseFloat( ele.filter.match(/opacity\=([^)]*)/)[1] ) / 100);
			else if(property == "width" && isNaN(value)) value = ele.clientWidth || ele.offsetWidth;
			else if(property == "height" && isNaN(value)) value = ele.clientHeight || ele.offsetHeight;
			
			//Remove the 'px' from the end of values
			if(typeof value == "string" && value.match(/^\d+px$/)) {
				value = Number(value.replace(/px/, ""));
			}
			
			return value;
		},
		
		/**
		 * Set the style of the element.
		 * Example:
		 *	JSL.dom("element").setStyle("position", "absolute");
		 *		OR
		 *	JSL.dom("element").setStyle({
		 *				"position":"absolute",
		 *				"top":"50px",
		 *				"left":"100px"
		 *			});
		 */
		"setStyle": function(property, value) {
			var all_styles = {};
			if(typeof property === "string") all_styles[property] = value;
			else all_styles = property;
			
			this.nodes.each(function(ele) {
				JSL.array(all_styles).each(function(value, property, all, ele) {
					property = property.replace(/\-(\w)/g,function(m,c){return c.toUpperCase();});//background-color becomes backgroundColor
					
					//Append a 'px' at the end of all numbers.
					if(value && value.constructor == Number) {
						var non_px = JSL.array(['zIndex','fontWeight','opacity','zoom','lineHeight']); //...except for these ones
						if( non_px.indexOf(property) == -1  && value.toString().indexOf("px") == -1 ) value += 'px';
					}
					
					if(property == "opacity") {
						ele.style.opacity = value;
						ele.style.filter = 'alpha(opacity='+value+')';	//IE
					} else {
						ele.style[property] = value;
					}
				},ele);
			});
			return this;
		},
		
		/**
		 * Shows all currently selected elements.
		 * Arguments:
		 *		display[OPTIONAL] - could be 'visible', 'inline' or 'block'. If you chose 'visible', the function changes the 'visibility' property instead of the 'display' property. Defaults to 'block'. 
		 * Example:
		 *	JSL.dom("example").show()
		 *	JSL.dom("example").show("visible")
		 */
		"show" : function(display) {
			this.nodes.each(function(ele) {
				if(display === "visible") ele.style.visibility = "visible";
				else if(display === "inline") ele.style.display = "inline";
				else ele.style.display = "block";
			});
			return this;
		},
		
		/**
		 * Hides all the currently selected elements
 		 * Arguments:
		 *		display[OPTIONAL] - could be 'hidden', 'none'. If you chose 'hidden', the function changes the 'visibility' property instead of the 'display' property. Defaults to 'none'. 
		 * Example:
		 *	JSL.dom("example").hide()
		 */
		"hide" : function(display) {
			this.nodes.each(function(ele) {
				if(display === "hidden") ele.style.visibility = "hidden";
				else ele.style.display = "none";
			});
			return this;
		},
		
		/**
		 * Toggles the selected elements between hidden and displayed state. It the element is shown, 
		 *		one toggle call will make it hidden - and if its hidden, a toggle call will show it.
		 * Example:
		 *	JSL.dom("example").toggle()
		 */
		"toggle": function() {
			this.nodes.each(function(ele) {
				if(ele.style.display != "block" ) ele.style.display = "block";
				else ele.style.display = "none";
			});
			// :TODO: Write tests
			return this;
		},
		///Alias of toggle - I often confuse the two. [IGNORE]
		"toogle":function(){this.toggle.apply(this, arguments);return this;},
		
		///////////////////////////////// Events /////////////////////////
		
		/**
		 * Attach an event to a function.
		 * Arguments: event - The event to watch for.
		 * 			  function - The function that shoulb be called on that event.
		 * Example:
		 *	JSL.dom(window).on("unload", goodbye_func);
		 */
		"on" : function(event, func) {
			this.nodes.each(function(ele) {
				JSL.event().add(ele, event, func);
			});
			return this;
		},
		
		/**
		 * Attach the click event to the specified function for all the selected elements
		 * Argument: func - The function that should be called on the 'onclick' event.
		 * Example:
		 *	JSL.dom("a.delete-links").click(confirm_delete);
		 */
		"click":function(func){return this.on("click", func);},
		
		/**
		 * Attach the load event to the specified function. Usually its only used with the window element
		 * Argument: func - The function that should be called on document 'onload' event.
		 * Example:
		 *	JSL.dom(window).load(init);
		 */
		"load":function(func){return this.on("load", func);},
		
		
		//////////////// The Privates //////////////////
		
		/// CSS Selectors - Taken from http://www.openjs.com/scripts/dom/css_selector/css_selector.js
		"_select" : function(all_selectors) {
			//Find what the selector is...
			var type = this._getType(all_selectors);
			if(type === "id") { //Superfast processing for IDs
				var ele = document.getElementById(all_selectors.replace("#",""));

				//To make sure we get the non existant elements
				if(ele) return [ele];
				else return [];
			}

			var selected = new Array();
			if(!document.getElementsByTagName) return selected; //It must be a very old browser
			
			all_selectors = all_selectors.replace(/\s*([^\w\.\#])\s*/g,"$1");//Remove the 'beautification' spaces
			var selectors = all_selectors.split(",");
			
			var getElementsByTagName = function(context, tag) { ///[IGNORE]
				if (tag == '*') return (context.all) ? context.all : context.getElementsByTagName("*"); // For IE.
				return context.getElementsByTagName(tag);
			}
			
			// Grab all of the tagName elements within current context
			var getElements = function(context,tag) { ///[IGNORE]
				if (!tag) tag = '*';

				// Get elements matching tag, filter them for class selector
				var found = [];
				for (var i=0,len=context.length; con=context[i],i<len; i++) {
					var eles = getElementsByTagName(con, tag);
					
					for(var j=0,leng=eles.length;j<leng; j++) {
						//Add it to the array.
						found.push(eles[j]);
					}
				}
				return found;
			}
		
			COMMA:
			for(var i=0,len1=selectors.length; selector=selectors[i],i<len1; i++) {
				var context = [document];
				var inheriters = selector.split(" ");
		
				SPACE:
				for(var j=0,len2=inheriters.length; element=inheriters[j],j<len2;j++) {
					//This part is to make sure that it is not part of a CSS3 Selector
					var left_bracket = element.indexOf("[");
					var right_bracket = element.indexOf("]");
					var pos = element.indexOf("#");//ID
					if(pos+1 && !(pos>left_bracket && pos<right_bracket)) {
						var parts = element.split("#");
						var tag = parts[0];
						var id = parts[1];
						var ele = document.getElementById(id);
						if(!ele || (tag && ele.nodeName.toLowerCase() != tag)) { //Specified element not found
							continue COMMA;
						}
						context = [ele];
						continue SPACE;
					}
					
					pos = element.indexOf(">");//Child selectors
					if(pos+1 && !(pos>left_bracket && pos<right_bracket)) {
						var parts = element.split(">");
						var tag = parts[0];
						var child = parts[1];
		
						var found = getElements(context, tag); //Get the tags in the current context.
						context = [];
						for (var l=0,len=found.length; fnd=found[l],l<len; l++) { // Go thru each tag
							var children = getElementsByTagName(fnd, child); //And find all element that match child tags
							for (var m=0,leng=children.length; fond=children[m], m<leng; m++) { // Go thru each
								if(fond.parentNode == fnd) context.push(fond); // Ifs its a direct child(1st generation) add it to our selected list.
							}
						}
						
						continue SPACE;
					}
					
					pos = element.indexOf("+");//sibling selector
					if(pos+1 && !(pos>left_bracket && pos<right_bracket)) {
						var parts = element.split("+");
						var tag = parts[0];
						var sibling_tag = parts[1];
		
						var found	= getElements(context, tag); //Get the tags in the current context.
						
						context = [];
						for (var l=0,len=found.length; ele_main=found[l],l<len; l++) { // Go thru each tag
							var sibling = ele_main.nextSibling;
							while(sibling) {
								if(sibling.nodeType == 1) { //Its a tag - not a text fragment.
									if(sibling.tagName == sibling_tag.toUpperCase()) {
										p(ele_main, sibling);
										context.push(sibling);
									}
									else break;
								}
								sibling = sibling.nextSibling;
							}
						}
						
						continue SPACE;
					}
		
					pos = element.indexOf(".");//Class
					if(pos+1 && !(pos>left_bracket && pos<right_bracket)) {
						var parts = element.split('.');
						var tag = parts[0];
						var class_name = parts[1];
		
						var found = getElements(context,tag);
						context = new Array;
						for (var l=0,len=found.length; fnd=found[l],l<len; l++) {
							if(fnd.className && fnd.className.match(new RegExp("(^|\\s)"+class_name+"(\\s|$)"))) context.push(fnd);
						}
						continue SPACE;
					}
		
					if(element.indexOf('[')+1) {//If the char '[' appears, that means it needs CSS 3 parsing
						// Code to deal with attribute selectors
						if (element.match(/^(\w*)\[(\w+)([=~\|\^\$\*]?)=?['"]?([^\]'"]*)['"]?\]$/)) {
							var tag = RegExp.$1;
							var attr = RegExp.$2;
							var operator = RegExp.$3;
							var value = RegExp.$4;
						}
						var found = getElements(context,tag);

						context = [];
						for (var l=0,len=found.length; fnd=found[l],l<len; l++) {
							if(attr === "class") var attr_value = fnd.className; //IE will not allow getAttribute("class")
							else var attr_value = fnd.getAttribute(attr);

							if(attr_value) {
								// The if conditions are for elements that DO NOT match the selector. If it matches it goes to the very bottom where its pushed into the context.
								if(operator=='=' && attr_value != value) continue;
								else if(operator=='~' && !attr_value.match(new RegExp('(^|\\s)'+value+'(\\s|$)'))) continue;
								else if(operator=='|' && !attr_value.match(new RegExp('^'+value+'-?'))) continue;
								else if(operator=='^' && attr_value.indexOf(value)!=0) continue;
								else if(operator=='$' && attr_value.lastIndexOf(value)!=(attr_value.length-value.length)) continue;
								else if(operator=='*' && !(attr_value.indexOf(value)+1)) continue;
								else if(!attr_value) continue;
								context.push(fnd);
							}
						}
		
						continue SPACE;
					}
		
					//Tag selectors - no class or id specified.
					var found = getElements(context,element);
					context = found;
				}
				for (var o=0,len=context.length;o<len; o++) selected.push(context[o]);
			}
			
			// Remove duplicate elements in the result.
			var final_result = []; //Make a New array - the non duplicates will be put into this.
			SELECTED_ELEMENT:
			for(var i=0, len=selected.length; i<len; i++) {
				for(var j=0, leng=final_result.length; j<leng; j++) {
					if(selected[i] == final_result[j]) continue SELECTED_ELEMENT; //Yup - its a duplicate
				}
				final_result.push(selected[i]); //Got a non duplicate element.
			}
			
			return final_result;
		},

		/**
		 * Returns the base element
		 * Example: JSL.dom("element-id").get() // returns document.getElementById("element-id");
		 */
		"get": function() {
			if(this.single) return this.single;
			else return this.nodes.get();
		},

		/// Class manipulations - taken from http://www.openjs.com/scripts/dom/class_manipulation.php
		"_class": {
			"_add":function(ele,cls) {
				if (!this._has(ele,cls)) ele.className += " "+cls;
			},
			"_has":function(ele, cls) {
				return ele.className.match(new RegExp('(\\s|^)'+cls+'(\\s|$)'));
			},
			"_remove":function(ele,cls) {
				if (this._has(ele,cls)) {
					var reg = new RegExp('(\\s|^)'+cls+'(\\s|$)');
					ele.className=ele.className.replace(reg,' ');
				}
			}
		},
		
		/// Takes a string and tries to guess wether it is a 'css selector' or a 'tag' or an 'id'. Returns the result.
		"_getType":function(str) {
			if(typeof str == "string") {
				if(str.indexOf("#") > 0 || str.indexOf(".")+1 || str.indexOf(" ")+1 || str.indexOf(",")+1 || str.indexOf("[")+1 || str.indexOf("*")+1
					 || str.indexOf("+")+1 || str.indexOf(">")+1) return "css"; //A CSS Selector
				else if(JSL.array(this.valid_tags).indexOf(str)+1) return "tag"; //Its a tag.
				else return "id"; //An id, perhabs?
			} else {
				return "node";
			}
		}
	}

	window.JSL["dom"] = function() {
		var return_vaule = new _dom_init(arguments);
		if(return_vaule.return_null) return null;
		return return_vaule;
	}
})();

/* :TODO:
 *
 *//**
 * Class: JSL.event
 * All the event related functions are in this class.
 */
(function() {
	function _event_init(e) {
		this.event = e || window.event;
		return this;
	}
	
	_event_init.prototype = {
		/**
		 * The famous addEvent function. But calling it in this format is not the preffered method. Use the DOM interface to make the call.
		 * Arguments: ele(DOM Node) - The Element to which the event should be attached. This must be a DOM Node.
		 * 				type(String) - The event type - "load", 'mouseover', 'click', etc.
		 * 				func(Function) - The function that must be called on the event
		 * 				capture(Boolean) - true if you want to enable capture.
		 * Example:
		 * 		JSL.dom("#ele").on("mouseover", function(e){ alert("Hello World"); });
		 * 		JSL.event().add(document.getElementById("ele"), "mouseover", function(e){ alert("Hello World"); });
		 */
		"add" :function(ele,type,func,capture) {
			function _makeCallback(e){
				var ele = JSL.event(e).getTarget() || document;
				func.call(ele,e);
			}
			capture = capture||true;
			
			if(ele.attachEvent) {
				return ele.attachEvent('on' + type, _makeCallback);
			} else if(ele.addEventListener) {
				ele.addEventListener(type, _makeCallback, capture);
				return true;
			} else {
				ele['on' + type] = _makeCallback;
			}
		},

		/**
		 * Stop an event from further propogation.
		 * Taken from http://www.openjs.com/articles/prevent_default_action/
		 * Example:
		 *	JSL.event(e).stop();
		 */
		"stop": function(){
			var e = this.event;
			e.cancelBubble = true;
			e.returnValue = false;
			if(e.stopPropagation) e.stopPropagation();
			if(e.preventDefault) e.preventDefault();
			return false;
		},

		/**
		 * Get the target of the current event
		 * Example:
		 *	var ele = JSL.event(e).getTarget();
		 */
		"getTarget": function() {
			var element;
			var e = this.event;
			if(e.target) element=e.target;
			else if(e.srcElement) element=e.srcElement;
			
			if(element && element.nodeType==3) element=element.parentNode; //Safari Bug fix
			return element;
		}
	}

	window.JSL["event"] = function(e) {
		return new _event_init(e);
	}
})();

/* :TODO:
 * remove() ?
 *
 *//**
 * Class: JSL.number
 * This holds the number based operations. I am not sure why I have included this in the main code base - it don't have a lot of practical uses. 
 * Arguments: number - The initial number - the original value
 */
(function() {
	function _number_init(number) {
		this.number = number;
		return this;
	}
	
	_number_init.prototype = {
		/**
		 * Calls the function provided as the argument the specified number of times. It also
		 *	gives the number of the current run as an argument to the user function.
		 * Example:
		 *	JSL.number(5).times(function(i) { alert("Run #"+i); }); //Executes the function 5 times
		 */
		"times":function(func) {
			var func = JSL._makeFunc(func,"i");
			
			return this._call(func, 0, this.number-1);
		},
		
		/**
		 * Calls the given function with the value of the current number as an argument.
		 * Arguments: upper_limit - The upper limit of the loop - the function will be executed while initial_number <= current_number <= upper_limit
		 * Example:
		 *	//Calls the function 8 times - the alerts will be 
		 *	//	Run #2, Run #3, Run#4 ... Run #9, Run#10
		 *	JSL.number(2).upto(10, function(i) {alert("Run #"+i);}); 
		 */
		"upto":function(upper_limit, func) {
			var func = JSL._makeFunc(func,"i");
			
			return this._call(func, this.number, upper_limit);
		},
		
		/**
		 * Function that could be used to round a number to a given decimal points. Returns the answer.
		 * Taken from http://www.openjs.com/scripts/maths/rounding_numbers.php
		 * Arguments :  decimal_points - The number of decimal points that should appear in the result
		 * Example: JSL.number(23.2833).round(2); //returns 23.28
		 */
		"round": function(decimal_points) {
			if(!decimal_points) return Math.round(this.number);
			if(this.number == 0) {
				var decimals = "";
				for(var i=0;i<decimal_points;i++) decimals += "0";
				return "0."+decimals;
			}
		
			var exponent = Math.pow(10, decimal_points);
			var num = Math.round((this.number * exponent)).toString();
			return Number(num.slice(0,-1*decimal_points) + "." + num.slice(-1*decimal_points));
		},
		
		/**
		 * Returns a random number between the number given as the argument.
		 * Arguments: upper_limit - The maximum value that can be returned by the function. Defaults to 100
		 * 			  lower_limit - The minimum value. Defaults to 0
		 * Example: JSL.number().random(5); // returns a number between 0 and 5.
		 * 			JSL.number().random(25, 20); // returns a number between 20 and 25.
		 */
		"random": function(upper_limit, lower_limit) {
			if(typeof upper_limit == "undefined") upper_limit = 100;
			if(typeof lower_limit == "undefined") lower_limit = 0;
			if(lower_limit > upper_limit) {
				var temp = lower_limit;
				lower_limit = upper_limit;
				upper_limit = temp;
			}
			return Math.floor(Math.random() * (upper_limit - lower_limit + 1)) + lower_limit;
		},
		
		/**
		 * This is where the function calls are made. Private function - used by both `times` and `upto`
		 */
		"_call": function(func, from, to) {
			var returns = [];
			
			if(from < to) {
				for(var i=from; i<=to; i++) returns.push(func.call(this, i));
			} else { //If the starting number is greater than the ending number, go the other way.
				for(var i=from; i>=to; i--) returns.push(func.call(this, i));
			}
			return JSL.array(returns);
		}
	}
	
	window.JSL["number"] = function(number) {
		return new _number_init(number);
	}
})();
/**
 * Class : JSL.ajax
 * This class has all the ajax functions.
 * Based on jxs V2.01.A - http://www.openjs.com/scripts/jx/
 * Example: JSL.ajax("http://www.example.com").load(function(data) {
 *	alert(data); //data has the data fetched from the given url
 * });
 * Arguments: URL - the url of the page to be loaded
 */
(function() {
	function _ajax_init(url) {
		this.url = url;
		this._init();
		if(!url) return false;
		return this;
	}
	
	_ajax_init.prototype = {
		"http"		: false, //HTTP Object
		"format"	: 'text',
		"callback"	: false, ///This is a user specified function
		"error"		: false,
		
		///Create a xmlHttpRequest object - this is the constructor. 
		"_getHTTPObject" : function() {
			var http = false;
			//Use IE's ActiveX items to load the file.
			if(typeof ActiveXObject != 'undefined') {
				try {http = new ActiveXObject("Msxml2.XMLHTTP");}
				catch (e) {
					try {http = new ActiveXObject("Microsoft.XMLHTTP");}
					catch (E) {http = false;}
				}
			//If ActiveX is not available, use the XMLHttpRequest of Firefox/Mozilla etc. to load the document.
			} else if (XMLHttpRequest) {
				try {http = new XMLHttpRequest();}
				catch (e) {http = false;}
			}
			return http;
		},
		
		/**
		 * This loads the URL provided in the constructor and calls the 'callback' user function 
		 *		with the data from the URL as its argument.
		 * Arguments:
		 *	callback - Function that must be called once the data is ready. [OPTIONAL]
		 *	format - The return type for this function. Could be 'xml','json' or 'text'. If it is json, 
		 *			the string will be 'eval'ed before it is returned it. Defaults to 'text'. [OPTIONAL]
		 *	method - GET or POST. Defaults to 'GET'. [OPTIONAL]
		 * Example:
		 * JSL.ajax("http://www.example.com/get_data.php?hello=world&foo=bar").load(function(data) {
		 * 		alert(data);
		 * 	}, "text", "POST");
		 */
		"load" : function (callback, format, method, opt) {
			var http = this._init(); //The XMLHttpRequest object is recreated at every call - to defeat Cache problem in IE
			var url = this.url;
			if(!http||!url) return;
	
			this.callback=callback;
			method = method||"GET";//Default method is GET
			format = format||"text";//Default return type is 'text'
			this.format = format.toLowerCase();
			method = method.toUpperCase();
			var ths = this;//Closure
			
			//XML Format need this for some Mozilla Browsers
			if(format == 'xml' && http.overrideMimeType) http.overrideMimeType('text/xml');
			
			//Kill the Cache problem in IE.
			var now = "uid=" + new Date().getTime();
			url += (url.indexOf("?")+1) ? "&" : "?";
			url += now;
	
			var parameters = null;
	
			if(method=="POST") {
				var parts = url.split("\?");
				url = parts[0];
				parameters = parts[1];
			}
			http.open(method, url, true);
	
			if(method=="POST") {
				http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
				http.setRequestHeader("Content-length", parameters.length);
				http.setRequestHeader("Connection", "close");
			}
	
			if(opt && opt.handler) { //If a custom handler is defined, use it
				http.onreadystatechange = opt.handler;
			} else {
				http.onreadystatechange = function () { /// [IGNORE] Call a function when the state changes.
					if(!ths) return;
					if (http.readyState == 4) {//Ready State will be 4 when the document is loaded.
						if(http.status == 200) {
							var result = "";
							if(http.responseText) result = http.responseText;
							//If the return is in JSON format, eval the result before returning it.
							if(ths.format.charAt(0) == "j") {
								//\n's in JSON string, when evaluated will create errors in IE
								result = result.replace(/[\n\r]/g,"");
								result = eval('('+result+')');
	
							} else if(ths.format.charAt(0) == "x") { //XML Return
								result = http.responseXML;
							}
	
							//Give the data to the callback function.
							if(ths.callback) ths.callback(result);
						} else {
							if(opt.loading_text) document.getElementsByTagName("body")[0].removeChild(opt.loading_text); //Remove the loading indicator element
							if(opt.loading_indicator && document.getElementById(opt.loading_indicator)) {
								document.getElementById(opt.loading_indicator).style.display="none"; //Hide the given loading indicator.
							}
							
							if(ths.error) ths.error(http.status);
						}
					}
				}
			}
			http.send(parameters);
		},
		
		/**
		 * bind is one all encompassing function for ajax. The first argument is an associative array and
		 * 		different details can be passed as that argument. First this hash must be created...
		 * 		<pre><code class="js">var options = {
		 * 			'onSuccess':alert,
		 * 			//other options go here...
		 * 		}</code></pre>
		 * 		Then it can be passed on to the bind() like this...
		 * 		<pre><code class="js">JSL.ajax("http://www.example.com/get_data.php?hello=world&amp;foo=bar").bind(options);</code></pre>
		 * 		The possible option values are listed below.
		 * Arguments: options - A associative array with these possible values.
		 * 		 - options['onSuccess'] - Function that should be called at success - ie. readyState=4 and status=200
		 * 		 - options['onError'] - Function that should be called at error
		 * 		 - options['format'] - Return type of the ajax data - could be 'xml','json' or 'text'. If none is specified, it will default to 'text'
		 * 		 - options['method'] - This decides with method should be used in sending the data - 'GET' or 'POST'. Defaults to 'GET'
		 * 		 - options['update'] - If the ID of a valid element is given here, then the ajax call will be made, the data fetched and fed into this element using innerHTML.
		 * 		 - options['loading_indicator'] - The id of the loading indicator. This will be set to display:block when the url is loading and to display:none when the data has finished loading.
		 * 		 - options['loading_text'] - HTML that would be inserted into the document once the url starts loading and removed when the data has finished loading. This will be inserted into a div with class name 'loading-indicator' and will be placed at 'top:0px;left:0px;'
		 * Example:
		 * 	JSL.ajax('data.php?fetch=true&num=42&name=marvin').bind({
		 *			"onSuccess":alert,
		 *			"onError":function(status){alert("Something went wrong. Error : "+status)},
		 *			"loading":"loading"
		 *		});
		 */
		"bind" : function(user_options) {
			var opt = {
				'onSuccess':false,
				'onError':false,
				'format':"text",
				'method':"GET",
				'update':"",
				'loading_indicator':"",
				'loading_text':""
			}
			for(var key in opt) {
				if(user_options[key]) {//If the user given options contain any valid option, ...
					opt[key] = user_options[key];// ..that option will be put in the opt array.
				}
			}
			opt.url = this.url;
			if(opt.onError) this.error = opt.onError;
	
			var div = false;
			if(opt.loading_text) { //Show a loading indicator from the given HTML
				if(opt.loading_indicator) div = document.getElementById(opt.loading_indicator); // If both loading_indicator and loading_text is given, use the 'loading_indicator' element as the holder for loading_text
				else {
					div = document.createElement("div");
					div.setAttribute("style","position:absolute;top:0px;left:0px;");
					div.setAttribute("class","loading-indicator");
					document.getElementsByTagName("body")[0].appendChild(div);
				}
				
				div.innerHTML = opt.loading_text;
				opt.loading_text=div;
			}
			if(opt.loading_indicator) document.getElementById(opt.loading_indicator).style.display="block"; //Show the given loading indicator.
			
			this.load(function(data) {
				if(opt.update) document.getElementById(opt.update).innerHTML = data;
				
				if(div && !opt.loading_indicator) document.getElementsByTagName("body")[0].removeChild(div); //Remove the loading indicator
				if(opt.loading_indicator) document.getElementById(opt.loading_indicator).style.display="none"; //Hide the given loading indicator.
				
				if(opt.onSuccess) opt.onSuccess(data);// Call the onSuccess function
			},opt.format,opt.method, opt);
		},
		
		"_init" : function() {return this._getHTTPObject();}
	}
	
	window.JSL["ajax"] = function(url) {
		return new _ajax_init(url);
	}
})();
	
/* :TODO:
 * In bind() - opt[onFetch] - call after the 'this.http.send(parameters)' has been made
 *
 */