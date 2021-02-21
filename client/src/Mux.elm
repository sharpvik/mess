module Mux exposing (mux)

import Elements exposing (topbar)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MainTypes exposing (..)
import Routes exposing (Route(..))


mux : Model -> List (Html Msg)
mux model =
    case model.route of
        Root ->
            root

        Signup ->
            signup model


root : List (Html Msg)
root =
    [ topbar "Mess"
    , section [ class "passage" ]
        [ h1 [] [ text "Coming soon..." ]
        , p []
            [ text "Mess chat app is currently under construction. We're working hard to create a new way of building local communities using technology and internet."
            ]
        , a
            [ class "button"
            , href "https://github.com/sharpvik/mess"
            ]
            [ text "Contribute" ]
        ]
    ]


signup : Model -> List (Html Msg)
signup model =
    case model.userSignupResult of
        Nothing ->
            [ topbar "Sign Up"
            , Html.form
                [ class "creds-form"
                , onSubmit (SignupFormSubmit (jsonEncodeUserData model.userData))
                ]
                [ input
                    [ type_ "text"
                    , name "handle"
                    , placeholder "Username"
                    , required True
                    , value model.userData.handle
                    , onInput (SignupFormKeyDown Handle)
                    ]
                    []
                , input
                    [ type_ "text"
                    , name "name"
                    , placeholder "Your Name"
                    , required True
                    , value model.userData.name
                    , onInput (SignupFormKeyDown Name)
                    ]
                    []
                , input
                    [ type_ "password"
                    , name "password"
                    , placeholder "Password"
                    , required True
                    , value model.userData.password
                    , onInput (SignupFormKeyDown Password)
                    ]
                    []
                , button
                    [ class "button"
                    , type_ "submit"
                    ]
                    [ text "Submit" ]
                ]
            ]

        Just True ->
            [ text "Success" ]

        Just False ->
            [ text "Failure" ]
