// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load', function() {
  $('#randomizer').click(function(e) {
    e.preventDefault();
    var random = [];
    var num;
    while(random.length < 5) {
     num = Math.floor((Math.random()*50)+1);
     if(random.indexOf(num) === -1){
       random.push(num);
     }
    }
    random = random.sort();
    $('#bet_bet_numbers').select2('val', random);
    random = [];
    while(random.length < 2) {
     num = Math.floor((Math.random()*11)+1);
     if(random.indexOf(num) === -1){
       random.push(num);
     }
    }
    random = random.sort();
    $('#bet_bet_stars').select2('val', random);
  });
});
