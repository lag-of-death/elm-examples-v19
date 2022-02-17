module Main exposing (main)

import Animation exposing (px)
import Animation.Messenger
import Browser
import Debug
import Html exposing (Html, button, div, img, input, p, text)
import Html.Attributes as HA exposing (src, style)
import Html.Events exposing (on, onClick, onInput)
import Http exposing (Response, emptyBody)
import Json.Decode as Json exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Task exposing (Task)



--main : Program Never Model Msg


init : Int -> ( Model, Cmd Msg )
init =
    \_ -> ( initialModel, Cmd.none )


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- SUBS


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.style ]



-- TYPES


type alias Photo =
    { id : String
    , url : String
    , title : String
    }


type alias Model =
    { searchPhrase : String
    , url : String
    , style : Animation.Messenger.State Msg
    }


type Msg
    = NoOp
    | SetSearchPhrase String
    | Search
    | GoingRight
    | ImageLoaded
    | Animate Animation.Msg
    | RunHTTPChain (Result Http.Error (Response String))


initialModel : Model
initialModel =
    { searchPhrase = ""
    , url = ""
    , style = initialStyle
    }


defaultPhoto : Photo
defaultPhoto =
    { id = "1"
    , url = ""
    , title = ""
    }


initialStyle : Animation.Messenger.State Msg
initialStyle =
    Animation.style
        [ Animation.scale 0.3
        , Animation.left (px 410.0)
        , Animation.borderRadius (px 360.0)
        , Animation.opacity 0
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        SetSearchPhrase phrase ->
            ( { model | searchPhrase = phrase }, Cmd.none )

        GoingRight ->
            let
                _ =
                    Debug.log "going right" "oh yes!"
            in
            ( model, Cmd.none )

        ImageLoaded ->
            let
                newStyle =
                    Animation.interrupt
                        [ Animation.toWith
                            (Animation.easing
                                { duration = 2
                                , ease = \x -> x ^ 2
                                }
                            )
                            [ Animation.scale 1
                            , Animation.borderRadius (px 0.0)
                            , Animation.left (px 0.0)
                            , Animation.opacity 1
                            ]
                        , Animation.Messenger.send GoingRight
                        , Animation.to [ Animation.left (px 140.0) ]
                        ]
                        model.style
            in
            ( { model | style = newStyle }, Cmd.none )

        Search ->
            ( { model
                | style = initialStyle
                , url = ""
              }
            , getUserAndPhotos model.searchPhrase
            )

        RunHTTPChain (Err err) ->
            ( model
            , let
                _ =
                    Debug.log "err" err
              in
              Cmd.none
            )

        RunHTTPChain (Ok data) ->
            let
                head =
                    List.head []
            in
            ( { model
                | url = .url <| Maybe.withDefault defaultPhoto head
              }
            , Cmd.none
            )

        Animate msg ->
            let
                ( newStyle, cmds ) =
                    Animation.Messenger.update msg model.style
            in
            ( { model
                | style = newStyle
              }
            , cmds
            )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ style "padding" "15px" ]
        [ input
            [ onInput SetSearchPhrase ]
            []
        , button
            [ onClick Search ]
            [ text "search" ]
        , renderImg model.url model.style
        ]


renderImg : String -> Animation.Messenger.State Msg -> Html Msg
renderImg url style =
    if String.isEmpty url then
        p [] [ text "no photo for empty url" ]

    else
        div
            []
            [ img
                (List.concat
                    [ Animation.render style
                    , [ HA.style "position" "absolute"
                      , HA.style "margin" "10px"
                      ]
                    , [ src url ]
                    , [ onLoad ImageLoaded ]
                    ]
                )
                []
            ]



-- HTTP


getUserAndPhotos : String -> Cmd Msg
getUserAndPhotos username =
    getUserId username
        |> Task.andThen (\_ -> getPicturesByUID "abc")
        |> Task.attempt RunHTTPChain


getUserId : String -> Task a (Response String)
getUserId username =
    let
        url =
            "https://api.flickr.com/services/rest/"
                ++ "?method=flickr.people.findByUsername"
                ++ "&api_key=<<FLICKER_API_KEY_HERE>>"
                ++ "&format=json"
                ++ "&nojsoncallback=1"
                ++ "&username="
                ++ username
    in
    Http.task
        { url = url
        , body = emptyBody
        , method = "GET"
        , headers = []
        , timeout = Just 10000
        , resolver = Http.stringResolver (\x -> Ok x)
        }


getPicturesByUID : String -> Task a (Response String)
getPicturesByUID userId =
    Http.task
        { url = buildUrl userId
        , body = emptyBody
        , method = "GET"
        , headers = []
        , timeout = Just 10000
        , resolver = Http.stringResolver (\x -> Ok x)
        }



-- DECODERS


photoDecoder : Decoder Photo
photoDecoder =
    Json.succeed Photo
        |> required "id" Json.string
        |> optional "url_q" Json.string ""
        |> optional "title" Json.string ""


photosDecoder : Decoder (List Photo)
photosDecoder =
    Json.at [ "photos", "photo" ] (Json.list photoDecoder)


userIdDecoder : Decoder String
userIdDecoder =
    Json.at [ "user", "id" ] Json.string



-- HELPERS


buildUrl : String -> String
buildUrl userId =
    "https://api.flickr.com/services/rest/"
        ++ "?method=flickr.people.getPhotos"
        ++ "&api_key=<<FLICKER_API_KEY_HERE>>"
        ++ "&user_id="
        ++ userId
        ++ "&format=json"
        ++ "&extras=url_q"
        ++ "&nojsoncallback=1"


onLoad : a -> Html.Attribute a
onLoad message =
    on "load" (Json.succeed message)
