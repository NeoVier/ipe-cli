module InteropDefinitions exposing (Flags, FromElm(..), ToElm(..), interop)

import File
import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Decode.Pipeline as TsDecodePipeline
import TsJson.Encode as TsEncode exposing (Encoder, required)


interop :
    { flags : Decoder Flags
    , fromElm : Encoder FromElm
    , toElm : Decoder ToElm
    }
interop =
    { flags = flags
    , fromElm = fromElm
    , toElm = toElm
    }


type FromElm
    = PrintAndExitFailure String
    | PrintAndExitSuccess String
    | RequestedFile String


type ToElm
    = GotFile File.File


type alias Flags =
    { argv : List String
    , versionMessage : String
    , otherFlags : {}
    }


fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\vPrintAndExitFailure vPrintAndExitSuccess vRequestedFile value ->
            case value of
                PrintAndExitFailure string ->
                    vPrintAndExitFailure string

                PrintAndExitSuccess string ->
                    vPrintAndExitSuccess string

                RequestedFile filename ->
                    vRequestedFile filename
        )
        |> TsEncode.variantTagged "exitFailure"
            (TsEncode.object [ required "message" identity TsEncode.string ])
        |> TsEncode.variantTagged "exitSuccess"
            (TsEncode.object [ required "message" identity TsEncode.string ])
        |> TsEncode.variantTagged "requestedFile"
            (TsEncode.object [ required "filename" identity TsEncode.string ])
        |> TsEncode.buildUnion


toElm : Decoder ToElm
toElm =
    TsDecode.discriminatedUnion "tag"
        [ ( "gotFile"
          , TsDecode.map GotFile (TsDecode.field "data" fileDecoder)
          )
        ]


fileDecoder : Decoder File.File
fileDecoder =
    TsDecode.succeed ()
        |> TsDecode.unknownAndThen (\_ -> File.decoder)


flags : Decoder Flags
flags =
    TsDecode.succeed Flags
        |> TsDecodePipeline.required "argv" (TsDecode.list TsDecode.string)
        |> TsDecodePipeline.required "versionMessage" TsDecode.string
        |> TsDecodePipeline.required "otherFlags" (TsDecode.succeed {})
