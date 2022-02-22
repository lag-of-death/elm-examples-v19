module Main exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav exposing (Key)
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (..)
import Url exposing (Protocol(..), Url)


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = NewUrl
        , onUrlChange = UrlChange
        }


type alias Model =
    { history : List String
    , key : Key
    }


init : Int -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { history = [ url.path ]
      , key = key
      }
    , Cmd.none
    )


type Msg
    = NewUrl Browser.UrlRequest
    | UrlChange Url
    | GoTo String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewUrl urlReq ->
            let
                urlRequest =
                    Debug.log "urlRequest" urlReq
            in
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    let
                        urlToLoad =
                            Debug.log "urlToLoad" url
                    in
                    ( model, Nav.load urlToLoad )

        UrlChange location ->
            let
                loc =
                    Debug.log "location" location
            in
            ( { model | history = loc.path :: model.history }
            , Cmd.none
            )

        GoTo url ->
            ( model, Nav.pushUrl model.key url )


view : Model -> Browser.Document Msg
view model =
    { title = "abc"
    , body =
        [ div []
            [ button [ onClick (GoTo "/lang/") ] [ text "lang" ]
            , br [] []
            , a [ href "/lang/" ] [ text "go: lang" ]
            , br [] []
            , a [ href "https://www.wp.pl" ] [ text "go: www.wp.pl" ]
            , br [] []
            , text <| Debug.toString <| .history <| model
            , br [] []
            ]
        ]
    }
