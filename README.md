# NeoVier/ipe-cli

Create modern backend applications using a strict functional programming language. Ipe tries to bring the Elm goodness to the backend, so we can build reliable and delightful apps all the way around!

This repository represents the CLI used to compile Ipe code. To use the compiler as an Elm package, checkout [Ipe's Compiler](https://github.com/NeoVier/ipe-compiler)

## Design Goals

- A strictly-typed functional language
- Delightful to use when building backend apps

## Usage

There are a bunch of helper scripts in `package.json`. So first, install all dependencies with `yarn install`. You can execute/run the compiler with `yarn execute <FILENAME>`, or build the project with `yarn build`.

## Developing

We use [elm-ts-interop](https://elm-ts-interop.com) in order to ensure nice type exchange between typescript and Elm, so you need to run `yarn gen:ts-interop` in order to get correct types. You can also watch type generation with `watch:ts-interop`. Similar commands are available for `elm` and `ts`, but you can run `yarn watch` to watch everything concurrently.

You can check code quality with `elm-review` and `eslint` with `yarn review:elm` or `yarn review:ts`. You can also run `yarn review` to run both of those commands sequentially.

## Learning Resources

Feel free to reach out to me on the [Elm Slack](https://elmlang.herokuapp.com/)! You can send me a DM or @ me, my username is `Henrique Buss`. Usually, programming language development is discussed in the #language-implementation channel.
