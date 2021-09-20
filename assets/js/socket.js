import {Socket} from "phoenix"

let socket = new Socket("/socket")
socket.connect()

let channel = socket.channel("lnd_node_status:status", {})

channel.join()
    .receive("ok", (resp, yo) => { 
        console.log("Joined successfully")
        console.dir(resp)
    })
    .receive("error", resp => { console.log("Unable to join", resp)})

channel.on('lnd_node_status:status', payload => {
    let detail = { is_up: payload.status === "UP"}

    console.log("LND node is " + (detail.is_up ? "up" : "down"))

    let event = new CustomEvent("lnd-node-status", { detail })
    window.dispatchEvent(event)
})

channel.on('node_status', detail => {
    console.log("GOT NODE STATUS")
    console.dir(detail)

    let event = new CustomEvent("lnd-node-status", { detail })
    window.dispatchEvent(event)
})

export default socket