// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load', function() {
  var stars = ['1', '2', '3', '4', '5', '6'];
  $('#bet_bet_stars').select2({
    tags: stars,
    tokenSeparators: [',', ' '],
    maximumSelectionSize: 2,
    createSearchChoice: function(term) {
      if(stars.indexOf(term) > 0) {
        return { id: term, text: term };
      } else {
        return null;
      }
    }
  });

  var numbers = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
    '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50'
  ];
  $('#bet_bet_numbers').select2({
    tags: numbers,
    tokenSeparators: [',', ' '],
    maximumSelectionSize: 5,
    createSearchChoice: function(term) {
      if(numbers.indexOf(term) > 0) {
        return { id: term, text: term };
      } else {
        return null;
      }
    }
  });
});
