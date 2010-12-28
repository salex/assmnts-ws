// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function toggle_checkbox_class(cls){
	num = $$('input.'+cls);
	for (var x = 0; x < num.length; x++){
		if (num[x].checked){
			num[x].checked = false;
			}else{
			num[x].checked = true;
		}
	}
}

function showdiv(e,csid) {
	var posx = 0;
	var posy = 0;
	if (!e) var e = window.event;
	if (e.pageX || e.pageY) 	{
		posx = e.pageX;
		posy = e.pageY;
	}
	else if (e.clientX || e.clientY) 	{
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
	if (e.pageX || e.pageY) 	{
		posx = e.pageX;
		posy = e.pageY;
	}
	else if (e.clientX || e.clientY) 	{
		posx = e.clientX + document.body.scrollLeft
			+ document.documentElement.scrollLeft;
		posy = e.clientY + document.body.scrollTop
			+ document.documentElement.scrollTop;
	}
	// posx and posy contain the mouse position relative to the document
	// Do something with this information
}

function mypopup(url)
 {
   mywindow = window.open (url,
  "mywindow","location=0,status=0,scrollbars=1,width=850");
  mywindow.moveTo(0,0);
 } 

function and_ans(ans){
	if ($("group").checked) {group_ans(ans,"&"); return};
	var curr_akeys = $("akeys").value
	if (curr_akeys == ""){
		$("akeys").value = ans
	}else{
		$("akeys").value = curr_akeys + "&" +  ans
	}
}

function or_ans(ans){
	if ($("group").checked) {group_ans(ans,"|"); return};
	var curr_akeys = $("akeys").value
	if (curr_akeys == ""){
		$("akeys").value = ans
	}else{
		$("akeys").value = curr_akeys + "|" +  ans
	}
}
function group_ans(ans,join){
	var curr_gkeys = $("agroup").value
	if (curr_gkeys == ""){
		$("agroup").value = ans
	}else{
		$("agroup").value = curr_gkeys + join +  ans
	}
}

function wrap_keys(join){
	var curr_gkeys = $("agroup").value
	var curr_akeys = $("akeys").value
	if ((curr_gkeys != "") &&  (curr_akeys != "")) {
		$("agroup").value = ""
		$("akeys").value = "(" + curr_akeys +")" + join + "(" + curr_gkeys +")"
	};
}

function set_uri(uri){
	var spos = uri.indexOf("qa_summary")
	var epos = uri.indexOf("&status=")
	var ss = uri.substring(0,spos)
	var ans = $("akeys").value
	var nans = escape(ans)
	var name = $("name").value
	var phone = $("phone").value
	var email = $("email").value
	var status = $("status").value
	var nuri = ss + "search?answers="+nans+"&filter=search&name="+ name +"&phone="+ phone +"&email=" + email +"&status=" + status 
	//alert(ss+"-"+nuri)
	win = top.opener;
	win.location.href = nuri;
	
}
