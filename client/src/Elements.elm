module Elements exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Location


topbar : String -> Html msg
topbar title =
    header [ class "topbar" ] [ h1 [] [ text title ] ]


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


buttonLinkWithOnClick : String -> msg -> Html msg
buttonLinkWithOnClick txt action =
    a [ class "button", onClick action ] [ text txt ]
