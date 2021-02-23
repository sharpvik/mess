module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s)


type alias UrlParser a =
    Parser (Route -> a) a


type Route
    = Home
    | Signup


urlParser : UrlParser a
urlParser =
    oneOf
        [ map Home Parser.top
        , map Home (s "@") -- this duplication is due to virtual routing
        , map Signup (s "@signup")
        ]


fromUrl : Url -> Route
fromUrl url =
    let
        parsed =
            Debug.log "route" (Parser.parse urlParser url)
    in
    case parsed of
        Nothing ->
            Home

        Just r ->
            r
