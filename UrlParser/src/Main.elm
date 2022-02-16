module Main exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav exposing (Key)
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (..)
import Url exposing (Protocol(..), Url)
import Url.Parser as UrlParser exposing ((</>), (<?>), int, top)
import Url.Parser.Query as Query


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = NewUrl
        , onUrlChange = UrlChange
        }



-- MODEL


type alias Model =
    { history : List String
    , key : Key
    , route : Maybe Route
    }


init : Int -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { history = [ Debug.log "initial url" (Debug.toString url) ]
      , key = key
      , route = UrlParser.parse routeParser url
      }
    , Cmd.none
    )



-- ROUTES


type Route
    = Home
    | LangId Int
    | LangList (Maybe String)


routeParser : UrlParser.Parser (Route -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Home top
        , UrlParser.map LangId (UrlParser.s "lang" </> int)
        , UrlParser.map LangList (UrlParser.s "lang" <?> Query.string "search")
        ]



-- UPDATE


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
                    let
                        maybeRoute =
                            UrlParser.parse routeParser url
                    in
                    ( { model | route = Debug.log "maybeRoute" maybeRoute }
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



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "abc"
    , body =
        [ div []
            [ button [ onClick (GoTo "/lang/") ] [ text "lang" ]
            , button [ onClick (GoTo "/lang/1") ] [ text "lang/1" ]
            , button [ onClick (GoTo "/lang/?search=sth") ] [ text "?search=sth" ]
            , a [ href "/lang/" ] [ text "go: lang" ]
            , br [] []
            , a [ href "/lang/1" ] [ text "go: lang/1" ]
            , br [] []
            , a [ href "/lang/?search=sth" ] [ text "go: lang/?search=sth" ]
            , br [] []
            , text <| Debug.toString <| .history <| model
            , br [] []
            , text <| Debug.toString <| .route <| model
            ]
        ]
    }
