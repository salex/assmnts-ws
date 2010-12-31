// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function toggle_checkbox_class(cls){
	num = $('.'+cls);
	for (var x = 0; x < num.length; x++){
		if (num[x].checked){
			num[x].checked = false;
			}else{
			num[x].checked = true;
		}
	}
}
/*
function showdiv(e,csid) {
	var posx = 0;
	var posy = 0;
	if (!e) var e = window.event;
	if (e.pageX || e.pageY)		{
		posx = e.pageX;
		posy = e.pageY;
	}
	else if (e.clientX || e.clientY)	{
		posx = e.clientX + document.body.scrollLeft
			+ document.documentElement.scrollLeft;
		posy = e.clientY + document.body.scrollTop
			+ document.documentElement.scrollTop;
	}
	// posx and posy contain the mouse position relative to the document
	// Do something with this information
	posy += 10;
	$(csid).style.top = posy +'px';
	$(csid).style.left = posx +'px';
	$(csid).style.display = 'block';
}

function hidediv(e) {
	var posx = 0;
	var posy = 0;
	if (!e) var e = window.event;
	if (e.pageX || e.pageY)		{
		posx = e.pageX;
		posy = e.pageY;
	}
	else if (e.clientX || e.clientY)	{
		posx = e.clientX + document.body.scrollLeft
			+ document.documentElement.scrollLeft;
		posy = e.clientY + document.body.scrollTop
			+ document.documentElement.scrollTop;
	}
	// posx and posy contain the mouse position relative to the document
	// Do something with this information
}
*/

function mypopup(url)
 {
	 mywindow = window.open (url,
	"mywindow","location=0,status=0,scrollbars=1,width=850");
	mywindow.moveTo(0,0);
 } 

function and_ans(ans){
	if ($("#group").attr("checked")) {
		group_ans(ans,"&"); 
	}else{
		var curr_akeys = $("#akeys").val();
		if (curr_akeys == ""){
			$("#akeys").val(ans);
		}else{
			$("#akeys").val( curr_akeys + "&" +	 ans);
		};
	};
}

function or_ans(ans){
	if ($("#group").attr("checked")) {
		group_ans(ans,"|"); 
	}else{
		var curr_akeys = $("#akeys").val();
	
		if (curr_akeys == ""){
			$("#akeys").val(ans);
		}else{
			$("#akeys").val(curr_akeys + "|" +	ans);
		};
	};
}
function group_ans(ans,join){
	var curr_gkeys = $("#agroup").val()
	if (curr_gkeys == ""){
		$("#agroup").val(ans)
		
	}else{
		$("#agroup").val(curr_gkeys + join +	ans)
	}
	
}

function wrap_keys(join){
	var curr_gkeys = $("#agroup").val()
	var curr_akeys = $("#akeys").val()
	
	if ((curr_gkeys != "") &&	 (curr_akeys != "")) {
		$("#agroup").val("")
		var nkey = "(" + curr_akeys +")" + join + "(" + curr_gkeys +")"
		$("#akeys").val(nkey )
	};
}

function set_uri(uri){
	var spos = uri.indexOf("qa_summary")
	var epos = uri.indexOf("&status=")
	var ss = uri.substring(0,spos)
	var ans = $("#akeys").val()
	var nans = escape(ans)
	var name = $("#name").val()
	var phone = $("#phone").val()
	var email = $("#email").val()
	var status = $("#status").val()
	var nuri = ss + "search?answers="+nans+"&filter=search&name="+ name +"&phone="+ phone +"&email=" + email +"&status=" + status 
	//alert(ss+"-"+nuri)
	win = top.opener;
	win.location.href = nuri;
	
}

$(document).ready(function() {
	$('[data-behaviors="toggleOther"]').bind('click', function() {
		toggleOther(this)
	});
	$('[data-behaviors="validateRequired"]').submit(function() {
		return( validateRequired());
	});
	$('[data-behavior="zipcodeLookup"]').bind('blur', function(){
		if (this.id == "citizen_zip") {
			var city = $("#citizen_city");
			var state = $("#citizen_state");
		}else{
			var city = $("#user_city");
			var state = $("#user_state");
			
		};
		
		//if (!city.val() ) {
			$.getJSON("http://www.geonames.org/postalCodeLookupJSON?&country=US&callback=?", {postalcode: this.value }, function(response) {
				if (response && response.postalcodes.length && response.postalcodes[0].placeName) {
					city.val(response.postalcodes[0].placeName);
					state.val(response.postalcodes[0].adminCode1);
					//$("#lookup").html(dumpObj(response,"tesr","  ",2))
					
				}
			})
		//}
	
	});

	$('[data-behavior="toggleSummary"]').bind('click', function() {
		var id = $(this).attr("id");
		var sumid = "#"+id.replace(/toggle_/,"")		
		if ($(sumid).css("display") == 'table-row') { 
			$(sumid).css("display", 'none')			
		}else {
			$(sumid).css("display", 'table-row')
		} ;

	});
	
});	 

