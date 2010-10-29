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
				if ( $('.alert').css('display')=='block' ) {
					$('.alert').fadeOut('fast').fadeIn('fast').fadeOut('fast').fadeIn('fast'); 
				} else {
					$('.alert').slideDown('fast');
				}
			} else {
				if ( $('.alert').css('display')=='block' ) {
					$('.alert').slideUp('fast'); 
				}
			}
		});  
		return false;
	});
	

});





