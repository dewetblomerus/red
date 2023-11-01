// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from '../vendor/topbar'

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content')

let Hooks = {}

Hooks.Say = {
  mounted() {
    this.handleEvent('Say', ({ utterance }) => {
      const utter = new SpeechSynthesisUtterance(utterance)
      window.speechSynthesis.cancel()
      utter.rate = 0.8
      window.speechSynthesis.speak(utter)
      console.log('Tried to say the word')

      const element = document.getElementById('repeatButton')
      element.addEventListener('click', function () {
        console.log("You've clicked the repeat button")
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak(utter)
      })

      document.body.onkeyup = function (e) {
        if (e.key == ' ' || e.code == 'Space' || e.keyCode == 32) {
          console.log("You've pressed the spacebar")
          window.speechSynthesis.cancel()
          window.speechSynthesis.speak(utter)
        }
      }
    })
  },
}

let liveSocket = new LiveSocket('/live', Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', (_info) => topbar.show(300))
window.addEventListener('phx:page-loading-stop', (_info) => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
