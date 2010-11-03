// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

    function dailychart(divId,returnedData) {
	     jQuery(divId).tufteBar({
         data: returnedData,
         barWidth: 0.8,
         barLabel:  function(index) { return this[1].bar_label },
         axisLabel: function(index) { return this[1].label },
         color:     function(index, stackedIndex) { 
			switch (this[2].flag)
			{
			case 'Red':
			 return ['#8B0000','#000'][stackedIndex % 2] 
			  break;
            case 'Green':
			 return ['#509721','#000'][stackedIndex % 2] 
			  break;
			case 'White':
			 return ['#FFFFFF','#000'][stackedIndex % 2] 
			  break;
			default:
			 return ['#FFC000','#000'][stackedIndex % 2] 
			}; 
		}
       });
     }

jQuery.ajaxSetup({  
    'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});


$(document).ready( function () {

    $('b.hide').click ( function() {
      $(this).parent("div").fadeOut('slow', function() {
            $(this).remove();
        });
    });

        // Select correct value for selector 
        var pm_id = $.url.param("id");
          $('#week_id option[value='+pm_id+']').attr('selected', 'selected');


		// load last available week
        $('#ajax_week').load("/dashboard/team_data_by_week/", function() {
			$(".collapse_chart").hide();
		});
		
        // On selector change update week
	      $("#week_id").change ( function () {
	        var url = "/dashboard/team_data_by_week/?id="+$(this).find("option:selected").val();
            $('#ajax_week').load(url, function() {
				$(".collapse_chart").hide();
			});
	      });
	

          $(".collapse_chart").live("click", function() {
	              var row_number = $(this).parents("tr").get(0).rowIndex + 1;
                  $("#team_table").get(0).deleteRow(row_number);
                  $(this).hide();
                  $(this).parents("td").children(".link_to_chart").show();
          });

        // Manage clicking on drill button
		  $(".link_to_chart").live("click",function() {

	            var user_id = $(this).attr("id");
                var week_id = $("#week_id").find("option:selected").val();
                var div_id =  'daily-bars-' + user_id

                var row_number = $(this).parents("tr").get(0).rowIndex + 1;
	            var x = $("#team_table").get(0).insertRow(row_number);
               
                $(x).html("<td colspan='6'><div id='"+div_id+"' class='graph' style='width: 480px; height: 120px; margin: 20px;'></div></td>");
                
                 $(this).hide();
                 $(this).parents("td").children(".collapse_chart").show();
             
                jQuery.getJSON("/dashboard/user_data_for_range", {week : week_id, user : user_id}, function(data) {
	              dailychart('#'+div_id,data[0].data);
	            }); 
	      });
          // Manage clicking on group update
          $("a.group_link").click( function() {
           // alert($(this).attr("id"));
            $(this).parents("li").siblings().removeClass('chosen_group');
            $(this).parents("li").addClass('chosen_group');

          });
      }); 


