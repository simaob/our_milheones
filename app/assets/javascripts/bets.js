// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $('#randomizer').click(function(e) {
    e.preventDefault();
    var random = [];
    var num;
    while(random.length < 5) {
     num = Math.ceil((Math.random()*50)+1);
     if(random.indexOf(num) === -1){
       random.push(num);
     }
    }
    $('#bet_bet_numbers').val('');
    $('#bet_bet_numbers').val(random.toString());
    random = [];
    while(random.length < 2) {
     num = Math.ceil((Math.random()*11)+1);
     if(random.indexOf(num) === -1){
       random.push(num);
     }
    }
    $('#bet_bet_stars').val('');
    $('#bet_bet_stars').val(random.toString());
  });
});
