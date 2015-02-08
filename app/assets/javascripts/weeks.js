// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//
$(document).on('ready page:load', function() {
  $('#week_solution_stars').select2({
    maximumSelectionSize: 2
  });
  $('#week_solution_numbers').select2({
    maximumSelectionSize: 5
  });
});
