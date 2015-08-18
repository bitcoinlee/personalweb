var delay = 0;
var geo = new google.maps.Geocoder();
var dlm = ' | ';

window.onload =  function(){
	  $("#exportbutton").hide() ;
	}

function getAddress(search, callback) {

	var temp = search.split(",");
	var srchJson;
	var Prefix ;

    if ($("#menu").val() == "Coors") {
		  srchJson = { location: new google.maps.LatLng(temp[1], temp[2]) };
		  Prefix = temp[0] + '-' + temp[1] + '-' + temp[2];
	}else{
		srchJson = { address: temp[1] } ;
		Prefix = temp[0] + '-' + temp[1]  ;
	}

        geo.geocode( srchJson , function (results, status) {

            if (status == google.maps.GeocoderStatus.OK) {
                var pct = ((nextAddress - 1) * 100) / (addresses.length - 2);

                if (pct > 10) {
					$("#exportbutton").show() ;
                } else {
					$("#exportbutton").hide() ;
                }
                $("#process").html ( (nextAddress - 1) + " of " + (addresses.length - 2) + " Done: " + pct.toFixed(2) + '%</br></br>' );

				var res = {
					lat		: results[0].geometry.location.lat(),
					lng		: results[0].geometry.location.lng(),
					country : "",
					address : "",
					zip		: "",
					state	: "",
					city	: ""
				};



                for (var i = 0; i < results[0].address_components.length; i++) {
                    var addr = results[0].address_components[i];

                    if (addr.types[0] == 'country')
                        res.country = addr.long_name;
                    else if (addr.types[0] == 'street_address')
                        res.address += addr.long_name;
                    else if (addr.types[0] == 'establishment')
                        res.address += addr.long_name;
                    else if (addr.types[0] == 'route')
                        res.address += addr.long_name;
                    else if (addr.types[0] == 'postal_code')
                        res.zip = addr.short_name;
                    else if (addr.types[0] == ['administrative_area_level_1'])
                        res.state = addr.long_name;
                    else if (addr.types[0] == ['locality'])
                        res.city = addr.long_name;
                }
               $("#messages").append(
                						Prefix
                						+ dlm + res.lat
                						+ dlm + res.lng
                						+ dlm + res.country
                						+ dlm + res.state
                						+ dlm + res.city
                						+ dlm + res.zip
                						+ dlm + res.address
                						+ '<br>'
                						);
		  /*$.ajax({
				type: 'post',
				url: 'http://localhost:8080/Addresses/Address',
				dataType: 'JSON',
				data: {
				  jsonData: JSON.stringify(res)
				},
				success: function(data) {

				},
				error: function(data) {
					alert('fail');
				}
			});
*/
            }
            else {
                if (status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
                    nextAddress--;
                    //delay++;
                } else {
                    var reason = "Code " + status;
                    var msg = 'address="' + search + '" error=' + reason + '(delay=' + delay + 'ms)<br>';
                    $("#messages").append(msg);
                }
            }
            callback();
        }
        );
    }

var addresses = [];
var openFile = function (event) {

    var input = event.target;
    var reader = new FileReader();
    nextAddress = 1;
    delay =0;

    $("#messages").html(
						'Input'
						+ dlm + 'Lat'
						+ dlm + 'Long'
						+ dlm + 'Country'
						+ dlm + 'State'
						+ dlm + 'City'
						+ dlm + 'Zip Code'
						+ dlm + 'Address<br/>') ;

    reader.onload = function (event) {
        var reader = event.target;
        var text = reader.result;
        addresses = text.split("\n");
        for (var i = 0; i < addresses.length - 1; i++) {
            addresses[i] = addresses[i].substring(0, addresses[i].length - 1);
        };
        theNext();
    };
    reader.readAsText(input.files[0]);
};


var nextAddress = 1;
function theNext() {
    if (nextAddress < addresses.length - 1) {
        setTimeout('getAddress("' + addresses[nextAddress] + '",theNext)', delay);
        nextAddress++;
    }
}


function download(filename) {
    var pom = document.createElement('a');
    var addresses = $("#messages").html();
    addresses = addresses.split("<br>").join('\n').split(dlm).join(',');
    pom.setAttribute('href', 'data:data:application/csv;charset=utf-8,' + encodeURIComponent(addresses));
    pom.setAttribute('download', filename);
    pom.click();
}

function printObj(obj){
	for (var property in obj) {
	  console.log( property + ': ' + obj[property] );
	}
}