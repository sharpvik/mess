module Page.Auth exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Elements
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode as Encode
import Location
import Route exposing (AuthCase)


init : AuthCase -> ( Model, Cmd Msg )
init auth =
    case auth of
        Route.Signup ->
            ( UserSignupData "" "" "" |> Signup
            , Cmd.none
            )

        Route.Login ->
            ( UserLoginData "" "" |> Login
            , Cmd.none
            )



-- TYPES


type Model
    = Signup UserSignupData
    | Login UserLoginData
    | SignupResult (Maybe (Result String String))


type Msg
    = SignupFormKeyDown SignupFormField String
    | FormSubmit Location.Dest Encode.Value
    | LoginFormKeyDown LoginFormField String
    | GotSignupResult (Result String String)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( SignupFormKeyDown field str, Signup data ) ->
            ( updateUserSignupDataWith data field str |> Signup
            , Cmd.none
            )

        ( LoginFormKeyDown field str, Login data ) ->
            ( updateUserLoginDataWith data field str |> Login
            , Cmd.none
            )

        ( FormSubmit dest json, _ ) ->
            ( SignupResult Nothing
              -- expecting response from server
            , Http.post
                { url = dest
                , body = Http.jsonBody json
                , expect = expectResponseMessage GotSignupResult
                }
            )

        ( GotSignupResult result, _ ) ->
            ( Just result |> SignupResult
            , Cmd.none
            )

        ( _, _ ) ->
            ( model, Cmd.none )


expectResponseMessage :
    (Result String String -> msg)
    -> Http.Expect msg
expectResponseMessage toMsg =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadStatus_ _ message ->
                    Err message

                Http.GoodStatus_ _ message ->
                    Ok message

                _ ->
                    Err "Something went terribly wrong... I'll try to fix it."



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    let
        handleInput val onIn =
            input
                [ type_ "text"
                , name "handle"
                , placeholder "Username"
                , required True
                , value val
                , maxlength 100
                , onInput onIn
                ]
                []

        passwordInput val onIn =
            input
                [ type_ "password"
                , name "password"
                , placeholder "Password"
                , required True
                , value val
                , maxlength 64
                , onInput onIn
                ]
                []

        submitButton =
            div []
                [ button
                    [ class "button"
                    , type_ "submit"
                    ]
                    [ text "Submit" ]
                ]
    in
    { title = "Auth @Mess"
    , body =
        case model of
            Signup data ->
                [ Elements.topbar "Auth"
                , Html.form
                    [ class "creds-form"
                    , onSubmit (FormSubmit Location.apiSignup (jsonEncodeUserSignupData data))
                    ]
                    [ handleInput data.handle (SignupFormKeyDown SignupHandle)
                    , input
                        [ type_ "text"
                        , name "name"
                        , placeholder "Your Name"
                        , required True
                        , value data.name
                        , maxlength 100
                        , onInput (SignupFormKeyDown SignupName)
                        ]
                        []
                    , passwordInput data.password (SignupFormKeyDown SignupPassword)
                    , submitButton
                    ]
                ]

            Login data ->
                [ Elements.topbar "Auth"
                , Html.form
                    [ class "creds-form"
                    , onSubmit (FormSubmit Location.apiLogin (jsonEncodeUserLoginData data))
                    ]
                    [ handleInput data.handle (LoginFormKeyDown LoginHandle)
                    , passwordInput data.password (LoginFormKeyDown LoginPassword)
                    , submitButton
                    ]
                ]

            SignupResult Nothing ->
                [ Elements.loader ]

            SignupResult (Just (Ok message)) ->
                [ div [ class "passage" ]
                    [ h1 [] [ text "Success!" ]
                    , p [] [ text message ]
                    , Elements.buttonLink Location.home "Go Back"
                    ]
                ]

            SignupResult (Just (Err message)) ->
                [ div [ class "passage" ]
                    [ h1 [] [ text "Failure..." ]
                    , p [] [ text message ]
                    , Elements.buttonLink Location.signup "Try Again"
                    ]
                ]
    }


type alias UserSignupData =
    { handle : String
    , name : String
    , password : String
    }


type SignupFormField
    = SignupHandle
    | SignupName
    | SignupPassword


updateUserSignupDataWith : UserSignupData -> SignupFormField -> String -> UserSignupData
updateUserSignupDataWith data field str =
    case field of
        SignupHandle ->
            { data | handle = str }

        SignupName ->
            { data | name = str }

        SignupPassword ->
            { data | password = str }


jsonEncodeUserSignupData : UserSignupData -> Encode.Value
jsonEncodeUserSignupData data =
    Encode.object
        [ ( "handle", Encode.string data.handle )
        , ( "name", Encode.string data.name )
        , ( "password", Encode.string data.password )
        ]


type alias UserLoginData =
    { handle : String
    , password : String
    }


type LoginFormField
    = LoginHandle
    | LoginPassword


updateUserLoginDataWith : UserLoginData -> LoginFormField -> String -> UserLoginData
updateUserLoginDataWith data field str =
    case field of
        LoginHandle ->
            { data | handle = str }

        LoginPassword ->
            { data | password = str }


jsonEncodeUserLoginData : UserLoginData -> Encode.Value
jsonEncodeUserLoginData data =
    Encode.object
        [ ( "handle", Encode.string data.handle )
        , ( "password", Encode.string data.password )
        ]
