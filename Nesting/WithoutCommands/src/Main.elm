module Main exposing (..)

import Browser
import Counter exposing (..)
import Html exposing (..)


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }


init : Counter.Model
init =
    Counter.initialModel


type Msg
    = NoOp
    | Counter Counter.Msg


update : Msg -> Model -> Model
update msg dataModel =
    case msg of
        NoOp ->
            dataModel

        Counter message ->
            Counter.update message dataModel


view : Model -> Html Msg
view model =
    map Counter (Counter.view model)
