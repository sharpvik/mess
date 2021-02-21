module Mux exposing (mux)

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
    [ header [ class "topbar" ]
        [ h1 [] [ text "Mess" ]
        , a [ href "/signup" ] [ text "Register" ]
        ]
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
    [ h1 [] [ text "signup page" ] ]
