// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//

import Item from "./fptool/item.js";
import DownloadSvg from "./fptool/downloadSvg.js";

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {
    RelayHook: {
        mounted() {
            window.addEventListener('relay-event', e => this.pushEvent(e.detail.signal, e.detail.payload));
        }
    },
    ItemHook: {
        mounted() { Item.init(this.el) },
        updated() { Item.update(this.el) }
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

window.pushEventToServer = function (signal, payload) {
    const event = new CustomEvent('relay-event', { detail: { payload, signal } });
    window.dispatchEvent(event);
}

window.downloadSvg = function () { DownloadSvg.download() }

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
liveSocket.disableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

