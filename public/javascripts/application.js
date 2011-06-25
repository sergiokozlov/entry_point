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
	jQuery(divId).tufteGraph('bar',{
		data: returnedData,
        toolTip: function(index) { 
          var msg = 'Office: '+this[3].check_in + ' &ndash; ' + this[3].check_out 
          if (this[0] instanceof Array && this[0][1] > 0 && this[0][0] > 0)  { msg = msg + '<br/>' + 'and ' + this[0][1] + ' minutes from home' }
		  else if (this[0] instanceof Array && this[0][1] > 0)  { msg = this[0][1] + ' minutes from home' }
          else {}
          return msg + '<br/>' + 'Lunch Time: ' + this[1].lunch_time + ' minutes'
        },
        bar: {
          barWidth:  0.8,
          barLabel:  function(index) { return this[1].bar_label },
		  axisLabel: function(index) { return this[1].label },
          wdLabel: function(index) {return this[1].wd }
        }, 
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

// This function draws daily trend with data
function dailytrend(divId,returnedData) {
  $(divId).tufteGraph('line', {
          data: returnedData,
          toolTip: function(index,stackIndex) { 
            return  Math.round(this[0][stackIndex]/6)/10 + 'h';
          },
          colors:    ['#ff5a00', '#365f91', 'green'],
          color:     function(index, stackedIndex, options) { return options.colors[stackedIndex % options.colors.length]; },
          line: {
		    axisLabel: function(index) { return this[1].label}
          }, 
          afterDraw: {
            point: function(ctx, index, stackedIndex, options) {
              var x = ctx.scale.X(index + 0.5);
              var y = ctx.scale.Y(returnedData[index][0][stackedIndex]);
              var c = ctx.circle(x, y, 4).attr({
                fill:   options.color(index, stackedIndex, options),
                stroke: '#FFFFFF'
              });
              c.toBack();
            },
              
            stack: function(ctx, index) {
              if (index % 2 == 0) {
                ctx.rect(ctx.scale.X(index), 0, ctx.scale.X(1), ctx.axis.y.pixelLength).attr({
                  stroke: 'none',
                  fill: '#EEEEEE'
                }).toBack();
              }
            }
          }
          
        });
}

// This function returns id of group selected for analysis
function chosenGroup() {
	var group_id =  $('#group_list').children(".chosen_group").attr("id");
		return getId(group_id);
	
}

// This function returns id of user selected for analysis
function chosenfocusUser() {
	var user_id =  $('#focususer_id').find("option:selected").val();
		return getId(user_id);
	
}
// This function returns id of dashboard range
function chosenRange() {
	var range_id = $('input[name=range]:radio:checked').attr("id");
	return getId(range_id);
}

// This function returns number of week selected for analysis
function chosenWeek() {
	var week_id = $("#week_id").find("option:selected").val();
	return getId(week_id);
}

// This function returns number of month selected for analysis
function chosenMonth() {
	var month_id = $("#month_id").find("option:selected").val();
	return getId(month_id);
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

// This function loads data table for selected month and group
function loadMonth(params, ids, f) {
	$('#ajax_week').load("/dashboard/team_data_by_month/", params, function() {
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

	$(x).html("<td class='chart' colspan='7'><div class='chart-container'><div id='"+div_id+"' class='graph'></div><img class='ajax-loader' src='/images/ajax-loader.gif' alt='' /></div></td>");

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
           $("#daily-bars").fadeIn('fast');
     });
	return false;
}

// This function shows comparison trend on Manage/Overview for a specified user id
function showComparisonTrend(params) {
    $.getJSON('/dashboard/group_trend_for_range/', params, function(data) {
      	dailytrend("#line_trend",data[0].data);
     });
} 

jQuery.ajaxSetup({  
	'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});


$(document).ready( function () {
	
// Actions on DASHBOARD
	$('a.hide').click ( function() {
		$(this).parent("div").fadeOut('slow', function() {
			$(this).remove();
		});
		return false;
	});

 
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

	// Select correct value for selector 
	var pm_id = 'week_'+$.url.param("id");
	$('#week_id option[value='+pm_id+']').attr('selected', 'selected');

    // hide month range
    $("#month_id").hide();

	// load last available week and check week radio button
    $("#radio_week").attr("checked","checked");
	loadWeek();

    // On range update - update ajax_week
    $('input[name=range]:radio').change ( function() {
      var range = getId(this.id);
      	switch (range)
			{
				case 'week':
				  $("#month_id").hide();
                  $("#week_id").show();
                  loadWeek({week: chosenWeek, group: chosenGroup});
 				  showComparisonTrend({week: chosenWeek, focususer: chosenfocusUser});
				break;
				case 'month':
				  $("#week_id").hide();
                  $("#month_id").show();
                  loadMonth({month: chosenMonth, group: chosenGroup}); 
 				  showComparisonTrend({month: chosenMonth, focususer: chosenfocusUser});
				break;
			}; 
        });

	// On selector change update week
	$("#week_id").change ( function () {
      var hidden_buttons = $(':hidden.link_to_chart'); 
      //alert(hidden_buttons.length);
      var open_ids = $.map(hidden_buttons, function(hb) {
          return getId($(hb).attr("id"));
        });
      
	  loadWeek({week: chosenWeek, group: chosenGroup}, open_ids, expandDailyChart);
	  showComparisonTrend({week: chosenWeek, focususer: chosenfocusUser});
	});

    // On selector change update month 
    $("#month_id").change ( function() {
        loadMonth({month: chosenMonth, group: chosenGroup});
		showComparisonTrend({month: chosenMonth, focususer: chosenfocusUser});
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

    //On changing user to focus update trend
    showComparisonTrend({week: chosenWeek, focususer: chosenfocusUser});

    $("#focususer_id").change ( function() {
		switch (chosenRange())
			{
				case 'week':
 				  showComparisonTrend({week: chosenWeek, focususer: chosenfocusUser});
				break;
				case 'month':
 				  showComparisonTrend({month: chosenMonth, focususer: chosenfocusUser});
				break;
			};
        });

	// Manage clicking on group update
	$("a.group_link").click( function() {
		//var group_id = $(this).parents("li").attr("id");
		$(this).parents("li").siblings().removeClass('chosen_group');
		$(this).parents("li").addClass('chosen_group');
		switch (chosenRange())
			{
				case 'week':
 				  	loadWeek({week: chosenWeek, group: chosenGroup });
				break;
				case 'month':
 				  loadMonth({month: chosenMonth, group: chosenGroup}); 
				break;
			};
		return false;
      }); 

	// First group name highlighted
	$("#group_line li:first-child").addClass('chosen_group');


	// Better usability for editing entries
    /*
    $("#edit_wd tr").live("mouseover", function() {
      $(this).addClass("hover");
    });
    $("#edit_wd tr").live("mouseout", function() {
      $(this).removeClass("hover");
    });
    */





    // Hover for table rows
	$("tr")
	.mouseover(function() {$(this).addClass("hover");})
	.mouseout(function()  {$(this).removeClass("hover");});

    /*
    $("#edit_wd input").click(function() {
        if ($(this).attr("checked")) {
            $(this).parent().parent().addClass("selected");
        }
        else {
            $(this).parent().parent().removeClass("selected");
        }
    });
    */

	
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
	
	
	// Show different froms for different Check In radio buttons
	$('.why .radio').click(function () {
	
		if ($('#why_forgot').is(":checked")) {
			$('#forgot').show();
		}
		else {
			$("#forgot").hide();
		}
		
		if ($('#why_wfh').is(":checked")) {
			$('#wfh').show();
		}
		else {
			$("#wfh").hide();
		}
		
	}).filter(':first').click();
	

	// jQuery UI Datepicker
	$( "span.date input" ).datepicker({ 
		defaultDate: -1,
		firstDay: 1,
		duration: 'fast',
		dateFormat: 'yy-mm-dd'
	});



}); 



