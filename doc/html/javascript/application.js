$(document).ready(function () {
	showHideControls();
	setup_response('direct_message', function(el, text) {
		 return 'd ' + getScreenName(el).replace(/@/,'') + ' ' + text  
	 });
	setup_response('re_tweet',function(el, text) {
		 return text + ' (via ' + getScreenName(el) + ')';
	 }); 
	setup_response('reply',function(el,text) {
		return getScreenName(el)+'';
	});
});                    

var getScreenName = function(el) {
	return $(el).parents('.tweet').find('.screen_name').attr('title')
}


var showHideControls = function () {
	$('#toggle-status-update').replaceWith('<div id="toggle-status-update" ><span>Toggle status updates</span></div>')

	$('#toggle-status-update').click(function (){
		$('#status-update').toggle('fast',function(){
			if ($(this).css('display') === 'none') {
				$('#toggle-status-update').css('margin-top', '-2px').find('span').css({
					'background-image': 'url(images/show-post-update.gif)',
					'position': 'relative',
					'top': '-5px'
				});
			} else {
				$('#toggle-status-update').css('margin-top', '0').find('span').css({
					'background-image': 'url(images/hide-post-update.gif)',
					'top': '-1px'
				});
			}
		});
	});
};

var setup_response = function (type, formatter) {
	$('.'+type).click( function (){
		var parents = $(this).parents('.tweet');
		parents.find('.status_text').text(formatter(this, parents.find('.text').text())); 
		parents.find('.actions li').removeClass('down');
		$(this).addClass('down');
		return false;                            
	});                                                                   
}