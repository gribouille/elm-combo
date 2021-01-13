module Example1 exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Combo


type alias Model =
  { state : Combo.State
  }

type Msg
  = OnState Combo.State


data : List String
data =
  [ "Lorem ipsum dolor sit amet"
  , "Quisque varius"
  , "Vivamus bibendum"
  , "Nullam faucibus"
  , "Nullam a dui aliquam"
  , "Cras sit amet"
  , "In a metus auctor"
  , "Mauris et tellus"
  , "Sed vel nunc"
  , "Aenean efficitur"
  ]


main : Program () Model Msg
main =
  Browser.sandbox
    { init = init
    , view = view
    , update = update
    }


init : Model
init =
  { state = Combo.init ""
  }

view : Model -> Html Msg
view model =
  let
    config = Combo.config OnState data
  in
    div [ class "panel-block", style "display" "flex", style "flex-direction" "column" ]
        [ div [ style "width" "100%", style "margin-bottom" "20px" ]
              [ span [] [ text <| "value: "
                        , strong [] [ text <| Combo.value model.state ]
                        ]
              ]
        , Combo.view config model.state
        ]


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnState s ->
       {model | state = s }
