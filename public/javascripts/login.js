$.ajaxSetup({  
    'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});

$(function () {


	// Focus on first visible input field
	$(':input:visible:enabled:first').focus();
	
	
	// Make AJAX call to users_controller
	$('#new_user_session').submit(function (){  
		$.post($(this).attr('action'), $(this).serialize(), function(msg){
			if (msg == 'Bad') {
				if ( $('.top-alert').css('display')=='block' ) {
					$('.top-alert').fadeOut('fast').fadeIn('fast').fadeOut('fast').fadeIn('fast'); 
				} else {
					$('.top-alert').slideDown('fast');
				}
			} else {
				if ( $('.top-alert').css('display')=='block' ) {
					$('.top-alert').slideUp('fast'); 
				}
			}
		});  
		return false;
	});
	

});





