$(function() {

    $('#page-wrapper').on('click', '.datepicker', function(){
        $(this).datepicker({ dateFormat: 'yy-mm-dd' });
        $(this).datepicker('show');
    });
    $('body').on('click', '.datepicker', function(){
        console.log("click");
        $(this).datepicker({ dateFormat: 'yy-mm-dd' });
        $(this).datepicker('show');
    });
    $('#navigation').toggle(800);
    $('#sidebar').toggle(800).promise().done(function(){
        $('#visible').toggle(800);
    });
    $('#logout').on('click', function(){
        var href = $(this).attr('href');
        $('#visible').toggle(800).promise().done(function(){
            $('#navigation').toggle(800);
            $('#sidebar').toggle(800).promise().done(function(){
                window.location = href;
            })
        })
        return false;
    });


    $( 'li.dropdown' ).each(function() {
        var self = this;
        var link = $(self).children('a')[0];
        var href = $(link).attr('href');
        // Expand menu on click
        $(link).on('click', function() {
            var sub_menu = $(self).children('ul');
            $(self).toggleClass('active');
            $(sub_menu).toggle(300);
            return false;
        });
    });

});

//Loads the correct sidebar on window load,
//collapses the sidebar on window resize.
// Sets the min-height of #page-wrapper to window size
$(function() {
    $(window).bind("load resize", function() {
        topOffset = 50;
        width = (this.window.innerWidth > 0) ? this.window.innerWidth : this.screen.width;
        if (width < 768) {
            $('div.navbar-collapse').addClass('collapse');
            topOffset = 100; // 2-row-menu
        } else {
            $('div.navbar-collapse').removeClass('collapse');
        }

        height = ((this.window.innerHeight > 0) ? this.window.innerHeight : this.screen.height) - 1;
        height = height - topOffset;
        if (height < 1) height = 1;
        if (height > topOffset) {
            $("#page-wrapper").css("min-height", (height) + "px");
        }
    });
});
