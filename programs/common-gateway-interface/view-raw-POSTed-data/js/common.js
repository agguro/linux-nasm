function addEvent(elm,event,fn,capture){JSL.dom(elm).on(event, fn);}
function findTarget(e){return JSL.event(e).getTarget();}
function getElementsByCSS(selector){return JSL.dom(selector).get();}
function getElementsByClassName(classname,tag){if(!tag)var tag="";return getElementsByCSS(tag+"."+classname);}
function toggle(item,state){if(state)item.style.display=state;else item.style.display=(item.style.display=="block")?"none":"block";}
function stopEvent(e){return JSL.event(e).stop();}

//Custom Stuff
var rel = "";

function evaluate(id) {
	var code = '';
	var result = '';
	var ele = $(id);
	if(ele.tagName == "TEXTAREA") code = ele.value;
	else code = ele.innerHTML;
	
	try {
		result = eval(code);
	} catch(E) {
		alert("JavaScript Error in code : " + E);
	}
	if(result) {
		if(ele.tagName == "TEXTAREA") ele.value = result;
		else ele.innerHTML = result;
	}
}

function replyTo(id,subject) {
	$('replyto').value = id;
	$('replyto-message').show();
	$('replyto-message').innerHTML = "Reply to "+subject+"'s comment. <a href='#comment_text' onclick='noReply()'>Don't Reply</a>";
}
function noReply() {
	$('replyto-message').hide();
	$('replyto').value = 0;
}

function siteInit() {
	if(typeof window.init == "function") init();
	
	var email = 'bin'+ 'nyva';
	var email_links = getElementsByClassName("email-encrypt","span");
	email += '@gma' + 'il.com';
	for(var i=0;i<email_links.length;i++) {
		email_links[i].innerHTML = '<a href="mailto:'+email+'">'+email+'</a>';
		email_links[i].className = "";
	}
	
	//Enables the evaluatetion textareas
	var evals = document.getElementsByName("test_evaluation_code");
	for(var i=0;i<evals.length;i++) {
		var ev = evals[0];
		addEvent(ev,"submit",function(e) {
			e = e ||window.event;
			var form_area = findTarget(e);
			var code = form_area.getElementsByTagName("textarea")[0].value;
			
			//Find the result area.
			var message_area = false
			if(form_area.getElementsByTagName("div")) {
				var result_areas = form_area.getElementsByTagName("div");
				for(var j=0; j<result_areas.length; j++) {
					if(result_areas[j].className.match(/result/)) {
						message_area = result_areas[j];
						break;
					}
				}
			}

			try {
				var result = eval(code)||"Code Executed successfully";
				if(message_area)
					message_area.innerHTML = "<div class='message-success'>"+result+"</div>";
				else alert(result);
			} catch (E) {
				var result = "Error : " + E;
				if(message_area)
					message_area.innerHTML = "<div class='message-error'>"+result+"</div>";
				else alert(result);
			}
			stopEvent(e);
		});
	}

	//Find relation
	var org_loc= location.href.toString();
	var sl=0,in_comp=0;
	if(!org_loc.indexOf("http://www.openjs.com")) loc=org_loc.replace("http://www.openjs.com","")
	else loc=org_loc;
	for(var i=0;i<loc.length;i++) {
	if(loc.charAt(i)=="/") {
	if(sl) rel=rel+"../";
	sl++;}
	}

	//Protection against Spam bots
	if(document.getElementById("commenter")) {
		$("commenter").checked = false;
		$("bot-protection").hide();
	}
}
JSL.dom(window).load(siteInit);
