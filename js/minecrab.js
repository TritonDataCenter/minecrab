$(function() {
  // collapse navbar when clicked
  $('.navbar-collapse a').click(function() {
    $('.navbar-collapse').collapse('hide');
  });

  // navbar watches scroll position
  $('body').scrollspy({ target: '.navbar-collapse', offset: 50 })
});
