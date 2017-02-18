$(document).ready(function() {
    
    var quotes = [
        'When 900 years old, you reach… Look as good, you will not.',
        'The Dark Side of the Force is the pathway to many abilities some consider to be… Unnatural.' ,
        'He’s holding a thermal detonator!',
        'You can’t win, Darth. Strike me down, and I will become more powerful than you could possibly imagine.',
        'Lando’s not a system he’s a man!',
        'If there`s a bright centre to the universe, you`re on the planet that it`s farthest from.',
        'Fear is the path to the dark side.',
        'At last we will reveal ourselves to the Jedi. At last we will have revenge.'
    ];

    $(document).foundation();

    $('[type="submit"]').on( 'click', function() {

        var item = quotes[Math.floor(Math.random()*quotes.length)];

        $('.loadwrapper .text').html(item);

        $('.loadwrapper').show();

    });
});
