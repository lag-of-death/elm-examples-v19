module Main exposing (..)

import Browser
import Counter exposing (..)
import Html exposing (..)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subs
        }


subs model =
    Sub.none


init : Int -> ( Model, Cmd Msg )
init _ =
    let
        ( counterModel, counterCmd ) =
            Counter.init
    in
    ( counterModel, Cmd.map CounterMsg counterCmd )


type alias Model =
    Counter.Model


initialModel : Model
initialModel =
    Counter.initialModel


type Msg
    = CounterMsg Counter.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        CounterMsg msg ->
            let
                ( newModel, cmd ) =
                    Counter.update msg model
            in
            ( newModel, Cmd.map CounterMsg cmd )


view : Model -> Html Msg
view model =
    div []
        [ Html.map CounterMsg (Counter.view model)
        ]
