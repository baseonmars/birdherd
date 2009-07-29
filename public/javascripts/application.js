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

		setupHideStickyTweet();
		setupTweetHover();                                             
		setupCharacterCounts();

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
	setupToggleExtendedTweet,setupHoverBehaviour,setupCharacterCounts;

	getScreenName = function(el) {
		return $(el).parents('.tweet').find('.sender').attr('title')
	};

	// modified from http://parentnode.org/javascript/working-with-the-cursor-position/
	setCaretToEnd = function(obj) {
		var pos = $(obj).text().length
		if(obj.createTextRange) { 
			// NOT USED, CAUSES SCROLL ISSUE IN SAFARI
			/* Create a TextRange, set the internal pointer to
			a specified position and show the cursor at this
			position
			*/ 
			// var range = obj.createTextRange(); 
			// 			range.move("character", pos); 
			// 			range.select(); 
		} else if(obj.selectionStart) { 
			/* Gecko is a little bit shorter on that. Simply
			focus the element and set the selection to a
			specified position
			*/ 
			obj.setSelectionRange(pos, pos);
			obj.focus();             
		}
	};

	showHideControls = function () {
		$('#toggle-status-update').replaceWith('<div id="toggle-status-update" ><span>Toggle status updates</span></div>')

		$('#toggle-status-update').live('click',function (){
			$('#status-update').toggle('fast',function(){
				if ($(this).css('display') === 'none') {
					$('#columns').css({top: '5em'});      
					$('#toggle-status-update').removeClass('up').addClass('down');
 				} else {
  				$('#columns').css({top: '17.8em'});
					$('#toggle-status-update').removeClass('down').addClass('up');
				}
			});
		});
	};

	setResponseAction = function (type, formatter) {
		$('.'+type).live('click', function (){
			var parents = $(this).parents('.tweet');
			parents.find('.status_text').text(formatter(this, parents.find('.text').focus().text())); 
			parents.find('.actions li').removeClass('down');
			parents.addClass('sticky');
			parents.removeClass('active');
			$('.actions',parents).removeClass('inactive');
			// setCaretToEnd(parents.find('.status_text').get(0));
			$(this).addClass('down');                          
			return false;
		});                                                                   
	};

	setupHideStickyTweet = function() {
		$('.tweet').each(function(){
			$(this).append('<p class="hide-tweet">Hide</p>');
		});
		$('.tweet .hide-tweet').live('click', function() { 
			$(this).parents('.tweet').addClass('collapsed').removeClass('sticky');
		});	
	}  
	
	setupTweetHover = function() {
		$('.tweet').live('mouseover', function() {
			if ($(this).hasClass('active') || $(this).hasClass('sticky')) {
				clearTimeout(this.hideTimer);
				return;
			}                                       
			$(this).addClass('active').removeClass('collapsed');
			$('.actions', this).addClass('inactive');
		});
		$('.tweet').live('mouseout', function() {
			var that = this;
			that.hideTimer =  setTimeout(function(){
				if ($(that).hasClass('sticky')) {
					return;
				} 		 
				$(that).removeClass('active').addClass('collapsed');
				$('.actions', that).removeClass('inactive');
				$('.actions li', that).removeClass('down');	
				}, 50
			);
		}); 
	} 
	
	setupCharacterCounts = function () { 
		$('.tweet_post_form textarea').each(function(){  
		    // get current number of characters  
		    var length = $(this).val().length;  
		    // get current number of words  
		    //var length = $(this).val().split(/\b[\s,\.-:;]*/).length;  
		    // update characters  
		    $(this).parent().find('.count').html(length);  
		    // bind on key up event  
		    $(this).keyup(function(){  
		        // get new length of characters  
		        var new_length = $(this).val().length;  
		        // get new length of words  
		        //var new_length = $(this).val().split(/\b[\s,\.-:;]*/).length;  
		        // update  
		        $(this).parent().find('.count').html(new_length);   
						if ( tweet_length > 140) { 
							$(this).parents('.charcount .count').css({color: 'red'});
						} else { 
							$(this).parents('.charcount .count').css({color: 'inherit'});
						}
		    });  
		});
	}
    
	// Public
	return {
		'init': init
	};
}());
