module Elements exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Location


topbar : String -> Html msg
topbar head =
    header [ class "topbar" ]
        [ h1 [] [ text head ]
        , div []
            [ a [ href Location.signup ] [ text "Sign Up" ]
            , text " | "
            , a [ href Location.login ] [ text "Log In" ]
            ]
        ]


loader : Html msg
loader =
    div [ class "loader" ]
        [ div [ class "median" ]
            [ div [ id "loader" ] []
            ]
        ]


buttonLink : Location.Dest -> String -> Html msg
buttonLink ref txt =
    a [ class "button", href ref ] [ text txt ]
