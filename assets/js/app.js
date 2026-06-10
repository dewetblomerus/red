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
    this.playSpeech = null
    this.playbackSpeed = 1.1

    const getPlaybackSpeed = () => {
      const speedControl = document.getElementById('playbackSpeed')
      const speed = speedControl
        ? Number.parseFloat(speedControl.value)
        : this.playbackSpeed

      return Number.isFinite(speed) && speed > 0 ? speed : 1.1
    }

    this.playbackSpeed = getPlaybackSpeed()

    this.handleEvent('Say', ({ utterance, audio_url }) => {
      const speakWithBrowser = function () {
        const utter = new SpeechSynthesisUtterance(utterance)
        utter.rate = getPlaybackSpeed()

        window.speechSynthesis.cancel()
        window.speechSynthesis.speak(utter)
      }

      this.playSpeech = speakWithBrowser

      if (audio_url) {
        const audio = new Audio(audio_url)
        audio.preload = 'auto'

        let settled = false

        const useGeneratedAudio = function () {
          audio.currentTime = 0
          audio.playbackRate = getPlaybackSpeed()
          window.speechSynthesis.cancel()
          audio.play()
        }

        const chooseGeneratedAudio = () => {
          if (settled) return
          settled = true
          this.playSpeech = useGeneratedAudio
          useGeneratedAudio()
        }

        const chooseBrowserSpeech = () => {
          if (settled) return
          settled = true
          this.playSpeech = speakWithBrowser
          speakWithBrowser()
        }

        audio.addEventListener('canplay', chooseGeneratedAudio, { once: true })
        audio.addEventListener('error', chooseBrowserSpeech, { once: true })
        window.setTimeout(chooseBrowserSpeech, 3000)
        audio.load()
      } else {
        speakWithBrowser()
      }
    })

    document.addEventListener('click', (e) => {
      if (e.target && e.target.id === 'repeatButton' && this.playSpeech) {
        this.playSpeech()
      }
    })

    document.addEventListener('change', (e) => {
      if (e.target && e.target.id === 'playbackSpeed') {
        this.playbackSpeed = getPlaybackSpeed()
      }
    })

    document.body.addEventListener('keyup', (e) => {
      if (
        (e.key == ' ' || e.code == 'Space' || e.keyCode == 32) &&
        this.playSpeech
      ) {
        this.playSpeech()
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
