// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


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
      var item_elem = new Element("div", {'class': 'item', 'id': this.get_html_id(item_id), style: 'display:none;'});
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

