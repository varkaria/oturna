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

let side = "left";
let tempState;
socket.onmessage = event => {
	let data = JSON.parse(event.data);
	if (tempState !== data.menu.bm.path.full) {
		tempState = data.menu.bm.path.full
		document.querySelector('.song-data').innerHTML = `${data.menu.bm.metadata.artist} - ${data.menu.bm.metadata.title}`

        if (side == 'left') {
            document.getElementById("one").src = `http://127.0.0.1:24050/Songs/${data.menu.bm.path.full}?a=${Math.random(10000)}`;
            document.getElementById("two").className = 'hide'
            document.getElementById("one").className = ''
            side = 'right'
        } else if (side == 'right') {
            document.getElementById("two").src = `http://127.0.0.1:24050/Songs/${data.menu.bm.path.full}?a=${Math.random(10000)}`;
            document.getElementById("one").className = 'hide'
            document.getElementById("two").className = ''
            side = 'left'
        }
	}
}

particlesJS("particles-js", {
    "particles": {
        "number": {
            "value": 10,
            "density": {
                "enable": true,
                "value_area": 800
            }
        },
        "shape": {
            "type": "circle",
			"stroke": {
				"width": 2,
				"color": "#b6b2b2"
			}
        },
        "opacity": {
            "value": 0.1736124811591,
            "random": true,
            "anim": {
                "enable": false,
                "speed": 1,
                "opacity_min": 0.1,
                "sync": false
            }
        },
        "size": {
            "value": 15.782952832645451,
            "random": true,
            "anim": {
                "enable": false,
                "speed": 40,
                "size_min": 0.1,
                "sync": false
            }
        },
        "line_linked": {
            "enable": false,
            "distance": 500,
            "color": "#ffffff",
            "opacity": 0.4,
            "width": 2
        },
        "move": {
            "enable": true,
            "speed": 1,
            "direction": "top",
            "random": false,
            "straight": false,
            "out_mode": "out",
            "bounce": false,
            "attract": {
                "enable": false,
                "rotateX": 2805.971106514665,
                "rotateY": 1200
            }
        }
    },
    "interactivity": {
        "detect_on": "canvas",
        "events": {
            "onhover": {
                "enable": false,
                "mode": "bubble"
            },
            "onclick": {
                "enable": true,
                "mode": "repulse"
            },
            "resize": true
        },
        "modes": {
            "grab": {
                "distance": 400,
                "line_linked": {
                    "opacity": 0.5
                }
            },
            "bubble": {
                "distance": 400,
                "size": 4,
                "duration": 0.3,
                "opacity": 1,
                "speed": 3
            },
            "repulse": {
                "distance": 200,
                "duration": 0.4
            },
            "push": {
                "particles_nb": 4
            },
            "remove": {
                "particles_nb": 2
            }
        }
    },
    "retina_detect": true
});