module Main exposing (main)

import Cli.Program
import InteropDefinitions
import InteropPorts



-- main : Program (Cli.Program.FlagsIncludingArgv InteropDefinitions.Flags) (Cli.Program.StatefulProgramModel Model CliOptions) Msg
-- main : Cli.Program.StatefulProgram Model Msg CliOptions InteropDefinitions.Flags


main =
    Cli.Program.stateful
        { printAndExitFailure =
            InteropDefinitions.PrintAndExitFailure
                >> InteropPorts.fromElm
        , printAndExitSuccess =
            InteropDefinitions.PrintAndExitSuccess
                >> InteropPorts.fromElm
        , init = init
        , update = update
        , subscriptions = subscriptions
        , config = config
        }


type CliOptions
    = NoOptions


config : Cli.Program.Config CliOptions
config =
    Cli.Program.config


type alias Model =
    {}


init : InteropDefinitions.Flags -> CliOptions -> ( Model, Cmd Msg )
init _ _ =
    ( {}, Cmd.none )


type Msg
    = NoOp


update : CliOptions -> Msg -> Model -> ( Model, Cmd Msg )
update _ _ _ =
    ( {}, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
