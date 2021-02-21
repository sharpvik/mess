module Elements exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import MainTypes exposing (..)


topbar : String -> Html Msg
topbar head =
    header [ class "topbar" ]
        [ h1 [] [ text head ]
        , a [ href "/signup" ] [ text "Register" ]
        ]
