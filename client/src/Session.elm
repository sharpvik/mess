module Session exposing (..)

import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder)


type Session
    = DidNotCheckYet Nav.Key
    | Guest Nav.Key
    | User Nav.Key Info


type alias Info =
    { handle : String
    , name : String
    }


decoder : Decoder Info
decoder =
    Decode.map2 Info
        (Decode.field "handle" Decode.string)
        (Decode.field "name" Decode.string)


toKey : Session -> Nav.Key
toKey session =
    case session of
        DidNotCheckYet key ->
            key

        Guest key ->
            key

        User key _ ->
            key
