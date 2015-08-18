"use strict";
var connection;
var myMessages = [];
var myMessageIdx = 0;

var host = window.location.host;
if (document.location.hostname != "localhost") {
	host = "papazerveas.zapto.org";
}
host = "papazerveas.zapto.org";

$(function() {

	$("#username").keydown(function(e) {
		if (e.keyCode === 13) {
			connect();
		}
	});

	$('#disconnect').hide();
  	$(window).on('beforeunload', function() {
  		disconnect();
	});
 
	
	$("#disconnect").click(function() {
		var p = confirm("are you sure you want to disconnect?");
		if (!p) return;
		disconnect();
		$('#input').val('');
		$('#users').html('');

	});
});

function disconnect() {
	$('#status').text('');
	$('.allChatDivs').html('');
	$('#tooltip').html('');
	$('#disconnect').hide();
	$('#connect').show();
	$('#username').show();
	$('#input').attr('disabled', 'disabled');
	connection.close();
	connection = null;
}

function connect() {

	if (connection)
		return;
	$('#input').val('');
	$('#users').html('');
	var content = $('#content');
	content.html('');
	var input = $('#input');
	var status = $('#status');
	$('#disconnect').show();

	var myName = false;

	window.WebSocket = window.WebSocket || window.MozWebSocket;  
	if (!window.WebSocket) {  
		content.html($('<p>', {
			text : 'Sorry, but your browser doesn\'t support WebSockets.'
		}));
		input.hide();
		$('span').hide();
		return;
	}
	connection = new WebSocket('ws://' + host + '/Chat/Websocket');  
	var username = $("#username").val()
	$("#username").hide();
	$("#connect").hide();
	if (!username)
		return;
	connection.onopen = function(data) { 
		input.removeAttr('disabled');  
		connection.send(username); 
		input.attr('disabled', 'disabled');
		myName = username;
	};

	connection.onerror = function(error) {
		content.html($(
						'<p>',
						{
							text : 'Sorry, but there\'s some problem with your  connection or the server is down.'
						}));
	};

	connection.onmessage = function(message) {
		try {
			var json = JSON.parse(message.data);
		} catch (e) {
			console.log(e);
			console.log('Not a a valid JSON response: ', message.data);
			return;
		}

		if (json.type === 'color') {
			status.text(myName).css('color', json.data);
			input.removeAttr('disabled').focus().select();
		} else if (json.type === 'error') {
			status.text('error').css('color', 'red');
			input.attr('disabled', 'disabled').val(json.data);
			disconnect();
		} else if (json.type === 'history') {
			for (var i = 0; i < json.data.length; i++) {
				addMessage(json.data[i].author, json.data[i].text,
						json.data[i].color, new Date(json.data[i].time));
			}
		} else if (json.type === 'message') {
			input.removeAttr('disabled');
			addMessage(json.data.author, json.data.text, json.data.color,
					new Date(json.data.time));
		} else if (json.type === 'private_message') {
			input.removeAttr('disabled');
			console.log(json.data);;
			Private_Message(json.data);
		} else if (json.type === 'activeusers') {
			input.removeAttr('disabled');
			var usrhtml = ""
			for (var i = 0; i < json.data.length; i++) {
				if (json.data[i].user == myName) {
					usrhtml += '<p><span  style="color:' + json.data[i].color + '">'
							+ json.data[i].user + '</span>';
				} else {
					usrhtml += '<p><a class="pup" href="javascript:;" onclick="printjson(this)" data=\''
							+ JSON.stringify(json.data[i])
							+ '\'><span  style="color:'
							+ json.data[i].color
							+ '">' + json.data[i].user + '</span></a>';
				}
			}
			$("#users").html(usrhtml);
		} else {
			console.log('Wrong json Response: ', json);
		}
		content.scrollTop(content.prop("scrollHeight"));
	};

	input.keydown(function(e) {
		if (e.keyCode === 13) {
			var msg = $(this).val();
			if (!msg)
				return;
			connection.send(msg);
			myMessages.push(msg);
			myMessageIdx = myMessages.length;
			$(this).val('').attr('disabled', 'disabled');

		} else if (e.keyCode == '38') {// up arrow
			myMessageIdx--;
			if (myMessageIdx < 0)
				myMessageIdx = 0;
			$(this).val(myMessages[myMessageIdx]);
		} else if (e.keyCode == '40') {// down arrow
			myMessageIdx++;
			if (myMessageIdx > myMessages.length)
				myMessageIdx = myMessages.length;
			$(this).val(myMessages[myMessageIdx]);
		}
	});

	setInterval(function() {
		if (connection) {
			if (connection.readyState !== 1) {
				status.text('Error');
				input.attr('disabled', 'disabled').val(
						'Unable to comminucate with the WebSocket server.');
				disconnect();
			}
		}
	}, 5000);

	function addMessage(author, message, color, dt) {
		var author1 = author;
		if (author == myName) {
			color = "red";
			author1 = "me";
			message = "<span style=\"color:red\">" + message + "</span>";
		}
		content.append('<p><span style="color:' + color + '">' + author1
				+ '</span> @ ' + dtForm(dt) + ': ' + message + '</p>');
		if (author == myName) {
			content.scrollTop(content[0].scrollHeight);
		}
	}
};

