$(document).ready(function () {   
	$('#toggle-status-update').click(function (){
		$('#status-update').slideToggle('fast',function(){
			if ($(this).css('display') === 'none') {
				$('#toggle-status-update').css('margin-top', '-12px').find('span').css({
					'background-image': 'url(images/show-post-update.gif)',
					'margin': '-4px 0 0 0'
				});

			} else {
				$('#toggle-status-update').css('margin-top', '0px').find('span').css({
					'background-image': 'url(images/hide-post-update.gif)',
					'margin': '0'
				});
			}
		);
	});
});