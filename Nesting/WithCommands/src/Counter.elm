module Counter exposing (..)

import Debug exposing (toString)
import Html exposing (..)
import Html.Events exposing (..)
import Random


subs : Model -> Sub Msg
subs model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Random.generate RandomNumber (Random.int 1 100)
    )


type alias Model =
    Int


initialModel : Model
initialModel =
    0


type Msg
    = Add
    | Sub
    | SetRandomNumber
    | RandomNumber Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Add ->
            ( model + 1, Cmd.none )

        Sub ->
            ( model - 1, Cmd.none )

        RandomNumber number ->
            ( number, Cmd.none )

        SetRandomNumber ->
            ( model, Random.generate RandomNumber (Random.int 1 100) )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Add ] [ text "+" ]
        , text <| toString model
        , button [ onClick Sub ] [ text "-" ]
        , div []
            [ button [ onClick SetRandomNumber ] [ text "set a random number" ]
            ]
        ]
