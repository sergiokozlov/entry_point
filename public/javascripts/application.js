// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
/*
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
     } */

	  $(document).ready( function () {
	     $('#week_id option[value="15"]').attr('selected', 'selected');
	
	      $("#week_id").change ( function () {
	        var url = "/dashboard/manage/"+$(this).find("option:selected").val();
	        window.location.replace(url);
	      });
	  });
