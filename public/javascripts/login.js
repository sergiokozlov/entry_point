jQuery.ajaxSetup({  
    'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}  
});

$(function () {

    // Focus on first visible input field
    $(window).load(function () {
      $(':input:visible:enabled:first').focus();

      $('#new_user_session').submit(function (){  
        $.post($(this).attr('action'), $(this).serialize(), function(msg){
          if (msg == 'Bad') {
          //alert( "Data Saved: " + msg );
          $('.alert').slideDown('fast'); }
          });  
        return false;
        });

      });

    // Login error
    //$('#user_session_submit').click( function() {
    //	$('.error').slideDown('fast').delay(3000).slideUp();
	//	return false;
	//});
	  
})





