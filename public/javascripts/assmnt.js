// An Unobtrusive Javascript (UJS) driver based on explicit behavior definitions. Just
// put a "data-behaviors" attribute on your view elements, and then assign callbacks
// for those named behaviors via Behaviors.add.

var Behaviors = {
  add: function(trigger, behavior, handler) {
    document.observe(trigger, function(event) {
      var element = event.findElement("*[data-behaviors~=" + behavior + "]");
      if (element) handler(element, event);
    });
  }
};

Behaviors.add("submit", "validate", function(element) {
  var formElements = element.select([".required", ".required-one"]);
  var valid = true;
  formElements.each(function(elm) {
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

  });
  if (!valid) {
    event.stop()
    };
});

Behaviors.add("click", "toggleOther", function(element) {
  var id = element.id;
  var other_id = id + "_other"
  var other_text = other_id + "_text"
  var input_type = $(id).type.toLowerCase()
  if (input_type == 'radio') {
      var input_name = $(id).name
      var input_form = $(id).form
      var radio_group = Form.getInputs(input_form, 'radio', input_name)
      //alert(radio_group)
      for (var i = 0; i < radio_group.length; i++) {
          //alert(radio_group[i].id)
          other_id = radio_group[i].id + "_other"
          other_text = radio_group[i].id + "_other_text"
          if ($(other_id)) {
              if ($(radio_group[i].id).checked) {
                  if ($(other_id)) {
                      $(other_id).style.display = "block"
                      $(other_text).disabled = false
                  };
              } else {
                  if ($(other_id)) {
                      $(other_id).style.display = "none"
                      $(other_text).value = ""
                      $(other_text).disabled = true
                  };
              };
          };
      };

  } else {

      if ($(id).checked) {
          if ($(other_id)) {
              $(other_id).style.display = "block"
              $(other_text).disabled = false
          };
      } else {
          if ($(other_id)) {
              $(other_id).style.display = "none"
              $(other_text).value = ""
              $(other_text).disabled = true
          };
      };
  };
});


function isEmpty(e) {
    var v = e.value;

    var siblings = document.getElementsByName(e.name);
    if (siblings.length > 2) {
        var ok = false;

        for (var i = 0; i < siblings.length; i++) {
            if (siblings[i].type.toLowerCase() == "text") {
                v = siblings[i].value
                empty = ((v == null) || (v.length == 0))
                ok = ok || empty
            }
        };

        return ok;
    } else {
        return ((v == null) || (v.length == 0));
    };
}

function isSelected(e) {
    return e.options ? e.selectedIndex > 0: false;
}

function isChecked(e) {
    var siblings = document.getElementsByName(e.name);
    return $A(siblings).any(function(elm) {
        return $F(elm);
    });

}

function setError(e) {
    var elemID = e.id
    if (elemID) {
        var chunks = elemID.split("_")
        if (chunks.length != 3) {
            return
        };
        var qid = $("q_" + chunks[1])
        if ($(qid)) {
            $(qid).addClassName('validation-error')
            errID = $(qid).id + "err"
            span = '<span class="validation-advice" id="' + errID + '">Your forgot something!</span>'
            if (!$(errID)) {
                $(qid).insert(span)
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
        var qid = $("q_" + chunks[1])
        if ($(qid)) {
            $(qid).removeClassName('validation-error')
            errID = $(qid).id + "err"
            if ($(errID)) {
                $(errID).remove()
            }
        }
    }
}
