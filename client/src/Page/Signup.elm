module Page.Signup exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Elements
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode as Encode
import Location


init : ( Model, Cmd Msg )
init =
    ( UserData "" "" "" |> FormData
    , Cmd.none
    )



-- TYPES


type Model
    = FormData UserData
    | SignupResult (Maybe Bool)


type Msg
    = SignupFormKeyDown SignupFormField String
    | SignupFormSubmit Encode.Value
    | GotSignupResult (Result Http.Error String)


type SignupFormField
    = Handle
    | Name
    | Password



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( SignupFormKeyDown field str, FormData data ) ->
            ( updateUserDataWith data field str |> FormData
            , Cmd.none
            )

        ( SignupFormSubmit json, _ ) ->
            ( SignupResult Nothing
              -- expecting response from server
            , Http.post
                { url = Location.apiSignup
                , body = Http.jsonBody json
                , expect = Http.expectString GotSignupResult
                }
            )

        ( GotSignupResult result, _ ) ->
            case result of
                Ok _ ->
                    ( Just True |> SignupResult
                    , Cmd.none
                    )

                Err _ ->
                    ( Just False |> SignupResult
                    , Cmd.none
                    )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    let
        goBackLink : Location.Dest -> String -> Html Msg
        goBackLink ref txt =
            a [ class "button", href ref ] [ text txt ]
    in
    { title = "Signup @Mess"
    , body =
        case model of
            FormData data ->
                [ Elements.topbar "Sign Up"
                , Html.form
                    [ class "creds-form"
                    , onSubmit (SignupFormSubmit (jsonEncodeUserData data))
                    ]
                    [ input
                        [ type_ "text"
                        , name "handle"
                        , placeholder "Username"
                        , required True
                        , value data.handle
                        , maxlength 100
                        , onInput (SignupFormKeyDown Handle)
                        ]
                        []
                    , input
                        [ type_ "text"
                        , name "name"
                        , placeholder "Your Name"
                        , required True
                        , value data.name
                        , maxlength 100
                        , onInput (SignupFormKeyDown Name)
                        ]
                        []
                    , input
                        [ type_ "password"
                        , name "password"
                        , placeholder "Password"
                        , required True
                        , value data.password
                        , maxlength 64
                        , onInput (SignupFormKeyDown Password)
                        ]
                        []
                    , div []
                        [ button
                            [ class "button"
                            , type_ "submit"
                            ]
                            [ text "Submit" ]
                        ]
                    ]
                ]

            SignupResult Nothing ->
                [ Elements.loader ]

            SignupResult (Just True) ->
                [ div [ class "passage" ]
                    [ h1 [] [ text "Success!" ]
                    , p [] [ text "You can go back and login now." ]
                    , goBackLink Location.home "Go Back"
                    ]
                ]

            SignupResult (Just False) ->
                [ div [ class "passage" ]
                    [ h1 [] [ text "Failure..." ]
                    , p [] [ text "Please try again!" ]
                    , goBackLink Location.signup "Try Again"
                    ]
                ]
    }


type alias UserData =
    { handle : String
    , name : String
    , password : String
    }


updateUserDataWith : UserData -> SignupFormField -> String -> UserData
updateUserDataWith data field str =
    case field of
        Handle ->
            { data | handle = str }

        Name ->
            { data | name = str }

        Password ->
            { data | password = str }


jsonEncodeUserData : UserData -> Encode.Value
jsonEncodeUserData data =
    Encode.object
        [ ( "handle", Encode.string data.handle )
        , ( "name", Encode.string data.name )
        , ( "password", Encode.string data.password )
        ]
