// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// This function stripes numeric part from id
function getId (input) {
	if (input == undefined) {
		return null
	}
	else {
		return input.split("_")[1];
	}
}

// This function draw bar char with daily data
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

// This function returns id of group selected for analysis
function chosenGroup() {
	var group_id =  $('#group_list').children(".chosen_group").attr("id");
		return getId(group_id);
	
}

// This function returns number of week selected for analysis
function chosenWeek() {
	var week_id = $("#week_id").find("option:selected").val();
	return getId(week_id);
}

// This function loads data table for selected week and group
function loadWeek(params, ids, f) {
	$('#ajax_week').load("/dashboard/team_data_by_week/", params, function() {
		$(".collapse_chart").hide();
         if (typeof f == "function"  && ids.length > 0) {
         //alert(ids);
          $.each(ids, function(index, value) {
             f(value);
          });
         };
	});
}

// This function shows dailychart on Manage/Overview for a specified user id
function expandDailyChart(user_id) {
	var link = $("#user_"+user_id).filter(".link_to_chart");
 	var row_number = link.parents("tr").get(0).rowIndex + 1;
	//alert(row_number);
	var div_id =  'daily-bars-' + user_id
	var x = $("#team_table").get(0).insertRow(row_number);

	$(x).html("<td class='chart-container' colspan='6'><div id='"+div_id+"' class='graph'></div></td>");

	link.hide();
	link.parents("td").children(".collapse_chart").show();
		
	$.getJSON("/dashboard/user_data_for_range", {week : chosenWeek, user : user_id, group : chosenGroup}, function(data) {
		dailychart('#'+div_id,data[0].data);
	});
}


// This function shows dailychart for the current_user
function showWeekByDay(direction, params) {
    $(".ajax-loader").show();
    $("#daily-bars").hide();
	var url = '/dashboard/my_data_for_range/'+direction
	$.getJSON(url, params, function(data) {
      	dailychart("#daily-bars",data[0].data);
		$("#week_shower").load("/dashboard/get_session_week");
           $(".ajax-loader").hide();
           $("#daily-bars").show();
     });
	return false;
}

jQuery.ajaxSetup({  
	'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});


$(document).ready( function () {

// Actions on "DASHBOARD/INDEX" page for current_user
	// show last loaded week daily chart for current_user, support "<< >>" moving, refresh week
	showWeekByDay();
	
	$("#scrollF").live("click", function() {
      showWeekByDay('forward');
		return false;
    });
    $("#scrollB").live("click", function() {
 		showWeekByDay('backward');
		return false;
     });

	// Week update by clicking on table row
	$("tr").click (function() {
		week_id = getId($(this).attr("id"));
 	 	showWeekByDay('', {week : week_id});
	})

// Actions on "DASHBOARD/MANAGE" and "DASHBOARD/OVERVIEW" for the manager and director
	$('a.hide').click ( function() {
		$(this).parent("div").fadeOut('slow', function() {
			$(this).remove();
		});
		return false;
	});

	// Select correct value for selector 
	var pm_id = 'week_'+$.url.param("id");
	$('#week_id option[value='+pm_id+']').attr('selected', 'selected');


	// load last available week
	loadWeek();

	// On selector change update week
	$("#week_id").change ( function () {
      var hidden_buttons = $(':hidden.link_to_chart'); 
      //alert(hidden_buttons.length);
      var open_ids = $.map(hidden_buttons, function(hb) {
          return getId($(hb).attr("id"));
        });
      
	  loadWeek({week: chosenWeek, group: chosenGroup}, open_ids, expandDailyChart);
	});


	$(".collapse_chart").live("click", function() {
		var row_number = $(this).parents("tr").get(0).rowIndex + 1;
		$("#team_table").get(0).deleteRow(row_number);
		$(this).hide();
		$(this).parents("td").children(".link_to_chart").show();
	});

	// Manage clicking on drill button
	$(".link_to_chart").live("click",function() {

		var user_id = getId($(this).attr("id"));
		expandDailyChart(user_id); 
	});

	// Manage clicking on group update
	$("a.group_link").click( function() {
		//var group_id = $(this).parents("li").attr("id");
		$(this).parents("li").siblings().removeClass('chosen_group');
		$(this).parents("li").addClass('chosen_group');
		loadWeek({week: chosenWeek, group: chosenGroup });
        
 
		return false;
      }); 

	// First group name highlighted
		$("#group_line li:first-child").addClass('chosen_group');
	  
	// Hover for table rows  
	$("tr")
	//.live("mouseover", function() {$(this).addClass("hover");})
	//.live("mouseout",  function() {$(this).removeClass("hover");});
	.mouseover(function() {$(this).addClass("hover");})
	.mouseout(function()  {$(this).removeClass("hover");});
	
	//Zebra tables
	//$('table tbody tr:odd').addClass('alt')'
	
	
	
	//**************** START MODAL DIALOG *******************//
	
	//When you click on a link with class of dialog-trigger and the href starts with a # 
	$('a.dialog-trigger[href^=#]').click(function() {
		var popID = $(this).attr('rel'); //Get Popup Name
		var popURL = $(this).attr('href'); //Get Popup href to define size

		//Pull Query & Variables from href URL
		var query= popURL.split('?');
		var dim= query[1].split('&');
		var popWidth = dim[0].split('=')[1]; //Gets the first query string value

		//Fade in the Popup
		$('#' + popID).fadeIn().css({ 'width': Number( popWidth ) });

		//Define margin for center alignment (vertical   horizontal)
		var popMargTop = ($('#' + popID).height() ) / 2;
		var popMargLeft = ($('#' + popID).width() ) / 2;

		//Apply Margin to Popup
		$('#' + popID).css({
			'margin-top' : -popMargTop,
			'margin-left' : -popMargLeft
		});

		//Show Background
		$('body').append('<div id="fade"></div>'); //Add the fade layer to bottom of the body tag.
		$('#fade').css({'filter' : 'alpha(opacity=40)'}).show(); //Fade in the fade layer - .css({'filter' : 'alpha(opacity=80)'}) is used to fix the IE Bug on fading transparencies 

		return false;
	});

	//Close Popups and Fade Layer
	$('a.close, #fade').live('click', function() { //When clicking on the close or fade layer...
		$('#fade , .dialog').fadeOut(function() {
			//$('#fade, a.close').remove();  //fade them both out
		});
		return false;
	});
	
	//**************** END MODAL DIALOG *******************//
	
	
	//**************** START HINTS IN INPUTS *******************//
	jQuery.fn.hint = function (blurClass) {
	  if (!blurClass) { 
		blurClass = 'blur';
	  }

	  return this.each(function () {
		// get jQuery version of 'this'
		var $input = jQuery(this),

		// capture the rest of the variable to allow for reuse
		  title = $input.attr('title'),
		  $form = jQuery(this.form),
		  $win = jQuery(window);

		function remove() {
		  if ($input.val() === title && $input.hasClass(blurClass)) {
			$input.val('').removeClass(blurClass);
		  }
		}

		// only apply logic if the element has the attribute
		if (title) { 
		  // on blur, set value to title attr if text is blank
		  $input.blur(function () {
			if (this.value === '') {
			  $input.val(title).addClass(blurClass);
			}
		  }).focus(remove).blur(); // now change all inputs to title

		  // clear the pre-defined text when form is submitted
		  $form.submit(remove);
		  $win.unload(remove); // handles Firefox's autocomplete
		}
	  });
	};
	
	// find all the input elements with title attributes
	$('input.text[title!=""]').hint();

	//**************** END HINTS IN INPUTS *******************//
	
	
}); 



