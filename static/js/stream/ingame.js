// START
let socket = new ReconnectingWebSocket("ws://127.0.0.1:24050/ws");

// Connecting to gosumemory websocket
socket.onopen = () => {
    console.log("Successfully Connected");
};

socket.onclose = event => {
    console.log("Socket Closed Connection: ", event);
    socket.send("Client Closed!");
};

socket.onerror = error => {
    console.log("Socket Error: ", error);
};

function reflow(elt) {
    elt.offsetHeight;
}

socket.onmessage = event => {
    try {
        let data = JSON.parse(event.data),
            players = data.tourney.ipcClients,
            state = data.tourney.manager.ipcState;

        if (state == 3) { // Ingame Screen
            document.body.className = "";
            players.forEach(function callback(value, index) {
                $(`.p${index + 1} #h350`).html(value.gameplay.hits['geki'])
                $(`.p${index + 1} #h300`).html(value.gameplay.hits[300])
                $(`.p${index + 1} #h200`).html(value.gameplay.hits['katu'])
                $(`.p${index + 1} #h100`).html(value.gameplay.hits[100])
                $(`.p${index + 1} #h50`).html(value.gameplay.hits[50])
                $(`.p${index + 1} #h0`).html(value.gameplay.hits[0])
                $(`.p${index + 1} #ur`).html(value.gameplay.hits.unstableRate.toFixed())
            });
        } else { // Not Gameplay + Result
            document.body.className = "songSelect";
        };
    } catch (err) { console.log(err); };
};