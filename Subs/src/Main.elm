module Main exposing (..)

import Browser
import Html
import Time


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subs
        }



-- SUBS


subs : Model -> Sub Msg
subs model =
    Time.every 1000 NewTime



-- MODEL


type alias Model =
    Time.Posix


initialModel : Model
initialModel =
    Time.millisToPosix 0


init : Int -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = NewTime Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewTime time ->
            ( time, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.text <| Debug.toString <| model
