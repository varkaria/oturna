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

	if (data.menu.state == 2) {
        if (tempState !== data.menu.state) {
            tempState = data.menu.state
            document.querySelector('#songs').innerHTML += `
            <div class="song pre-animation" id="${Math.random().toString(36).substring(7)}">
                <div class="l-side">
                    <div class="song-meta">
                        <div class="artist">${map.metadata.artist}</div>
                        <div class="title">${map.metadata.title}</div>
                    </div>
                    <div class="song-stats">Star : <b>${map.stats.fullSR}</b> OD : <b>${map.stats.memoryOD}</b></div>
                </div>
                <div class="r-side">
                    <div class="stage">Stage ${stage}</div>
                </div>
                <div class="map-darker"></div>
                <img src="http://127.0.0.1:24050/Songs/${data.menu.bm.path.full}?a=${Math.random(10000)}" class="map-bg">
            </div>
            `
            setTimeout(function(){
                document.querySelector('.pre-animation').classList.remove('pre-animation')
            },1500)

            stage = stage + 1
        }
    } else {
        if (tempState !== data.menu.state) {
            tempState = data.menu.state
        }
    }
}
