import {Socket} from "phoenix"

let socket = new Socket("/socket")
socket.connect()

let channel = socket.channel("lnd_node_status:status", {})

channel.join()
    .receive("ok", (resp, yo) => { 
        console.log("Connected to node")
    })
    .receive("error", resp => { 
        console.log("Unable to connect to node ", resp)
    })

channel.on('lnd_node_status:status', payload => {
    let detail = { is_up: payload.status === "UP"}

    console.log("LND node is " + (detail.is_up ? "up" : "down"))

    let event = new CustomEvent("lnd-node-status", { detail })
    window.dispatchEvent(event)
})

channel.on('node_status', detail => {
    let event = new CustomEvent("lnd-node-status", { detail })

    console.log("NODE STATUS")
    console.dir(detail)
    
    dispatchEventWhenDomReady(event)
})

// inspiration for this function
// https://stackoverflow.com/questions/8100576/how-to-check-if-dom-is-ready-without-a-framework
let dispatchEventWhenDomReady = (event) => {
    if(document.readyState === "complete") {
        window.dispatchEvent(event)
    }
    else {
        window.addEventListener("load", () => {
            window.dispatchEvent(event)
        });
    }
} 

export default socket