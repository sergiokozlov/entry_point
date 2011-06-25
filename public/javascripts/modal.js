function showModalLayer(popID,popURL) {

		//Pull Query & Variables from href URL
		/*var query= popURL.split('?');
		var dim= query[1].split('&');
		var popWidth = dim[0].split('=')[1];*/ //Gets the first query string value

		//Fade in the Popup
		$('#' + popID).show(); /*.css({ 'width': Number( popWidth ) });*/

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
}  

$(document).ready( function () {
	
	// Tabs
	$('ul.tabNav li a').click(function () {
		var tabContainers = $(this).parents('ul').siblings('div');
		var tabWithAlert = $(this).parents('ul').siblings('div').children('span');
		tabContainers.hide().filter(':first').show();
		tabContainers.hide();
		tabContainers.filter(this.hash).show();
		$(this).parent().siblings().removeClass('active');
		$(this).parent().addClass('active');
		return false;
	}).filter('ul.tabNav li:first-child a').click();

  //When you click on a link with class of dialog-trigger and the href starts with a # 
	$('a.dialog-trigger').click(function() {
	  showModalLayer($(this).attr('rel'),$(this).attr('href'));
      return false;
	});

  //When there is flash[:notice] or flash[:error] show modal layer
    if ($(".dialog .alert").length>0) {
      rel = $(".alert").parents("div.dialog");
      link = $('a.dialog-trigger[rel="'+rel.attr("id")+'"]');
      showModalLayer(rel.attr("id"), '#');
	  var tabWithAlertId = $('div.dialog div.tabs span[class ~="alert"]').parent().attr('id');
	  $('ul.tabNav li a[href = "#'+ tabWithAlertId +'"]').click();
    }


	//Close Popups and Fade Layer
	$('a.close').live('click', function() { //When clicking on the close or fade layer...
		$('#fade , .dialog').hide(/*function() { $('#fade, a.close').remove(); }*/);
        $('#manual_entries').remove(); // clean up on dialog close
        $(".dialog .alert").remove(); // clean up on dialog close
		return false;
	});
	
	
}); 
