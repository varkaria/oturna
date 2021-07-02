var x = setInterval(function () {
    // Get today's date and time
    var now = new Date().getTime();
    // Find the distance between now and the count down date
    var distance = countDownDate - now;
    var doasone = 0
    // Time calculations for days, hours, minutes and seconds
    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

    function formatTime(time) {
        return time < 10 ? `0${time}` : time;
    }

    document.getElementById("timer").innerHTML = formatTime(minutes) + ":" + formatTime(seconds);
    document.getElementById("timer-sec").innerHTML = formatTime(seconds);

    if (distance < 0) {
        clearInterval(x);
    }
}, 1000);