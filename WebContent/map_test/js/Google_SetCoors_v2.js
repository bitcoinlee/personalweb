var simpleGoogleMapsApiExample = simpleGoogleMapsApiExample || {};


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
            simpleGoogleMapsApiExample.map($("#map")[0], myArray );
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

    var infoWindowVisible = (function () {
        var currentlyVisible = false;

        return function (visible) {
            if (visible !== undefined) {
                currentlyVisible = visible;
            }

            return currentlyVisible;
        };
    } ());

    var addInfoWindowListeners = function (map, marker, infoWindow) {
        google.maps.event.addListener(marker, "click", function () {
            if (infoWindowVisible()) {
                infoWindow.close();
                infoWindowVisible(false);
            } else {
                infoWindow.open(map, marker);
                infoWindowVisible(true);
            }
        });

        google.maps.event.addListener(infoWindow, "closeclick", function () {
            infoWindowVisible(false);
        });
    };

    var addInfoWindow = function (map, marker, address) {
        var infoWindowOptions = {
            content: address,
            maxWidth: 2000,
            maxHeight: 2000
        };
        var infoWindow = new google.maps.InfoWindow(infoWindowOptions);

        addInfoWindowListeners(map, marker, infoWindow);

        return infoWindow;
    };




    var initialize = function (mapDiv, latitude, longitude, accuracy) {
        var coordinates = new google.maps.LatLng(latitude, longitude);
        var map = createMap(mapDiv, coordinates);
        var marker = addMarker(map, coordinates);
        var geocoder = new google.maps.Geocoder();

        addCircle(map, coordinates, accuracy);

        geocoder.geocode({
            location: coordinates
        }, function (results, status) {
            if (status === google.maps.GeocoderStatus.OK && results[0]) {
                marker.setClickable(true);

                addInfoWindow(map, marker, results[0].formatted_address);


            }
        });
    };
    /*
    initialize(mapDiv, 37.954060, 23.745601, 5);
    */


    InitializeMap();
    var ltlng = [];
    var Desc = [];


    for (var i = 1; i < myArray.length - 1; i++) {

        var temp = myArray[i].split(",");

        Desc.push("Description: " + temp[0] + " <br>Lat: " + temp[1] + " <br>Long: " + temp[2]);
        ltlng.push(new google.maps.LatLng(temp[1], temp[2]));

    };



    function addressLatLng(coordinates, callback) {

        var geocoder = new google.maps.Geocoder();
        var tempresult = "";

        geocoder.geocode({
            location: coordinates
        }, function (results, status) {
            if (status === google.maps.GeocoderStatus.OK && results[0]) {
                tempresult = results[0].formatted_address;
                callback(tempresult);
            }
            else {
                tempresult = 'NA';
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

            google.maps.event.addListener(marker, 'click', function () {

                var infowindow = new google.maps.InfoWindow();

                 addressLatLng(ltlng[i], function (address) {
                     infowindow.setContent("Address:" + address + "<br />" + Desc[i]);
                });

                infowindow.open(map, marker);
            });

        })(i, marker);
    }





    for (var i = 0; i < ltlng.length; i++) {

        /*   var marker = addMarker(map, ltlng[i]); */
        addCircle(map, ltlng[i], 5);
        console.log(i + " : " + ltlng[i].lat() + " , " + ltlng[i].lng());

    };


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