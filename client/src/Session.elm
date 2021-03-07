module Session exposing (..)

import Browser.Navigation as Nav


type alias Handle =
    String


type alias Name =
    String


type Session
    = Guest Nav.Key
    | User Nav.Key Handle Name


dummy : Nav.Key -> Session
dummy key =
    User key "sarah" "Sarah Binet"
