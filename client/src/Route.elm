module Route exposing (AuthCase(..), Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s)


type alias UrlParser a =
    Parser (Route -> a) a


type Route
    = Home
    | Auth AuthCase
    | Profile


type AuthCase
    = Signup
    | Login


at : Parser a a
at =
    s "@"


urlParser : UrlParser a
urlParser =
    oneOf
        [ map Home Parser.top
        , map Home at -- this duplication is due to virtual routing
        , map (Auth Signup) <| at </> s "signup"
        , map (Auth Login) <| at </> s "login"
        , map Profile <| at </> s "profile"
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
