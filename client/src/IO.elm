module IO exposing (..)


type IO err ok
    = Waiting
    | Loading
    | Finished (Result err ok)
