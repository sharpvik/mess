module Location exposing (..)


type alias Dest =
    String



-- EXTERNAL


repo : Dest
repo =
    "https://github.com/sharpvik/mess"



-- API


apiSignup : Dest
apiSignup =
    "/api/signup"


apiLogin : Dest
apiLogin =
    "/api/login"



-- INTERNAL


home : Dest
home =
    "/@"


signup : Dest
signup =
    "/@/signup"


login : Dest
login =
    "/@/login"


profile : Dest
profile =
    "/@/profile"
