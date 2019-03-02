$(function() {
  $(".edit_button").click(function() {
    $(".show_when_editing").css("display", "inline-block");
    $(".hide_when_editing").css("display", "none");
  });
    
  
  $(".done_editing_button").click(function() {
    // collect all measurment data from displayed table
    var measurements_table = $("#measurements_table");
    var new_measurements = [];
    measurements_table.find(".measurements_row").each(function() {
      var measurements_id = $(this).attr("id");
      var new_data = {};
      new_data["id"] = measurements_id;
      new_data["weight"]    = $(this).find(".weight_edit").val().trim();
      new_data["body_fat"]  = $(this).find(".body_fat_edit").val().trim();
      new_data["height"]    = $(this).find(".height_edit").val().trim();
      new_measurements.push(new_data);
    });
    
    $.ajax({
      type:"POST",
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      url:"/process_update_measurements",
      data: {
        "new_measurements": new_measurements,
      }, 
      complete: function(o) {
        if (o.status == 500) {
          $("#flash_error").html(o.message)
        } else {
          window.location.reload(true);  
        }
      }
    });
  });
});



