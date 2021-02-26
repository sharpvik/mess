module Route exposing (AuthCase(..), Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s)


type alias UrlParser a =
    Parser (Route -> a) a


type Route
    = Home
    | Auth AuthCase


type AuthCase
    = Signup
    | Login


do : Parser a a
do =
    s "@"


urlParser : UrlParser a
urlParser =
    oneOf
        [ map Home Parser.top
        , map Home do -- this duplication is due to virtual routing
        , map (Auth Signup) (do </> s "signup")
        , map (Auth Login) (do </> s "login")
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
