// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('page:load', function() {
  $('#bet_bet_stars').select2({
    maximumSelectionSize: 2
  });
  $('#bet_bet_numbers').select2({
    maximumSelectionSize: 5
  });
});
