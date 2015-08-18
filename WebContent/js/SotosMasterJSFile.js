if (document.referrer.indexOf("papazerveas.tk") > 0) {
    top.location = window.location.href;
}

position = 0;
function scrolltitle() {
	document.title = msg.substring(position, msg.length) + msg.substring(0, position);
	position++;
	if (position > msg.length) {
	 
		return;
		position = 0;
	}
		
	 window.setTimeout("scrolltitle()", 170);
}

$(document).ready(function() {
	  $('div.demo-show2> div').hide();
	  $('div.demo-show2> div:eq(1)').slideToggle('slow');
	  $('div.demo-show2> h3').click(function() {
	    var $nextDiv = $(this).next();
	    var $visibleSiblings = $nextDiv.siblings('div:visible');
	    if ($visibleSiblings.length ) {
	      $visibleSiblings.slideUp('fast', function() {
	        $nextDiv.slideToggle('slow');
	      });
	    } else {
	       $nextDiv.slideToggle('fast');
	    }
	  });

    sendIP();


    var filename = window.location.href.substr(window.location.href.lastIndexOf("/") + 1);
    if (filename == "index.html" ||filename == "") { filename = "indexEN.html" }

    if (filename.toLowerCase().indexOf("en") === -1) { var language = "GR"; var changelanguage = "EN"; }
    else { var language = "EN"; var changelanguage = "GR"; }
    filename = filename.substr(0, filename.length - 7);


    if (language == "EN") {
    	msg = "Sotiris Papazerveas - Personal Page ";
    	$('#bannerEN').html( "<div class='bA'><div class='cu'> " +
		    "<a href='mailto:papazerveas@hotmail.com?subject=Contact from Website' title='Send email'>Contact Us | </a>" +
		    "<a href=\"./" + filename + changelanguage + ".html \" title='Ελληνική έκδοση' >" +
		    " <img src='css/images/flag_" + changelanguage + ".jpg'  width='12' height='9' />" +
		    "</a></div><div class='toplogo'><a href='./index" + language + ".html' title='Sotiris Papazerveas'> " +
		    "<img src='css/images/transparent.gif'  width='380' height='50' border='0' /></a></div></div>"
		    );
    }
    else {
    	msg = "Σωτήρης Παπαζερβέας - Προσωπική Ιστοσελίδα ";
    	$('#bannerEN').html( "<div class=\"bA\"><div class=\"cu\"> " +
		    "<a href=\"mailto:papazerveas@hotmail.com?subject=Επικοινωνία από την Ιστοσελίδα \" title=\"Αποστολή email\" >Επικοινωνία | </a>" +
		    "<a href=\"./" + filename + changelanguage + ".html \" title=\"English Version\" >" +
		    " <img src=\"css/images/flag_" + changelanguage + ".jpg\"  alt=\"\" width=\"12\" height=\"9\" />" +
		    "</a></div><div class=\"toplogo\"><a href=\"./index" + language + ".html\" title=\"Σωτήρης Παπαζερβέας\"> " +
		    "<img src=\"css/images/transparent.gif\"  width=\"380\" height=\"50\" border=\"0\" /></a></div></div>"
		    );
    }
    

    
    scrolltitle();
    
    var page = function (page, EN, GR) {
        this.page = page;
        if (language == "EN") { this.title = EN; }
        if (language == "GR") { this.title = GR; }
    };

    var navPages = [];
    navPages.push(new page("index", "Home", "Αρχική Σελίδα"));
    navPages.push(new page("OnlineTools", "Online Tools", "Online Εργαλεία"));
    navPages.push(new page("OfflineTools", "Offline Tools", "Offline Εργαλεία"));
    navPages.push(new page("SAS_", "SAS Samples", "Δείγματα SAS"));
    navPages.push(new page("R_", "R Samples", "Δείγματα R"));
    navPages.push(new page("Contact", "Contact Info", "Στοιχεία Επικοινωνίας"));
    navPages.push(new page("Links", "Links", "Σύνδεσμοι"));
    navPages.push(new page("Visits_Check", "Site Analytics", "Αναλύσεις σελίδας"));
    navPages.push(new page("chat_", "Chat websocket", "Chat websocket"));
    
    var navHTML = "<ul class=\"leftnavigation\"> ";
    var selected = "";
    for (var i = 0; i < navPages.length; i++) {
        if (filename == navPages[i].page) selected = "id = 'selected'"; else selected = "";
        navHTML += " <li " + selected
                                + "><div align='right' ><a href='" +
		    			navPages[i].page + language + ".html'>"
		    			+ navPages[i].title
		    			+ "</a></div></li> ";
    }
    navHTML += "</ul>"

     $('#navpanEN').html( navHTML);

     $('#footerEN').html("<div class=\"footerArea\">" +
        "<div class=\"copyright\">&copy; 2012 Designed & Developed by Sotiris Papazerveas. | " +
        "<a href=\"http://html5.validator.nu/?doc=http://www.papazerveas.3owl.com/&showimagereport=yes&showsource=yes\" title=\"Validate HTML code\">HTML 5</a> | " +
        " <a href=\"http://jigsaw.w3.org/css-validator/\" title=\"Validate CSS code\">CSS 2.0</a>" +
        "<div style=\"position:fixed; right:10px ;bottom:10px\">Sotiris Papazerveas</div>" +
        "</div></div>");


    (function (i, s, o, g, r, a, m) {
        i['GoogleAnalyticsObject'] = r; i[r] = i[r] || function () {
            (i[r].q = i[r].q || []).push(arguments)
        }, i[r].l = 1 * new Date(); a = s.createElement(o),
  			m = s.getElementsByTagName(o)[0]; a.async = 1; a.src = g; m.parentNode.insertBefore(a, m)
    })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');
    var filename = window.location.href.substr(window.location.href.indexOf(".") + 1);
    filename = filename.substr(0, filename.indexOf("/"));
    ga('create', 'UA-42776397-1', filename);
    ga('send', 'pageview');

    LoadScript('./js/modal_popup.js');
    favico();

});

function LoadScript(scriptsource) {
    var head = document.getElementsByTagName('head')[0];
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.onreadystatechange = function () {
        // if (this.readyState == 'complete') { callFunctionFromScript(); }
    }
    script.src = scriptsource;
    head.appendChild(script);
    console.log(scriptsource + ' loaded');
}

function favico() {
    var link = document.createElement('link');
    link.type = 'image/x-icon';
    link.rel = 'shortcut icon';
    link.href = 'css/images/Stitlelogo.ico';
    document.getElementsByTagName('head')[0].appendChild(link);
}

 



function sendIP() {
	console.log('//online-papazerveas.rhcloud.com/GetIp');
	$.ajax({
		type: 'post',
		url:  '//online-papazerveas.rhcloud.com/GetIp',
		data: {
			store : 'n',
			print : 'y'
		},
		success: function (responsetext) {
			console.log(responsetext);
	        if (document.getElementById("response")) {
	            document.getElementById("response").innerText = responsetext;
	        }
		},
		error: function (request, status, error) {
			if (document.getElementById("response")) {
	            document.getElementById("response").innerText = request.responseText;
	        }
			console.log(request.responseText);
	    }
	});
};