function esc(mySel) { 
	return mySel.replace(/([:|\.\]\[])/g,'\\$1');
}

function toggleOther(elem){
	
	var id = elem.id;
	var other_id = id + "_other"
	var other_text = other_id + "_text"
	var input_type = $('#'+id).attr("type").toLowerCase()
	if (input_type == 'radio') {
	
		var input_name = $('#'+id).attr("name")
		input_name = esc(input_name)
		//var input_form = $(id).form
		var selt = 'input[name="'+input_name+'"]:radio'
		var radio_group = $(selt)
		//alert(radio_group.length+"rg"+selt)
		for (var i = 0; i < radio_group.length; i++) {
			//alert(radio_group[i].id + " - " + radio_group[i].checked)
			other_id = radio_group[i].id + "_other"
			other_text = radio_group[i].id + "_other_text"
			if ($("#"+other_id)) {
				if (radio_group[i].checked) {
					if ($("#"+other_id)) {
						$("#"+other_id).css("display", 'block')
						$("#"+other_text).attr("disabled","")
					};
				} else {
					if ($("#"+other_id)) {
						$("#"+other_id).css("display", 'none')
						$("#"+other_text).val("")
						$("#"+other_text).attr("disabled","disabled")
					};
				};
			};
		};

	} else {

		if ($("#"+id).attr("checked")) {
				if ($("#"+other_id)) {
						$("#"+other_id).css("display", 'block')
						$("#"+other_text).attr("disabled","")
				};
		} else {
				if ($("#"+other_id)) {
						$("#"+other_id).css("display", 'none')
						$("#"+other_text).val("")
						$("#"+other_text).attr("disabled","disabled")
				};
		};
	};
}

function validateRequired(){
	var formElements = $(".required, .required-one");
	var valid = true;
	//formElements.each(function(elm) {
	for (var i = 0; i < formElements.length; i++) {
		var elm = formElements[i]
			var type = elm.type.toLowerCase();
			var node = elm.nodeName.toLowerCase();
			var elm_valid = true 
			if (node == 'input') {
					var type = elm.type.toLowerCase();
					if (type == 'text' || type == 'password') {
							elm_valid = !isEmpty(elm)
							elm_valid ? clearError(elm) : setError(elm)
							valid = valid && elm_valid
					} else if (type == 'radio' || type == 'checkbox') {						
							elm_valid = isChecked(elm)
							elm_valid ? clearError(elm) : setError(elm)
							valid = valid && elm_valid
					}
			} else if (node == 'textarea') {
					elm_valid = !isEmpty(elm)
					elm_valid ? clearError(elm) : setError(elm)
					valid = valid && elm_valid
					
			} else if (node == 'select') {				
					elm_valid = isSelected(elm)
					elm_valid ? clearError(elm) : setError(elm)
					valid = valid && elm_valid
					
			} else {

			}

	};
	if (!valid) {
		return(false)
	 };
	return(true)
}

function isEmpty(e) {
	var v = e.value;
	return((v == null) || (v.length == 0));
}

function isSelected(e) {
	return e.options ? e.selectedIndex > 0: false;
}

function isChecked(e) {
	var ename = esc(e.name)
	var ckd = $('input[name="'+ename+'"]:checked')
	return (ckd.size() > 0)

}

function setError(e) {
	var elemID = e.id
	
	if (elemID) {
		var chunks = elemID.split("_")
		if (chunks.length != 3) {
				return
		};
		var qid = $("#q_" + chunks[1])
		if ($(qid)) {
			$(qid).addClass('validation-error')
			errID = $(qid).attr("id") + "err"
			span = '<span class="validation-advice" id="' + errID + '">Your forgot something!</span>'
			
			if (!$("#"+errID).length) {
					$(qid).append(span)
			}
		}
	}
}

function clearError(e) {
	var elemID = e.id
	if (elemID) {
		var chunks = elemID.split("_")
		if (chunks.length != 3) {
				return
		};
		var qid = $("#q_" + chunks[1])
		if ($(qid)) {
			$(qid).removeClass('validation-error')
			errID = $(qid).attr("id") + "err"
			if ($("#"+errID).length) {
					$("#"+errID).remove()
			}
		}
	}
}


function dumpObj(obj, name, indent, depth) {
       if (depth > 10) {
              return indent + name + ": <Maximum Depth Reached>\n";
       }
       if (typeof obj == "object") {
              var child = null;
              var output = indent + name + "\n";
              indent += "\t";
              for (var item in obj)
              {
                    try {
                           child = obj[item];
                    } catch (e) {
                           child = "<Unable to Evaluate>";
                    }
                    if (typeof child == "object") {
                           output += dumpObj(child, item, indent, depth + 1);
                    } else {
                           output += indent + item + ": " + child + "\n";
                    }
              }
              return output;
       } else {
              return obj;
       }
}
