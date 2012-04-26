// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

document.observe("dom:loaded", function(){
  br_main_office_location = new google.maps.LatLng(br_office_infos.geo_location.lat, br_office_infos.geo_location.lng);
  initialize_tracking_map();
  show_icons();
});
var global_z_index = 0;

function Label(opt_options) {
 // Initialization
 this.setValues(opt_options);
  this.count = 1;
 // Label specific
 var span = this.span_ = document.createElement('span');
 span.style.cssText = 'z-index:100000000;position: relative; left: -50%; top: -8px; ' +
                      'white-space: nowrap; border: 1px solid gray; ' +
                      'padding: 2px; background-color: white; font-weight:bold;';

 var div = this.div_ = document.createElement('div');
 div.appendChild(span);
 div.style.cssText = 'position: absolute; display: none;';
};
Label.prototype = new google.maps.OverlayView;

// Implement onAdd
Label.prototype.onAdd = function() {
 var pane = this.getPanes().overlayLayer;
 pane.appendChild(this.div_);

 // Ensures the label is redrawn if the text or position is changed.
 var me = this;
 this.listeners_ = [
   google.maps.event.addListener(this, 'position_changed',
       function() { me.draw(); }),
   google.maps.event.addListener(this, 'text_changed',
       function() { me.draw(); })
 ];
};

// Implement onRemove
Label.prototype.onRemove = function() {
 this.div_.parentNode.removeChild(this.div_);

 // Label is removed from the map, stop updating its position/text.
 for (var i = 0, I = this.listeners_.length; i < I; ++i) {
   google.maps.event.removeListener(this.listeners_[i]);
 }
};

// Implement draw
Label.prototype.draw = function() {
 var projection = this.getProjection();
 var position = projection.fromLatLngToDivPixel(this.get('position'));
 var div = this.div_;
 div.style.zIndex = 100000;
 div.style.left = position.x + 'px';
 div.style.top = position.y - 60 + 'px';
 div.style.display = 'block';

 this.span_.innerHTML = this.count;
};


String.prototype.hashCode = function(){
  var hash = 0;
  if (this.length == 0) return hash;
  for (i = 0; i < this.length; i++) {
    char = this.charCodeAt(i);
    hash = ((hash<<5)-hash)+char;
    hash = hash & hash; // Convert to 32bit integer
  }
  return hash;
}

function hash_color(title){
  return (Math.abs(title.hashCode() % (1<<24))).toString(16);
}

var map;
var geocoder;
var br_main_office_location;

function seller_shipped_item(item_struct){
  return item_struct.status > 1
}

function arrived_from_seller(item_struct){
  return item_struct.status > 2
}

function shipped_to_customer(item_struct){
  return item_struct.status > 3; 
}

function initialize_tracking_map(){

  var stylers = [
  {
    featureType: "administrative.country",
    stylers: [
      { hue: "#ffb300" },
      { visibility: "on" }
    ]
  },{
    featureType: "administrative.province",
    stylers: [
      { visibility: "on" }
    ]
  },{
    featureType: "road",
    stylers: [
      { visibility: "off" }
    ]
  },{
    featureType: "transit",
    stylers: [
      { visibility: "off" }
    ]
  },{
    featureType: "poi",
    stylers: [
      { visibility: "off" }
    ]
  },{
    featureType: "landscape",
    stylers: [
      { visibility: "off" }
    ]
  },{
    stylers: [
      { hue: "#ff5e00" },
      { saturation: 68 }
    ]
  },{
    featureType: "administrative.locality",
    stylers: [
      { visibility: "off" }
    ]
  }
  ];


  //BAYRU OFFICE COORDINATES
  //br_main_office_location = new google.maps.LatLng(32,-101);
  var tracking_style_map = new google.maps.StyledMapType(stylers,
      {name: "BayRu Style Map"});
  var myOptions = {
          center: br_main_office_location,
          zoom: 4,
          mapTypeControlOptions: {
            mapTypeIds: [google.maps.MapTypeId.ROADMAP, 'interactive_styled_map']
          }
        };
  geocoder = new google.maps.Geocoder();
  map = new google.maps.Map($("map_canvas"), myOptions);
  map.mapTypes.set('interactive_styled_map', tracking_style_map);
  map.setMapTypeId('interactive_styled_map');
  icon_ops.map = map;
}

