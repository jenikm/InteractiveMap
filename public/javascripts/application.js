// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

document.observe("dom:loaded", function(){
  initialize_tracking_map();
});

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
  return (Math.abs(title.hashCode() % (1<<24)))
}

function setup_multiple_selection(options){
    var select_multiple_two = new Control.SelectMultiple(options.value_id,options.options_id,{  
        checkboxSelector: 'table tr td input[type=checkbox]',  
        nameSelector: 'table tr td.name',  
        afterChange: function(){  
            if(select_multiple_two && select_multiple_two.setSelectedRows)  
                select_multiple_two.setSelectedRows();  
        }  
    });  
      
    //adds and removes highlighting from table rows  
    select_multiple_two.setSelectedRows = function(){  
        this.checkboxes.each(function(checkbox){  
            var tr = $(checkbox.parentNode.parentNode);  
            tr.removeClassName('selected');  
            if(checkbox.checked)  
                tr.addClassName('selected');  
        });  
    }.bind(select_multiple_two);  
    select_multiple_two.checkboxes.each(function(checkbox){  
        $(checkbox).observe('click',select_multiple_two.setSelectedRows);  
        $(checkbox).observe('click',function(){
          $(checkbox).value.split(",").each(function(elem){
            if($(checkbox).checked){
              item_list.add_to_list(elem);
            }
            else
              item_list.remove_from_list(elem);
            }.bind(this))
        }.bind(this));  
    });  
    select_multiple_two.setSelectedRows();  
      
    //link open and closing  
    $(options.options_id + "_toggle").observe('click',function(event){  
        if(!this.container.visible()){
          new Effect.BlindDown(this.container,{  
              duration: 0.3,
              afterFinish:function(){$(this.container).style.overflow='auto'}.bind(this)
          });  
        }
        else{
          new Effect.BlindUp(this.container,{  
              duration: 0.3  
          });
        }
        Event.stop(event);  
        return false;  
    }.bindAsEventListener(select_multiple_two));  
  }

var ItemList = Class.create({
  initialize: function(content_id, database_id){
    this.item_ids = []
    this.draggables = {};
    this.content_id = content_id;
    this.outer_content = $(content_id);
    this.database = $(database_id);
  },
  get_html_id: function(item_id){
    return 'picked_item_' + item_id;
  },
  add_to_list: function(item_id){
    if(!this.item_ids.include(item_id)){
       
      this.item_ids.push(item_id);
      var data_set_item = this.database.select("div#data_set_item_" + item_id).first();
      var item_picture = new Element("img", {'src': data_set_item.readAttribute("data-image_url"), 'onerror': "this.src = '/images/thumb_no_image.gif'"});
      var item_title = new Element("div").update(data_set_item.readAttribute("data-title"));
      var item_elem = new Element("div", 
        {'class': 'item', 'id': this.get_html_id(item_id), style: 'display:none;', 'data-db_id': item_id});
      item_elem.appendChild(item_picture)
      item_elem.appendChild(item_title);
      this.outer_content.appendChild(item_elem);
      this.draggables[item_id] = new Draggable(this.get_html_id(item_id));
      Effect.Grow(this.get_html_id(item_id)); 
    }
  },
  remove_from_list: function(item_id){
    if(this.item_ids.include(item_id)){
      this.item_ids = this.item_ids.without(item_id);
      this.draggables[item_id].destroy();
      Effect.Shrink(this.get_html_id(item_id), { afterFinish: function(){$(this.get_html_id(item_id)).remove()}.bind(this) });
    }
  }
})
var map;
var geocoder;
var br_main_office_location;

function seller_shipped_item(item_struct){
  return item_struct.status > 1
}

function arrived_from_seller(item_struct){
  return item_struct.status > 2
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
  br_main_office_location = new google.maps.LatLng(42.019078, -87.714531);
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
}

//TODO must use the midpoint formula for geographical points
function midway_location(l1, l2){
  return new google.maps.LatLng( l1.lat() + (l2.lat() - l1.lat()) / 2, l1.lng() + (l2.lng() - l1.lng()) / 2);
}



function add_to_map(elem){
  new Ajax.Request("/order_items/" + elem.getAttribute("data-db_id") + ".json", {onComplete: collect_geocodes_and_show, method: "get" })
  var address_structs = [];
  function collect_geocodes_and_show(response){
    var item_struct = response.responseJSON;

    function resolve_geocode(_callback){
      geocoder.geocode( { 'address': address_struct.address}, function(results, status) {
      if(status == google.maps.GeocoderStatus.OK) {
        var loc = results[0].geometry.location;
        //To spread out items that are dense
        var offset = (item_struct.title.hashCode() % 10) * 0.1;
        address_struct.location = new google.maps.LatLng(loc.lat() + offset, loc.lng());
        //address_struct.location = results[0].geometry.location;
  
        _callback();
      } else {
        alert("Geocode was not successful for the following reason: " + status);
      }
      })
    }

    function add_midway_office_or_further(){
      address_structs.push( {location: midway_location(address_structs.last().location, br_main_office_location), type: "MIDWAY_SELLER" });
      if(arrived_from_seller(item_struct)){
       address_structs.push( {location: br_main_office_location, type: "BR_MAIN_OFFICE"} );
      }
      add_icons();
    }

    //EXTRACT SELLER ADDRESS
    if(!item_struct.seller_country.empty()){
      var address_struct = {address: item_struct.seller_country, type: "SELLER", location: null};
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
      var marker = new google.maps.Marker({
            map: map,
            position: address_struct.location
        })
        if(i){
          //LAT,LNG-> INCREASE /\ increase
          l1 =  address_structs[i-1].location;
          l2 = address_structs[i].location;
          var angle = Math.atan((l2.lng() - l1.lng()) / (l2.lat() - l1.lat()));
          angle *= 180 / Math.PI;
          angle = angle < 0 ? (360 + angle): angle;
          if(l1.lat() > l2.lat())
            angle += 180;
          angle %= 360;
          var a4 = new ArrowOverlay(map, address_struct.location, angle, item_path_color(item_struct), 2);
        }
      }
    )
    var path_points = address_structs.map(function(address_struct){
      return address_struct.location;
    })
    var path = new google.maps.Polyline({
      path: path_points,
      strokeColor: item_path_color(item_struct),
      strokeOpacity: 1.0,
      strokeWeight: 2
    });

    path.setMap(map);
    }
  }
  function item_path_color(item_struct){
    return hash_color(item_struct.title).toString(16);
  }
}
