$(document).ready(function () {
	Birdherd.UI.init();

	// TODO set up a stylesheet or something instead of apply to each item
	$('.tweet').addClass('collapsed');
});       

var Birdherd = {};

Birdherd.UI = (function(){         
	// Init
	var init;

	init = function() {
		showHideControls();

		setupToggleExtendedTweet();

		setResponseAction('direct_message', function(el) {
			return 'd '+getScreenName(el).replace(/@/,'')+' ';
		});
		setResponseAction('re_tweet',function(el, text) {
			return text+' (via '+getScreenName(el)+')';
		}); 
		setResponseAction('reply',function(el) {
			return getScreenName(el)+' ';
		});
	};

	//Private
	var getScreenName, setupResponse, setCaretToEnd, showHideControls, setupResponse,
	setupToggleExtendedTweet;

	getScreenName = function(el) {
		return $(el).parents('.tweet').find('.sender').attr('title')
	};

	// modified from http://parentnode.org/javascript/working-with-the-cursor-position/
	setCaretToEnd = function(obj) { 
		var pos = $(obj).text().length
		if(obj.createTextRange) { 
			/* Create a TextRange, set the internal pointer to
			a specified position and show the cursor at this
			position
			*/ 
			var range = obj.createTextRange(); 
			range.move("character", pos); 
			range.select(); 
		} else if(obj.selectionStart) { 
			/* Gecko is a little bit shorter on that. Simply
			focus the element and set the selection to a
			specified position
			*/ 
			obj.focus();         
			obj.setSelectionRange(pos, pos); 
		} 
	};

	showHideControls = function () {
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

	setResponseAction = function (type, formatter) {
		$('.'+type).click( function (){
			var parents = $(this).parents('.tweet');
			parents.find('.status_text').text(formatter(this, parents.find('.text').focus().text())); 
			parents.find('.actions li').removeClass('down');
			parents.find('.send_response').show();
			setCaretToEnd(parents.find('.status_text').get(0));
			$(this).addClass('down');
			return false;                            
		});                                                                   
	};

	setupToggleExtendedTweet = function() {
		$('.tweet').each(function(){
			var toggle = $(this).append('<p class="toggle">toggle</p>')
			toggle.click( function() { $(this).toggleClass('collapsed');} );
		});
	}

	return {
		init: init
	};
}());
