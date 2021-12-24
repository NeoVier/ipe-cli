import { Elm } from './Main.elm'

const app = Elm.Main.init({
  flags: {
    argv: [],
    // TODO
    versionMessage: ''
  }
})

console.log(app)