var icon_ops = { map: null, position: null, animation: google.maps.Animation.DROP, zIndex: 0 }
var draw_office_icon = false;

function show_icons(){
  //Draw item icons
  order_item_infos.each(function(item_struct){
    add_item_icons_to_map(item_struct);
  });
  //Draw office icon
  if(draw_office_icon){
    draw_office();
  }
  shipments.each(function(shipment){
    draw_shipments(shipment);
  });
}

function draw_shipments(shipment){
  var prev_geo_location;
  shipment.shipment_tracking_logs.each(function(stl, i){
    var color = shipment.shipment_tracking_logs.length - 1 == i ? "yellow" : "gray";
    icon_ops.icon = new google.maps.MarkerImage("/images/interactive_map_icons/plane_" + color + ".png", null, null, null, new google.maps.Size(32,40) );
    if(stl.lat && stl.lng){
      stl.geo_location = new google.maps.LatLng(stl.lat, stl.lng);
      icon_ops.position = stl.geo_location
      var shipment_marker = new google.maps.Marker(Object.clone(icon_ops));  
      var iwc = "<table><tr><th>Count</th><th>Title</th><th>Image</th><th>Status</th></tr>\n"
          shipment.order_items.each(function(oi, i){
            iwc += "<tr><td>" + (i + 1) + "</td><td>" + oi.title + "</td><td><img onerror='this.src=\"/images/thumb_no_image.gif\"' src='" + oi.image_url + "' width=40</></td><td>" + status_names[oi.status] + "</td></tr>\n"
          }).join("\n") + "</table>";
        var info_window = new google.maps.InfoWindow({
            content: iwc
          });

          google.maps.event.addListener(shipment_marker, 'click', function() {
            info_window.open(map, shipment_marker);
          });

      
      if(prev_geo_location && i > 0){
        draw_line(shipment.tracking_number, [prev_geo_location, stl.geo_location], 4);
      }
      prev_geo_location = stl.geo_location;
    }
  });
}

function draw_office(){
  icon_ops.position = br_main_office_location;
  icon_ops.zIndex++;
  var color = br_office_infos.order_items.length > 0 ? "yellow" : "gray";
  icon_ops.icon = new google.maps.MarkerImage("/images/interactive_map_icons/br_office_" + color + ".png", null, null, null, new google.maps.Size(32,40) );
  var office_marker = new google.maps.Marker(Object.clone(icon_ops));

  var label = document.createElement("div");
  label.style.cssText = "border: 1px solid black;; padding: 5px;";
  label.innerHTML = br_office_infos.order_items.length;

  var label_options = { content: label,
                    maxWidth: 0,
                    pixelOffset: new google.maps.Size(-15, -70),
                    zIndex: null,
                    boxStyle: { opacity: 1, fontWeight: 'bold', backgroundColor: '#FFFFFF' }, 
                    closeBoxURL: "" };
  var ib = new InfoBox(label_options);
  ib.open(map, office_marker);
  var iwc = "<table><tr><th>Count</th><th>Title</th><th>Image</th><th>Status</th></tr>\n"
    br_office_infos.order_items.each(function(oi, i){
      iwc += "<tr><td>" + (i + 1) + "</td><td>" + oi.title + "</td><td><img onerror='this.src=\"/images/thumb_no_image.gif\"' src='" + oi.image_url + "' width=40</></td><td>" + status_names[oi.status] + "</td></tr>\n"
    }).join("\n") + "</table>";
  var info_window = new google.maps.InfoWindow({
      content: iwc
    });

    google.maps.event.addListener(office_marker, 'click', function() {
      info_window.open(map,office_marker);
    });
}

