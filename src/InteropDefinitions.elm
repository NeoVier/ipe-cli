module InteropDefinitions exposing (FileInfo, Flags, FromElm(..), ToElm(..), interop)

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
    = GotFile FileInfo


type alias FileInfo =
    -- TODO - Move to another module?
    { contents : String }


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
          , TsDecode.map GotFile (TsDecode.field "file" fileInfoDecoder)
          )
        ]


fileInfoDecoder : Decoder FileInfo
fileInfoDecoder =
    TsDecode.map FileInfo
        (TsDecode.field "contents" TsDecode.string)


flags : Decoder Flags
flags =
    TsDecode.succeed Flags
        |> TsDecodePipeline.required "argv" (TsDecode.list TsDecode.string)
        |> TsDecodePipeline.required "versionMessage" TsDecode.string
        |> TsDecodePipeline.required "otherFlags" (TsDecode.succeed {})