function printjson(e) {
	var obj = JSON.parse($(e).attr('data'));
	var object = obj.decrec;
	var output = '';
	output += 'user' + ': ' + obj['user'] + '<br> ';
	output += 'color' + ': ' + obj['color'] + '<br> ';
	for ( var property in object) {
		output += property + ': ' + object[property] + '<br> ';
	}
	$('#input').val('/' + obj['user'] + ' ');

	var json = {
		author : obj['user'],
		message : '',
		color : obj['color'],
		from : '',
		to : '',
		time : new Date()
	}
	Private_Message(json);
	$('#tooltip').html(output);
}

function Private_Message(json) {

	var userName = json.author;
	var message = json.text;
	var color = json.color;
	var dt = new Date(json.time);
	var skipSend = false; 
	
	var me = 1;
	if (json.from == json.author)
		me = 0;
	var usrDiv = json.author.replace(/[^a-zA-Z0-9]/g, '_');
	if ($("div#" + usrDiv).length) {
		if (!$("div#" + usrDiv).is(":visible")) {
			$("div#" + usrDiv).show();
		}
	} else {
		var chatWindow = "<div id='"
				+ usrDiv
				+ "' class='chatDiv'>"
				+ "<div class='chatDivTitle'>"
				+ userName
				+ " <a href='javascript:;' style='float:right;color:white;' class='chatClose'>✕</a></div>"
				+ "<div class='textarea' style= 'height:170px;background: #ddd;' id='chatHistory'  ></div>"
				+ "<input class='textarea' type='text'   style='margin-top:5px;height:45px;' id='chatBox'   > "
				+ "</div>";
		$(".allChatDivs").append(chatWindow);
		connection.send("/" + userName + " getprivatemessages");
		skipSend = true;
	}

	$("div#" + usrDiv).find(".chatDivTitle").css('background-color', color)
			.css('color', 'white');
	$("div#" + usrDiv).find(".chatClose").click(function(event) {
		$(this).closest(".chatDiv").hide();
	});

	if (typeof message === 'string') {
		var oldChatHistory = $("#" + usrDiv).find("#chatHistory").html().trim();
		if (skipSend) return;
		if (me == 1) {
			$("div#" + usrDiv).find("#chatHistory").append(
					'<p><span  class="msgBck"  style="color:red">me:@ ' + dtForm(dt)
							+ ': ' + message+ '</span> </p>');
		}else{
			$("div#" + usrDiv).find("#chatHistory").append(
					'<p style="text-align:right;"><span class="msgBck" style="color:' + color + '">' + json.from
							+ ' @ ' + dtForm(dt) + ': ' + message
							+ '</span></p>');
		}
		var $charHistory = $("#" + usrDiv).find("#chatHistory");
		$charHistory.scrollTop($charHistory.prop("scrollHeight"));
	}

	$("div#" + usrDiv).find("#chatBox").off(); //remove listeners
	$("div#" + usrDiv).find("#chatBox").keyup(
			function(event) {
				var keycode = (event.keyCode ? event.keyCode : event.which);
				if (keycode == 13) {
					connection
							.send("/" + userName + " " + $(this).val().trim());
					/*
					$("div#" + usrDiv).find("#chatHistory").append(
							'<p><span class="msgBck" style="color:red">me:@ '
									+ dtForm(dt) + ': ' + $(this).val()
									+ '</span> </p>');
					*/
					$(this).val('');
					var $charHistory = $("#" + usrDiv).find("#chatHistory");
					$charHistory.scrollTop($charHistory.prop("scrollHeight"));
				}
				if (event.keyCode == 27) {
					$(this).closest(".chatDiv").hide();
				}
			});
}

function dtForm(dt) {
	return +(dt.getHours() < 10 ? '0' + dt.getHours() : dt.getHours()) + ':'
			+ (dt.getMinutes() < 10 ? '0' + dt.getMinutes() : dt.getMinutes())
}
