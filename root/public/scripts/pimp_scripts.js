
            //set up a global associative array to keep track of what elements are displayed
            var hidden = new Array();
            window.onload = function(){
                nested = document.getElementsByClassName('nested');
                for(var i = 0; i < nested.length; i++){
                    hidden[nested[i].id] = true;
                }
                //add the add page form id
                hidden["page_name_div"] = true;

               //find all the 'insert' divs
                var inserts = document.getElementsByClassName('insert_div');
                var insert_containers = document.getElementsByClassName('insert_point');

                //find all the insert items
                var insert_items = document.getElementsByClassName('insert_list_item');

                //Now, find all the textarea and header forms
                var text_divs = document.getElementsByClassName('add_text_container');
                var header_divs = document.getElementsByClassName('add_header_container');

                //find all the cancel buttons
                var cancel_text = document.getElementsByClassName('cancel_text');
                var cancel_header = document.getElementsByClassName('cancel_header');

                //Add the insert divs, header divs, and text area divs to the hidden array.
                //also give the containers on click handlers
                for(var i = 0; i < inserts.length; i++){
                  hidden[inserts[i].id] = true;
                  hidden[text_divs[i].id] = true;
                  hidden[header_divs[i].id] = true;
                  insert_containers[i].onmouseover = showInsert;
                  insert_containers[i].onmouseout = hideInsert;
                  cancel_text[i].onclick = displayWidgetHandler;
                  cancel_header[i].onclick = displayWidgetHandler;
                }


                for(var i = 0; i < insert_items.length; i++){
                    insert_items[i].onclick = displayWidgetHandler;
                }




            }


            function displayWidgetHandler(e){
                if (!e){
                    var e = window.event;
                }
                var target;
                if(e.target) target = e.target;
                else if(e.srcElement) target = e.srcElement;

                //now, we should have the element that was clicked on.
                var elem="insert_";
                var target_name= target.id.split("_");

                if(target.id.indexOf("_hdr_") > 0){
                  //clicked on the 'Add Header' button
                  elem += target_name[2] + "_" + target_name[3] + "_header";
                }else if(target.id.indexOf("cancel") >= 0){
                  //clicked on a 'Cancel' button
                   if(target_name[target_name.length - 1] == "text"){
                       //hide the text one
                       elem += target_name[1] + "_" + target_name[2] + "_text";
                   }else{
                       elem += target_name[1] + "_" + target_name[2] + "_header";
                   }
                }else{
                  //clicked on a 'Add text' button
                  elem += target_name[1] + "_" + target_name[2] + "_text";
                }
                /*var alertstring = "displayWidgethandler::: Show/Hide element = " + elem + "\n Target = " + target.id;
                alertstring += "\nTarget Name Last Element: " + target_name[target_name.length - 1];
                alertstring += "\nTarget name array length: " + target_name.length;
                alert(alertstring);*/
                displayWidget(elem);
            }

            function displayWidget(item_id){

                //var f = get_object(list);f.style.display == "none" || f.style.display == ""
                if (hidden[item_id]){
                   //f.style.display = "block";
                    Effect.Appear(item_id, {duration: 0.5, from:0.5});
                    hidden[item_id] = false;
                }else{
                   //f.style.display = "none";
                    Effect.Fade(item_id, {duration: 0.5, from:0.5})
                    hidden[item_id] = true;

                }

            }

            function showInsert(e){

                if (!e){
                    var e = window.event;
                }
                var source = e.relatedTarget || e.fromElement;
                var target;
                if(e.target) target = e.target;
                else if (e.srcElement) target = e.srcElement;
                var index = target.id.indexOf("_container",0);
                var hidethis = "";
                //pull out the actual element to show
                if(index >= 0){
                  hidethis = target.id.substring(0,index);
                }
                /*
                var alertString = "showInsert => From Element: " + source.id + "\nTo Element: "+target.id + "\nEvent Type: ";
                alertString += e.type + "\nHidethis: " + hidethis;
                alertString += "\nIs Hidden: " + hidden[hidethis];
                //alert(alertString);
                */

                if(hidden[hidethis] == true){
                   //Effect.Appear(hidethis, {duration: 0.5, from:0.5});
                   var element = get_object(hidethis);
                    element.style.display = "block";
                   hidden[hidethis] = false;
                }
            }

            function hideInsert(e){
                if (!e){
                    var e = window.event;
                }
                /*
                This chunk of code gets the source and to elements, then
                determines whether or not the mouse has actually left the
                required div tag or not.
                 */
                var toelem = (e.relatedTarget) ? e.relatedTarget : e.toElement;
                var target;
                if(e.target) target = e.target;
                else if (e.srcElement) target = e.srcElement;
                //if the mouseout event wasn't fired from a div element, throw it away.
                if (target.nodeName != 'DIV') return;
                while(toelem != target && toelem.nodeName != 'BODY'){
                    toelem = toelem.parentNode;
                }

                //the mouseout event took place in the layer
                if(toelem == target) return;

                //if we got here, we have actually left the element

                var index = target.id.indexOf("_container");
                var hidethis = "";
                if(index > 0){
                  hidethis = target.id.substring(0,index);
                }
               /*
                var alertString = "hideInsert => To Element: " + toelem.id;
                alertString += "\nFrom Element: " + target.id;
                alertString += "\nEvent Type: " + e.type;
                alertString += "\nHide: " + hidethis
                //alert(alertString);
                  */

                if(hidden[hidethis] == false){
                   //Effect.Fade("insert_1", {duration: 0.5, from:0.5});
                    get_object(hidethis).style.display = "none";
                   hidden[hidethis] = true;
                }
            }

            function setBackground(e,d){
               //var listitem = get_object(e);
               if(hidden[d] == true){
                   //make the background the original
                    e.style.background = "#FFA826";

               }else{
                   //the dropdown is about to show, set the background of the listitem
                   e.style.background = "#E7F1F8";
               }

            }

            function showLoad(){

            }

            function hideLoad(){

            }

            /*********************************************************************
             * Get an object, this function is cross browser
             * *** Please do not remove this header. ***
             * This code is working on my IE7, IE6, FireFox, Opera and Safari
             *
             * Usage:
             * var object = get_object(element_id);
             *
             * @Author Hamid Alipour Codehead @ webmaster-forums.code-head.com
             **/
            function get_object(id) {
                var object = null;
                if (document.layers) {
                    object = document.layers[id];
                } else if (document.all) {
                    object = document.all[id];
                } else if (document.getElementById) {
                    object = document.getElementById(id);
                }
                return object;
            }
            /*********************************************************************/


	function file_onchange() {
	  var s=document.getElementById('userfile').value;
	  var r=s.lastIndexOf('/');
	  if (r<0) {
	    r=s.lastIndexOf('\\\\');
	  }
	  if (r>=0) {
	    s=s.substr(r+1);
	  }
	  document.getElementById('remotename').value=s;
	}