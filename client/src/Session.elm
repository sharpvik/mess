module Session exposing (..)


type alias Handle =
    String


type alias Name =
    String


type Session
    = Guest
    | User Handle Name


dummy : Session
dummy =
    User "sarah" "Sarah Binet"
