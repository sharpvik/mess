module MainTypes exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Http
import Json.Encode
import Routes exposing (Route)
import Url exposing (Url)


type alias UserData =
    { handle : String
    , name : String
    , password : String
    }


userDataWithHandle : UserData -> String -> UserData
userDataWithHandle data handle =
    { data | handle = handle }


userDataWithName : UserData -> String -> UserData
userDataWithName data name =
    { data | name = name }


userDataWithPassword : UserData -> String -> UserData
userDataWithPassword data password =
    { data | password = password }


jsonEncodeUserData : UserData -> Json.Encode.Value
jsonEncodeUserData data =
    Json.Encode.object
        [ ( "handle", Json.Encode.string data.handle )
        , ( "name", Json.Encode.string data.name )
        , ( "password", Json.Encode.string data.password )
        ]


type alias Model =
    { route : Route
    , key : Nav.Key
    , userData : UserData
    , userSignupResult : Maybe Bool
    }


type SignupFormField
    = Handle
    | Name
    | Password


type Msg
    = LinkClicked UrlRequest
    | LinkChanged Url
    | SignupFormKeyDown SignupFormField String
    | SignupFormSubmit Json.Encode.Value
    | UserSignupResult (Result Http.Error String) -- True is success, False is failure
    | Nop Json.Encode.Value
