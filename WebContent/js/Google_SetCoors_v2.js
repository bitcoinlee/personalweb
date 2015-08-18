var simpleGoogleMapsApiExample = simpleGoogleMapsApiExample || {};

function download(filename) {
    var pom = document.createElement('a');
    var text = document.getElementById('tempres').innerHtml;

    console.log(text);
    pom.setAttribute('href', 'data:data:application/csv;charset=utf-8,' + encodeURIComponent(text));
    pom.setAttribute('download', filename);
    pom.click();
}




var openFile = function (event) {

    var myArray = [];
    var input = event.target;
    var reader = new FileReader();
    

    reader.onload = function (event) {
        var reader = event.target;
        var text = reader.result;

        myArray = text.split("\n");
        for (var i = 0; i < myArray.length - 1; i++) {
            myArray[i] = myArray[i].substring(0, myArray[i].length - 1);
        };
        $(document).ready(function () {
            "use strict";
            simpleGoogleMapsApiExample.map($("#map")[0], myArray);
        });
    };
    reader.readAsText(input.files[0]);
};


simpleGoogleMapsApiExample.map = function (mapDiv, myArray) {
    "use strict";

    var createMap = function (mapDiv, coordinates) {
        var mapOptions = {
            center: coordinates,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            zoom: 7
        };

        return new google.maps.Map(mapDiv, mapOptions);
    };

    var addMarker = function (map, coordinates) {
        var markerOptions = {
            clickable: true,
            map: map,
            position: coordinates
        };

        return new google.maps.Marker(markerOptions);
    };

    var addCircle = function (map, coordinates, accuracy) {
        var circleOptions = {
            center: coordinates,
            clickable: false,
            fillColor: "blue",
            fillOpacity: 0.15,
            map: map,
            radius: accuracy,
            strokeColor: "blue",
            strokeOpacity: 0.3,
            strokeWeight: 2
        };

        return new google.maps.Circle(circleOptions);
    };



    InitializeMap();
    var ltlng = [];
    var Desc = [];


    for (var i = 1; i < myArray.length - 1; i++) {

        var temp = myArray[i].split(",");

        Desc.push("<b>Description:</b> " + temp[0] + "<br /><b>Lat:</b> " + temp[1] + "  <b>Long:</b> " + temp[2]);
        ltlng.push(new google.maps.LatLng(temp[1], temp[2]));

    };

    document.getElementById('tempres').innerHtml = "";

    for (var i = 0; i <= ltlng.length; i++) {


        addressLatLng(ltlng[i], Desc[i], 'all', function (address) {

            temp = address.split('<br />')
            document.getElementById('tempres').innerHtml = document.getElementById('tempres').innerHtml + '\n' + temp;

            // alert(document.getElementById('tempres').innerHtml)
        });
    }


    function addressLatLng(coordinates, desc, type, callback) {

        var geocoder = new google.maps.Geocoder();
        var tempresult = "";

        geocoder.geocode({
            location: coordinates
        }, function (results, status) {
            if (status === google.maps.GeocoderStatus.OK && results[0]) {

                if (type == "address") { tempresult = 'Address: ' + results[0].formatted_address; }
                else {
                    var address = "", city = "", state = "", zip = "", country = "";


                    for (var i = 0; i < results[0].address_components.length; i++) {
                        var addr = results[0].address_components[i];

                        if (addr.types[0] == 'country')
                            country = addr.long_name;
                        else if (addr.types[0] == 'street_address') // address 1
                            address = address + addr.long_name;
                        else if (addr.types[0] == 'establishment')
                            address = address + addr.long_name;
                        else if (addr.types[0] == 'route')  // address 2
                            address = address + addr.long_name;
                        else if (addr.types[0] == 'postal_code')       // Zip
                            zip = addr.short_name;
                        else if (addr.types[0] == ['administrative_area_level_1'])       // State
                            state = addr.long_name;
                        else if (addr.types[0] == ['locality'])       // City
                            city = addr.long_name;
                    }

                    tempresult = '<div style="width: 280px; color:#000000;" >' + desc + '<br /> <b>Country:</b> ' + country + '<br /><b>State:</b> ' + state + '<br /><b>City:</b> ' + city + '<br /> <b>Zip:</b> ' + zip + '<br /> <b>Address:</b> ' + address + '</div>';
                    // console.log(tempresult);
                }
                callback(tempresult);
            }
            else {
                tempresult = '<div style="width: 280px; color:#000000;" >' + desc + '<br /><b>No further Information Available from Google</b>' + '</div>';
                callback(tempresult);
                /*  alert("Geocoder failed due to: " + status);*/
            }
        });
    };




    var map = createMap(mapDiv, ltlng[0]);
    for (var i = 0; i <= ltlng.length; i++) {

        var marker = new google.maps.Marker({
            map: map,
            position: ltlng[i]
        });

        (function (i, marker) {

            var infowindow = new google.maps.InfoWindow({ maxWidth: 320 });
            google.maps.event.addListener(marker, 'click', function () {

                //   var infowindow = new google.maps.InfoWindow({ maxWidth: 320 });
                    addressLatLng(ltlng[i], Desc[i], 'all', function (address) {
                        infowindow.setContent(address);
                    });
                    infowindow.open(map, marker);
            });

        })(i, marker);

        addCircle(map, ltlng[i], 5);
    }


};


function InitializeMap() {
    var latlng = new google.maps.LatLng(30.756, 25.986);
    var myOptions =
        {
            zoom: 3,
            center: latlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
    map = new google.maps.Map(document.getElementById("map"), myOptions);
}
window.onload = InitializeMap;


function gmapPrint() {
    window.print();
    /*
    var content = window.document.getElementById("map");
    var newWindow = window.open();
    newWindow.document.write(content.innerHTML);
    newWindow.print();
    */
}
