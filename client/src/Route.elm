module Route exposing
    ( AuthCase(..)
    , ProfileCase(..)
    , Route(..)
    , fromUrl
    )

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s)


type alias UrlParser a =
    Parser (Route -> a) a


type Route
    = Home
    | Auth AuthCase
    | Profile ProfileCase
    | Logout


type AuthCase
    = Signup
    | Login


type ProfileCase
    = ViewProfile
    | EditProfile


at : Parser a a
at =
    s "@"


urlParser : UrlParser a
urlParser =
    oneOf
        [ map (Profile ViewProfile) Parser.top
        , map (Profile ViewProfile) at -- this duplication is due to virtual routing
        , map (Profile ViewProfile) <| at </> s "profile"
        , map (Profile EditProfile) <| at </> s "profile" </> s "edit"
        , map (Auth Signup) <| at </> s "signup"
        , map (Auth Login) <| at </> s "login"
        , map Home <| at </> s "home"
        , map Logout <| at </> s "logout"
        ]


fromUrl : Url -> Route
fromUrl url =
    Maybe.withDefault Home <| Debug.log "route" (Parser.parse urlParser url)
