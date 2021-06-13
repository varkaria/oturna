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
let stage = 1;

function removespacebar(d) {
    return d.replace(/ /g, '%20')
}

socket.onmessage = event => {
	let data = JSON.parse(event.data),
        map = data.menu.bm;

	if (data.menu.state == 7) {
        if (tempState !== data.menu.state) {
            tempState = data.menu.state
            document.getElementById("bimg").src = `http://127.0.0.1:24050/Songs/${data.menu.bm.path.full}?a=${Math.random(10000)}`;
            document.getElementById("title").innerHTML = map.metadata.title
            document.getElementById("artist").innerHTML = map.metadata.artist
            document.getElementById("mapper").innerHTML = map.metadata.mapper
            document.getElementById("diff").innerHTML = map.metadata.difficulty
            document.getElementById("star").innerHTML = map.stats.fullSR
            document.getElementById("od").innerHTML = map.stats.memoryOD
            document.getElementById("hp").innerHTML = map.stats.memoryHP
            document.getElementById("bpm").innerHTML = map.stats.bpm.max
            document.getElementById("removeme").classList.remove("remove-me");
        }
    } else {
        if (tempState !== data.menu.state) {
            tempState = data.menu.state
        }
    }
}
