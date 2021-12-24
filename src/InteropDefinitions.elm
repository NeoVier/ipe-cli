module InteropDefinitions exposing (Flags, FromElm(..), ToElm(..), interop)

import Json.Encode
import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Decode.Pipeline as TsDecodePipeline
import TsJson.Encode as TsEncode exposing (Encoder, optional, required)


interop :
    { toElm : Decoder ToElm
    , fromElm : Encoder FromElm
    , flags : Decoder Flags
    }
interop =
    { toElm = toElm
    , fromElm = fromElm
    , flags = flags
    }


type FromElm
    = PrintAndExitFailure String
    | PrintAndExitSuccess String


type ToElm
    = AuthenticatedUser User


type alias User =
    { username : String }


type alias Flags =
    { argv : List String
    , versionMessage : String
    }


fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\vPrintAndExitFailure vPrintAndExitSuccess value ->
            case value of
                PrintAndExitFailure string ->
                    vPrintAndExitFailure string

                PrintAndExitSuccess string ->
                    vPrintAndExitSuccess string
        )
        |> TsEncode.variantTagged "exitFailure"
            (TsEncode.object [ required "message" identity TsEncode.string ])
        |> TsEncode.variantTagged "exitSuccess"
            (TsEncode.object [ required "message" identity TsEncode.string ])
        |> TsEncode.buildUnion


toElm : Decoder ToElm
toElm =
    TsDecode.discriminatedUnion "tag"
        [ ( "authenticatedUser"
          , TsDecode.map AuthenticatedUser
                (TsDecode.map User
                    (TsDecode.field "username" TsDecode.string)
                )
          )
        ]


flags : Decoder Flags
flags =
    TsDecode.succeed Flags
        |> TsDecodePipeline.required "argv" (TsDecode.list TsDecode.string)
        |> TsDecodePipeline.required "versionMessage" TsDecode.string
