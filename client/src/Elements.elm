module Elements exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Location


topbarWithRightSide : String -> Html msg -> Html msg
topbarWithRightSide title rhs =
    header [ class "topbar" ]
        [ h1 [] [ text title ]
        , rhs
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
