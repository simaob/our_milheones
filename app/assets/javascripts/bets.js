// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $('#bet_bet_stars').select2({
    maximumSelectionSize: 2,
    tokenSeparators: [',', ' ']
  });
  $('#bet_bet_numbers').select2({
    maximumSelectionSize: 5,
    tokenSeparators: [',', ' ']
  });
});
