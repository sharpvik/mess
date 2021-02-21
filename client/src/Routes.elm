module Routes exposing (Route(..), parse)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, s)


type alias UrlParser a =
    Parser (Route -> a) a


type Route
    = Root
    | Signup


urlParser : UrlParser a
urlParser =
    oneOf
        [ map Root (s "")
        , map Signup (s "signup")
        ]


parse : Url -> Route
parse url =
    let
        parsed =
            Debug.log "parsed" (Url.Parser.parse urlParser url)
    in
    case parsed of
        Nothing ->
            Root

        Just r ->
            r
