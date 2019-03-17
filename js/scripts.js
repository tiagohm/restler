/* 
 Created on : Jul 4, 2017, 12:43:10 AM
 Author     : Atta-Ur-Rehman Shah (http://attacomsian.com)
 */
$(function () {

    //init wow effects
    new WOW().init();

    //scroll menu
    $(window).scroll(function () {
        var secondFeature = $('#features').offset().top;
        var scroll = $(window).scrollTop();
        if (scroll >= 300) {
            $('.sticky-navigation').css({"top": '0px'});
        } else {
            $('.sticky-navigation').css({"top": '-100px'});
        }
        if (scroll >= secondFeature - 200) {
            $(".mobileScreen").css({'background-position': 'center top'});
        }
        return false;
    });
    
    //page scroll
    $('a.page-scroll').bind('click', function (event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top - 20
        }, 1500, 'easeInOutExpo');
        event.preventDefault();
    });
});