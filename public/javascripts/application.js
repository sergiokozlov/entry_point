// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

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
	return group_id;
}

// This function returns number of week selected for analysis
function chosenWeek() {
	var week_id = $("#week_id").find("option:selected").val();
	return week_id;
}

// This function loads data table for selected week and group
function loadWeek(params) {
	$('#ajax_week').load("/dashboard/team_data_by_week/", params, function() {
		$(".collapse_chart").hide();
	});
}

// This function shows dailychart on Manage/Overview for a specified user id
function expandDailyChart(user_id) {
	var link = $("#"+user_id);
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
	var url = '/dashboard/my_data_for_range/'+direction
	$.getJSON(url, params, function(data) {
     	dailychart("#daily-bars",data[0].data);
		$("#week_value").load("/dashboard/get_session_week");
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
	
	$("#scrollF").click(function() {
      showWeekByDay('forward');
		return false;
    });
    $("#scrollB").click(function() {
 		showWeekByDay('backward');
		return false;
     });

	// Week update by clicking on table row
	$("tr").click (function() {
		week_id = $(this).attr("id");
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
	var pm_id = $.url.param("id");
	$('#week_id option[value='+pm_id+']').attr('selected', 'selected');


	// load last available week
	loadWeek();

	// On selector change update week
	$("#week_id").change ( function () {
		loadWeek({week: chosenWeek, group: chosenGroup});
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
		/*
		var div_id =  'daily-bars-' + user_id;
		var row_number = $(this).parents("tr").get(0).rowIndex + 1;
		var x = $("#team_table").get(0).insertRow(row_number);

		$(x).html("<td colspan='6'><div id='"+div_id+"' class='graph'></div></td>");

		$(this).hide();
		$(this).parents("td").children(".collapse_chart").show();
		*/
		expandDailyChart(user_id); 
	});

	// Manage clicking on group update
	$("a.group_link").click( function() {
		var group_id = $(this).parents("li").attr("id");
	
		loadWeek({week: chosenWeek, group: group_id});

		$(this).parents("li").siblings().removeClass('chosen_group');
		$(this).parents("li").addClass('chosen_group');
 
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
	
}); 



