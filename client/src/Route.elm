module Route exposing (AuthCase(..), Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s)


type alias UrlParser a =
    Parser (Route -> a) a


type Route
    = Home
    | Auth AuthCase
    | Profile
    | Logout


type AuthCase
    = Signup
    | Login


at : Parser a a
at =
    s "@"


urlParser : UrlParser a
urlParser =
    oneOf
        [ map Profile Parser.top
        , map Profile at -- this duplication is due to virtual routing
        , map Profile <| at </> s "profile"
        , map (Auth Signup) <| at </> s "signup"
        , map (Auth Login) <| at </> s "login"
        , map Home <| at </> s "home"
        , map Logout <| at </> s "logout"
        ]


fromUrl : Url -> Route
fromUrl url =
    Maybe.withDefault Home <| Debug.log "route" (Parser.parse urlParser url)
