// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

    function dailychart(returnedData) {
	     jQuery('#daily-bars').tufteBar({
         data: returnedData,
         barWidth: 0.8,
         barLabel:  function(index) { return this[0] },
         axisLabel: function(index) { return this[1].label },
         color:     function(index) { 
			switch (this[2].flag)
			{
			case 'Red':
			 return '#8B0000'
			  break;
			case 'White':
			 return '#FFFFFF'
			  break;
			default:
			 return '#828282'
			}; 
		}
       });
     } 

	  $(document).ready( function () {

        // Select correct value for selector 
        var pm_id = $.url.param("id");
          $('#week_id option[value='+pm_id+']').attr('selected', 'selected');
        // Hide buttons
        $(".collapse_chart").hide();

        // On selector change update week
	      $("#week_id").change ( function () {
	        var url = "/dashboard/team_data_by_week/?id="+$(this).find("option:selected").val();
            $('#ajax_week').load(url);
	      });

          
          $(".collapse_chart").click(function() {
	              var row_number = $(this).parents("tr").get(0).rowIndex + 1;
                  $("#team_table").get(0).deleteRow(row_number);
                  $(this).hide();
                  $(this).parents("td").children(".link_to_chart").show();
          });

        // Manage clicking on drill button
		  $(".link_to_chart").click(function() {

	            var row_number = $(this).parents("tr").get(0).rowIndex + 1;
                var user_id = $(this).attr("id");
                var week_id = +$("#week_id").find("option:selected").val();
	            var x = $("#team_table").get(0).insertRow(row_number);
				//var url = "/dashboard/user_data_for_range/?week="+$("#week_id").find("option:selected").val()+"&user="+user_id;
	            // switch to jQuery style
	            x.innerHTML="<td colspan='6'><div id='daily-bars' class='graph' style='width: 480px; height: 120px; margin: 20px;'></div></td>";
                
                 $(this).hide();
                 $(this).parents("td").children(".collapse_chart").show();
             
                jQuery.getJSON("/dashboard/user_data_for_range", {week : week_id, user : user_id}, function(data) {
	              dailychart(data[0].data);
	            }); 
	      });
      }); 


