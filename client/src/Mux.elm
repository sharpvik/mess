module Mux exposing (mux)

import Elements exposing (topbar)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MainTypes exposing (..)
import Routes exposing (Route(..))


mux : Route -> List (Html Msg)
mux route =
    case route of
        Root ->
            root

        Signup ->
            signup


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


signup : List (Html Msg)
signup =
    [ topbar "Sign Up"
    , Html.form [ class "creds-form" ]
        [ input
            [ type_ "text"
            , name "handle"
            , placeholder "Username"
            , required True
            ]
            []
        , input
            [ type_ "text"
            , name "name"
            , placeholder "Your Name"
            , required True
            ]
            []
        , input
            [ type_ "password"
            , name "password"
            , placeholder "Password"
            , required True
            ]
            []
        ]
    ]
