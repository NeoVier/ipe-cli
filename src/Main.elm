module Main exposing (CliOptions, Model, Msg, main)

import Cli.Option
import Cli.OptionsParser
import Cli.OptionsParser.BuilderState
import Cli.Program
import InteropDefinitions
import InteropPorts
import Json.Decode
import Json.Encode


main : Cli.Program.StatefulProgram Model Msg CliOptions { otherFlags : Json.Encode.Value }
main =
    Cli.Program.stateful
        { config = config
        , init = init
        , printAndExitFailure =
            InteropDefinitions.PrintAndExitFailure
                >> InteropPorts.fromElm
        , printAndExitSuccess =
            InteropDefinitions.PrintAndExitSuccess
                >> InteropPorts.fromElm
        , subscriptions = subscriptions
        , update = update
        }


type CliOptions
    = CompileFile MakeOptions


type alias MakeOptions =
    { filename : String
    }


config : Cli.Program.Config CliOptions
config =
    Cli.Program.config
        |> Cli.Program.add (Cli.OptionsParser.map CompileFile buildCommand)


buildCommand : Cli.OptionsParser.OptionsParser MakeOptions Cli.OptionsParser.BuilderState.AnyOptions
buildCommand =
    Cli.OptionsParser.buildSubCommand "make" MakeOptions
        |> Cli.OptionsParser.with (Cli.Option.requiredPositionalArg "filename")


type alias Model =
    {}


init :
    Cli.Program.FlagsIncludingArgv { otherFlags : Json.Encode.Value }
    -> CliOptions
    -> ( Model, Cmd Msg )
init { otherFlags } (CompileFile { filename }) =
    case InteropPorts.decodeFlags otherFlags of
        Ok _ ->
            ( {}
            , InteropDefinitions.RequestedFile filename
                |> InteropPorts.fromElm
            )

        Err error ->
            ( {}
            , Json.Decode.errorToString error
                |> InteropDefinitions.PrintAndExitFailure
                |> InteropPorts.fromElm
            )


type Msg
    = GotFile InteropDefinitions.FileInfo
    | GotErrorDecodingToElmPort Json.Decode.Error


update : CliOptions -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg _ =
    case msg of
        GotFile file ->
            ( {}
            , ("Successfuly read file\n" ++ file.contents)
                |> InteropDefinitions.PrintAndExitSuccess
                |> InteropPorts.fromElm
            )

        GotErrorDecodingToElmPort error ->
            ( {}
            , Json.Decode.errorToString error
                |> InteropDefinitions.PrintAndExitFailure
                |> InteropPorts.fromElm
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    InteropPorts.toElm
        |> Sub.map
            (\toElm ->
                case toElm of
                    Ok (InteropDefinitions.GotFile file) ->
                        GotFile file

                    Err error ->
                        GotErrorDecodingToElmPort error
            )
