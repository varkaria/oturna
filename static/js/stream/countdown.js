// Update the count down every 1 second
anime({
    targets: '.count-number',
    translateY: ["20px", "0px"],
    easing: "easeInOutExpo",
    opacity: [0, 1],
    duration: 600
  });

var x = setInterval(function () {
    // Get today's date and time
    var now = new Date().getTime();
    // Find the distance between now and the count down date
    var distance = countDownDate - now;
    var doasone = 0
    // Time calculations for days, hours, minutes and seconds
    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);
    var vid = document.getElementById("myVideo"); 

    function formatTime(time) {
        return time < 10 ? `0${time}` : time;
    }

    document.getElementById("timer").innerHTML = formatTime(minutes) + ":" + formatTime(seconds);

    if (distance < 0) {
        clearInterval(x);
        if (doasone == 0) {
            document.getElementById('timer').remove()
            vid.mute = true; // without this line it's not working although I have "muted" in HTML
            vid.play();
            doasone = 1
        }
    }
}, 1000);

let socket = new ReconnectingWebSocket("ws://127.0.0.1:24050/ws");

socket.onopen = () => {
	console.log("Successfully Connected");
};

socket.onclose = event => {
	console.log("Socket Closed Connection: ", event);
	socket.send("Client Closed!")
};

socket.onerror = error => {
	console.log("Socket Error: ", error);
};

let tempState;

socket.onmessage = event => {
	let data = JSON.parse(event.data);
	if (tempState !== data.menu.bm.id) {
        tempState = data.menu.bm.id
        anime({
            targets: '.song_data',
            opacity: [1, 0],
            duration: 800
        });
        document.getElementById("song").innerHTML = data.menu.bm.metadata.artist + " - " + data.menu.bm.metadata.title
        anime({
            targets: '.song_data',
            opacity: [0, 1],
            duration: 800
        });
	}
}