function draw_line(color_seed, points, weight){
  if(!weight)
    weight = 3;
  var path = new google.maps.Polyline({
    path: points,
      strokeColor: hash_color(color_seed),
      strokeOpacity: 1,
      strokeWeight: weight
    });
  path.setMap(map);
}


function add_item_icons_to_map(item_info){
  //Make midway a bit random 
  with(item_info){
    var info_window_content = 
        "<table class='info_window'>" +
          "<tr>" +
            "<th>Title</th><td>_TITLE_</td>" +
          "</tr>" +
          "<tr>" +
            "<th>Last Status</th><td>_STATUS_</td>" +
          "</tr>" +
          "<tr>" +
            "<td>" +
              "<img onerror='this.src=\"/images/thumb_no_image.gif\"' src='_IMAGE_URL_' height=40/>" +
            "</td>" +
          "</tr>" +
      "</table>";

    var local_w_c = info_window_content.gsub("_TITLE_", order_item.title);
    local_w_c = local_w_c.gsub("_STATUS_", status_names[order_item.status]);
    if(order_item.image_url)
      local_w_c = local_w_c.gsub("_IMAGE_URL_", order_item.image_url);

    if(geo_locations.seller){
      var color = order_item.status == 1 ? "yellow" : "gray";
      icon_ops.icon = new google.maps.MarkerImage("/images/interactive_map_icons/item_" + color + ".png", null, null, null, new google.maps.Size(32,40) );
      var offset = (order_item.title.hashCode() % 10) * 0.1;
      geo_locations.seller.lat += offset;
      geo_locations.seller.geo_location = new google.maps.LatLng(geo_locations.seller.lat, geo_locations.seller.lng);
      icon_ops.position = geo_locations.seller.geo_location;
      icon_ops.zIndex++;
      var l_icon_ops = Object.clone(icon_ops);
      l_icon_ops.title = "Title: " +order_item.title;
      var seller_marker = new google.maps.Marker(l_icon_ops);

      var info_window = new google.maps.InfoWindow({
        content: local_w_c
      });
      google.maps.event.addListener(seller_marker, 'click', function() {
        info_window.open(map,seller_marker);
      });
    }
    if(geo_locations.midway){
      //To spread out items that are dense
      //Draw stuff on the map
      geo_locations.midway.geo_location = new google.maps.LatLng(geo_locations.midway.lat, geo_locations.midway.lng);
      
      var color = order_item.status == 2 ? "yellow" : "gray";
      icon_ops.icon = new google.maps.MarkerImage("/images/interactive_map_icons/truck_" + color + ".png", null, null, null, new google.maps.Size(32,40) );
      icon_ops.position = geo_locations.midway.geo_location;
      icon_ops.zIndex++;

      var l_icon_ops = Object.clone(icon_ops);
      l_icon_ops.title = "Title: " + order_item.title;
      var midway_maker = new google.maps.Marker(l_icon_ops);
      //draw arrow to midway
      draw_line(order_item.title, [geo_locations.seller.geo_location, geo_locations.midway.geo_location]);


      var info_window = new google.maps.InfoWindow({
        content: local_w_c
      });

      google.maps.event.addListener(midway_maker, 'click', function() {
        info_window.open(map,midway_maker);
      });
      
    }
    if(order_item.status >= 3){
      draw_office_icon = true;
      //draw arrow to office
      draw_line(order_item.title, [geo_locations.midway.geo_location, br_main_office_location]);
    }
  }
}


