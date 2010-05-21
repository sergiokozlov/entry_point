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

        // Load team table for current week
       // var url = "/dashboard/team_data_by_week/?id="+$(this).find("option:selected").val();
         // $('#ajax_week').load(url);

	    // On selector change update week
	      $("#week_id").change ( function () {
	        var url = "/dashboard/team_data_by_week/?id="+$(this).find("option:selected").val();
            $('#ajax_week').load(url);
	      });

          var myOffset = $('#week_id').offset();
          alert(myOffset.top);
          alert(myOffset.left);
        //
             
	  });
