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
    | AuthResult AuthCase (Maybe (Result String String))


type Msg
    = SignupFormKeyDown SignupFormField String
    | FormSubmit AuthCase Encode.Value
    | LoginFormKeyDown LoginFormField String
    | GotAuthResult AuthCase (Result String String)



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

        ( FormSubmit authCase json, _ ) ->
            let
                dest =
                    case authCase of
                        Route.Signup ->
                            Location.apiSignup

                        Route.Login ->
                            Location.apiLogin
            in
            ( AuthResult authCase Nothing
              -- expecting response from server
            , Http.post
                { url = dest
                , body = Http.jsonBody json
                , expect =
                    expectResponseMessage <| GotAuthResult authCase
                }
            )

        ( GotAuthResult authCase result, _ ) ->
            ( AuthResult authCase <| Just result
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
        topbar =
            Elements.topbarWithRightSide "Auth" <|
                a [ href Location.home ] [ text "Home" ]

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
                [ topbar
                , div [ class "creds-form-container" ]
                    [ div [ class "tabs" ]
                        [ a [ href Location.signup, class "tab active" ] [ text "Sign Up" ]
                        , a [ href Location.login, class "tab" ] [ text "Log In" ]
                        ]
                    , Html.form
                        [ class "creds-form"
                        , onSubmit (FormSubmit Route.Signup (jsonEncodeUserSignupData data))
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
                ]

            Login data ->
                [ topbar
                , div [ class "creds-form-container" ]
                    [ div [ class "tabs" ]
                        [ a [ href Location.signup, class "tab" ] [ text "Sign Up" ]
                        , a [ href Location.login, class "tab active" ] [ text "Log In" ]
                        ]
                    , Html.form
                        [ class "creds-form"
                        , onSubmit (FormSubmit Route.Login (jsonEncodeUserLoginData data))
                        ]
                        [ handleInput data.handle (LoginFormKeyDown LoginHandle)
                        , passwordInput data.password (LoginFormKeyDown LoginPassword)
                        , submitButton
                        ]
                    ]
                ]

            AuthResult _ Nothing ->
                [ Elements.loader ]

            AuthResult authCase (Just (Ok message)) ->
                [ div [ class "passage" ]
                    [ h1 [] [ text "Success!" ]
                    , p [] [ text message ]
                    , case authCase of
                        Route.Signup ->
                            Elements.buttonLink Location.login "Log In"

                        Route.Login ->
                            Elements.buttonLink Location.home "Go Back"
                    ]
                ]

            AuthResult authCase (Just (Err message)) ->
                [ div [ class "passage" ]
                    [ h1 [] [ text "Failure..." ]
                    , p [] [ text message ]
                    , Elements.buttonLink
                        (case authCase of
                            Route.Signup ->
                                Location.signup

                            Route.Login ->
                                Location.login
                        )
                        "Try Again"
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