/*
  paths.push(address_structs);
  collect_geocodes_and_show(item_struct)
  function collect_geocodes_and_show(item_struct){

    function resolve_geocode(_callback){
      geocoder.geocode( { 'address': address_struct.address}, function(results, status) {
      if(status == google.maps.GeocoderStatus.OK) {
        var loc = results[0].geometry.location;
        //To spread out items that are dense
        var offset = (item_struct.title.hashCode() % 10) * 0.1;
        address_struct.location = new google.maps.LatLng(item_struct.seller_lat + offset, item_struct.seller_lng);
        //address_struct.location = results[0].geometry.location;
  
        _callback();
      } else {
        alert("Geocode was not successful for the following reason: " + status); }
      })
    }

    function add_midway_office_or_further(){
      var prev_struct = Object.clone(address_structs.last());
      prev_struct.location = midway_location(prev_struct.location, br_main_office_location);
      prev_struct.type = "MIDWAY_SELLER";
      address_structs.push( prev_struct );
      if(arrived_from_seller(item_struct)){
        address_structs.push( {location: br_main_office_location, type: "BR_MAIN_OFFICE", db_id: 0, sequence: 0} );
      }
      add_icons();
    }

    //EXTRACT SELLER ADDRESS
    if(!item_struct.seller_country.empty()){
      var address_struct = {address: item_struct.seller_country, type: "SELLER", location: null, db_id: id, sequence: id};
      if(item_struct.seller_country == "US"){
        if(item_struct.seller_zip_code.search(/^\d+$/) != -1){
          address_struct.address = item_struct.seller_zip_code + ", " + address_struct.address;
        }
      } 
      address_structs.push(address_struct);
      //RESOLVE SELLER ADDRESS, and figure out what to do next
      resolve_geocode(seller_shipped_item(item_struct) ? add_midway_office_or_further : add_icons);
    }
    function add_icons(){
      address_structs.each(function(address_struct, i){
        var icon_ops = {
            map: map,
            position: address_struct.location,
            animation: google.maps.Animation.DROP,
            zIndex: global_z_index++
          }

        if(address_struct.type == "BR_MAIN_OFFICE"){ 
          with(google.maps){
            icon_ops.icon = new MarkerImage("/images/shield.png", null, null, null, new Size(32,40) );
            icon_ops.zIndex = 10000;
          }
        }

        points[p_id(address_struct)] = points[p_id(address_struct)] || {};
        window.setTimeout(function(){
          var point = points[p_id(address_struct)];
            if(!point.marker)
              point.marker = new google.maps.Marker(icon_ops);
            
            if(address_struct.type == "BR_MAIN_OFFICE"){
              if(point.label_content){
                point.label_content.innerHTML = find_nodes_by_type_and_sequence( address_struct.type, 0 ).length;
              }
              else{
                point.label_content = document.createElement("div");
                point.label_content.style.cssText = "border: 1px solid black;; padding: 5px;";
                point.label_content.innerHTML = find_nodes_by_type_and_sequence( address_struct.type, 0 ).length;

                var myOptions = {
                  content: point.label_content
                  ,maxWidth: 0
                  ,pixelOffset: new google.maps.Size(-15, -70)
                  ,zIndex: null
                  ,boxStyle: { 
                  opacity: 1,
                  fontWeight: 'bold',
                  backgroundColor: '#FFFFFF'
                 },
                closeBoxURL: ""
              };
              var ib = new InfoBox(myOptions);
              ib.open(map, point.marker);
              }
            }
          }, 200 * i
        )

          //Only draw arrow for the second point in the path
          if(i){
            //LAT,LNG-> INCREASE /\ increase
            l1 =  address_structs[i-1].location;
            l2 = address_structs[i].location;
            var angle = Math.atan((l2.lng() - l1.lng()) / (l2.lat() - l1.lat()));
            angle *= (180 / Math.PI);
            angle = angle < 0 ? (360 + angle): angle;

            if(l1.lat() > l2.lat())
              angle += 180;

            angle %= 360;
            if(!points[p_id(address_struct)].arrow || address_struct.type == "BR_MAIN_OFFICE")
              points[p_id(address_struct)].arrow = new ArrowOverlay(map, address_struct.location, angle, item_path_color(item_struct), 1);
          }
        }
      )
      var path_points = address_structs.map(function(address_struct){
        return address_struct.location;
      })
      
    }
  }
  
}
*/
