module Location exposing
    ( Dest
    , apiAvatar
    , apiLogin
    , apiLogout
    , apiProfile
    , apiSignup
    , home
    , login
    , logout
    , profile
    , repo
    , signup
    )

import Url.Builder as Build


type alias Dest =
    String



-- EXTERNAL


repo : Dest
repo =
    "https://github.com/sharpvik/mess"



-- API


api : String -> Dest
api sub =
    Build.absolute [ "api", sub ] []


apiSignup : Dest
apiSignup =
    api "signup"


apiLogin : Dest
apiLogin =
    api "login"


apiProfile : Dest
apiProfile =
    api "profile"


apiAvatar : Dest
apiAvatar =
    api "avatar"


apiLogout : Dest
apiLogout =
    api "logout"



-- INTERNAL


at : List String -> Dest
at sub =
    Build.absolute ("@" :: sub) []


home : Dest
home =
    at [ "home" ]


signup : Dest
signup =
    at [ "signup" ]


login : Dest
login =
    at [ "login" ]


profile : Dest
profile =
    at [ "profile" ]


logout : Dest
logout =
    at [ "logout" ]
