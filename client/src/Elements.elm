module Elements exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


topbar : String -> Html msg
topbar head =
    header [ class "topbar" ]
        [ h1 [] [ text head ]
        , a [ href "/@signup" ] [ text "Register" ]
        ]


loader : Html msg
loader =
    div [ class "loader" ]
        [ div [ class "median" ]
            [ div [ id "loader" ] []
            ]
        ]
