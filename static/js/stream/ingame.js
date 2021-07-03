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

let once = 0

socket.onmessage = event => {
    try {
        let data = JSON.parse(event.data),
            state = data.tourney.manager.ipcState;
        if (state == 3) { // Ingame Screen
            document.body.className = "";
            once = 0
        } else { // Not Gameplay + Result
            document.body.className = "songSelect";
            var tl = anime.timeline({
                easing: 'easeOutExpo',
                duration: 1000
            });
            
            if (once == 0) {
                once = 1
                fetch(`https://omthpl.varkaria.tech/manager/matchapi/${currentset}/`)
                .then(response => response.json())
                .then(data => {
                    if (data.sets[`${data.currentround[0]}`].finish == false) {
                        data.sets[`${data.currentround[0]}`].pick.forEach(function(element, index) {
                            if (element.winner) {
                                $(`.pick-result`).append(`
                                <div class="win-0${index+1}">
                                    <div class="w-teamava" style="background-image:url(/team_flag/${element.winner.team})"></div>
                                    <div class="w-team">${element.winner.teamname}</div>
                                    <div class="w-info">Wins from this map</div>
                                </div>
                                `)
                            }
                            $('.pb-list').append(`
                            <div class="pr-0${index+1}" style="background: linear-gradient( rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0.6)), url(https://assets.ppy.sh/beatmaps/${element.info.beatmapset_id}/covers/cover.jpg);">
                                <img class="pr-mods" src="/static/img/mods/${element.mods.toUpperCase()}.png">
                                <div class="pr-title">${element.info.title}</div>
                                <div class="pr-artist">${element.info.artist}</div>
                            </div>
                            `)
                        })
                        $('.pi-01').html(data.sets[`${data.currentround[0]}`].pick[`${data.currentround[1]}`].mods)
                        $('.pi-02').html(data.sets[`${data.currentround[0]}`].pick[`${data.currentround[1]}`].info.title)
                        $('.pi-03').html(data.sets[`${data.currentround[0]}`].pick[`${data.currentround[1]}`].info.artist)
                        $('.bg-w').attr('src', `https://assets.ppy.sh/beatmaps/${data.sets[`${data.currentround[0]}`].pick[`${data.currentround[1]+2}`].info.beatmapset_id}/covers/cover.jpg`)
                        tl.add({
                            targets: '.next-map',
                            opacity: 1
                        })
                        .add({
                            targets: '.bg-mask-l',
                            translateX: ['-800px', '0px'],
                            easing: 'easeInExpo',
                        })
                        .add({
                            targets: '.bg-mask-r',
                            translateX: ['800px', '0px'],
                            easing: 'easeInExpo',
                        }, '-=1000')
                        .add({
                            targets: '.background-text-02',
                            translateX: ['800px', '0px'],
                            opacity: [0, 0.1],
                            duration: 2000
                        })
                        .add({
                            targets: '.background-text-01',
                            translateX: ['-800px', '0px'],
                            opacity: [0, 0.1],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.text-anim',
                            top: ['-800px', '-2642px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.pick-result',
                            opacity: [0, 1],
                            translateY: ['20px', '0px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.pb-list',
                            opacity: [0, 1],
                            translateY: ['20px', '0px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.background-text-02',
                            translateX: ['0px', '1800px'],
                            duration: 2000,
                            delay: 3000
                        })
                        .add({
                            targets: '.background-text-01',
                            translateX: ['0px', '-1800px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.text-anim',
                            top: ['2642px', '-800px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.pick-result',
                            opacity: [1, 0],
                            duration: 500
                        }, '-=2000')
                        .add({
                            targets: '.pb-list',
                            opacity: [1, 0],
                            translateY: ['0px', '20px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.bg-w',
                            opacity: [0, 1],
                            translateY: ['1000px', '0px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.pb-part',
                            opacity: [0, 1],
                            translateY: ['20px', '0px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.pi-part',
                            opacity: [0, 1],
                            translateY: ['-20px', '0px'],
                            duration: 2000
                        }, '-=2000')
                        .add({
                            targets: '.pb-part',
                            opacity: [1, 0],
                            duration: 1000,
                            delay: 6000
                        })
                        .add({
                            targets: '.pi-part',
                            opacity: [1, 0],
                            duration: 1000
                        }, '-=1000')
                        .add({
                            targets: '.bg-w',
                            translateX: ['0px', '415px'],
                            duration: 1000,
                            easing: 'easeOutExpo',
                        }, '-=800')
                        .add({
                            targets: '.bg-mask-l',
                            translateX: ['0px', '-800px'],
                            easing: 'easeOutExpo',
                        })
                        .add({
                            targets: '.bg-mask-r',
                            translateX: ['0px', '800px'],
                            easing: 'easeOutExpo',
                        }, '-=1000')
                        .add({
                            targets: '.bg-w',
                            translateY: ['0px', '815px'],
                            easing: 'easeInExpo',
                        }, '-=1500')
                    };
                });
            }
        };
    } catch (err) {
        console.log(err);
    };
};