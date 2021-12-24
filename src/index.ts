import { Elm } from './Main.elm'
import fs from 'fs'

const version = '0.0.0'

const app = Elm.Main.init({
  flags: {
    argv: process.argv,
    versionMessage: `Ipe compiler v${version}`,
    otherFlags: {}
  }
})

app.ports.interopFromElm.subscribe((fromElm) => {
  switch (fromElm.tag) {
    case 'exitFailure': {
      console.error(fromElm.data.message)
      break
    }
    case 'exitSuccess': {
      console.log(fromElm.data.message)
      break
    }
    case 'requestedFile': {
      fs.readFile(fromElm.data.filename, (err, data) => {
        if (err) {
          // TODO
          throw err
        }

        app.ports.interopToElm.send({ tag: 'gotFile', file: data })
      })
      break
    }
  }
})
