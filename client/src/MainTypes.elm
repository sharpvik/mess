module MainTypes exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Routes exposing (Route)
import Url exposing (Url)


type alias Model =
    { route : Route
    , key : Nav.Key
    }


type Msg
    = LinkClicked UrlRequest
    | LinkChanged Url
    | Nop
