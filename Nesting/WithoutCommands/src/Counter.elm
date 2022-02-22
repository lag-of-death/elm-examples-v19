module Counter exposing (..)

import Debug exposing (toString)
import Html exposing (..)
import Html.Events exposing (..)


type alias Model =
    Int


initialModel : Model
initialModel =
    0


type Msg
    = Add
    | Sub


update : Msg -> Model -> Model
update msg model =
    case msg of
        Add ->
            model + 1

        Sub ->
            model - 1


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Add ] [ text "+" ]
        , text <| toString model
        , button [ onClick Sub ] [ text "-" ]
        ]
