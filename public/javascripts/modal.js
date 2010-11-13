$(document).ready( function () {
	
	//When you click on a link with class of dialog-trigger and the href starts with a # 
	$('a.dialog-trigger[href^=#]').click(function() {
		var popID = $(this).attr('rel'); //Get Popup Name
		var popURL = $(this).attr('href'); //Get Popup href to define size

		//Pull Query & Variables from href URL
		var query= popURL.split('?');
		var dim= query[1].split('&');
		var popWidth = dim[0].split('=')[1]; //Gets the first query string value

		//Fade in the Popup
		$('#' + popID).show().css({ 'width': Number( popWidth ) });

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
	$('a.close').live('click', function() { //When clicking on the close or fade layer...
		$('#fade , .dialog').hide(/*function() {	$('#fade, a.close').remove(); }*/ );
		return false;
	});
	
	
}); 