module Counter exposing (..)

import Debug
import Html exposing (..)
import Time


subs : Model -> Sub Msg
subs model =
    Time.every 1000 RandomNumber


type alias Model =
    Int


initialModel : Model
initialModel =
    0


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


type Msg
    = RandomNumber Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomNumber timestamp ->
            ( model + 1, Cmd.none )


view : Model -> Html Msg
view model =
    text <| Debug.toString <| model
