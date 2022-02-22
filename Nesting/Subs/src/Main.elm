module Main exposing (..)

import Browser
import Counter
import Debug exposing (toString)
import Html exposing (..)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subs
        }


subs : Model -> Sub Msg
subs model =
    Sub.batch
        [ Sub.none
        , Sub.map CounterMsg (Counter.subs model.counter)
        ]


type alias Model =
    { counter : Counter.Model }


init : Int -> ( Model, Cmd Msg )
init _ =
    let
        ( counterModel, counterCmd ) =
            Counter.init
    in
    ( { counter = counterModel }
    , Cmd.map CounterMsg counterCmd
    )


type Msg
    = CounterMsg Counter.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        CounterMsg msg ->
            let
                ( counterModel, counterCmd ) =
                    Counter.update msg model.counter
            in
            ( { counter = counterModel }
            , Cmd.map CounterMsg counterCmd
            )


view : Model -> Html Msg
view model =
    text <| toString <| model
