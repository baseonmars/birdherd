$(document).ready(function () {
	showHideControls();
	setup_message();
});

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

var setup_message = function () {
	$('.direct_message').click( function (){
		$(this).parents('.actions').find('.status_text')[0].text($(this).parents('.tweet').find('.text').text());
		return false;                            
	});                                                                   
}