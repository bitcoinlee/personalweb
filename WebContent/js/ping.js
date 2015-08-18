function sleep(milliseconds) {
	var start = new Date().getTime();
	for (var i = 0; i < 1e7; i++) {
		if ((new Date().getTime() - start) > milliseconds) {
			break;
		}
	}
}

function pingIp(ip, pingsum, TotalLoops, loop, callback){
	var ping1 = $.now();
	$.ajax({
		   type: "HEAD",
		   url: "http://" + ip,
		   cache: false,
		   crossDomain:true,
		   
		   error: function( objAJAXRequest, strError ){
			    
			   /*   callback( {
			 		'ip': ip,
					'pingsum' : -1,
					'loop' : loop,
					'TotalLoops': TotalLoops,
					'avg_ping': -1
				} );*/
		   },
		   complete: function () {
			ping = $.now() - ping1;
			pingsum += ping;
			if(loop < TotalLoops){
				loop++;
				pingIp(ip, pingsum, TotalLoops, loop, callback);
			}		
			else callback( {
				 		'ip': ip,
						'pingsum' : pingsum,
						'loop' : loop,
						'TotalLoops': TotalLoops,
						'avg_ping': pingsum/loop
					} );
		    }
		 });  
}

$(window).on('load', function () {
	
 $(".contentleft div.link").each(function () {

  // sleep(50);
   var ip = $(this).attr("value");
   var $_e = $(this) ;
   $_e
	.text("Offline")
	.css({ "color": "red" });
   
 	pingIp(ip, 0 , 5 , 0 , function(data){
 			var avg = data.avg_ping;
 			var ct = data.loop;
			 if (avg < 250) {
				 $_e
			        .text("Online - ping: " + avg.toFixed(2) + " ms (on " + ct + "tests)")
			        .css({ "color": "green" });
			    } else  {
			    	$_e
			    	.text("Online - ping: " + avg.toFixed(2) + " ms (on " + ct + "tests)")
			    	.css({ "color": "orange" });
			    }  
		} )
  });
});
