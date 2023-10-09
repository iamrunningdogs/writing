module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import Element as UI exposing (px, rgb255)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import FatalError exposing (FatalError)
import Html exposing (Html)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import UrlPath exposing (UrlPath)
import View exposing (View)
import Widgets


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type Msg
    = SharedMsg SharedMsg


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    {}


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flags maybePagePath =
    ( {}
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg globalMsg ->
            ( model, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view sharedData page model toMsg pageView =
    { body =
        [ UI.layout
            [ UI_Background.color (UI.rgb255 24 26 27)
            , UI_Font.color (UI.rgb255 211 207 201)
            , UI_Font.size 18
            , UI_Font.family [ UI_Font.typeface "Helvetica", UI_Font.sansSerif ]
            ]
          <|
            UI.column
                [ UI.width UI.fill
                , UI.height UI.fill
                , UI.spacing 50
                ]
                [ UI.column
                    [ UI.centerX
                    , UI.width <| UI.maximum 750 UI.fill
                    , UI.paddingXY 10 0
                    ]
                    [ header
                    , pageView.body
                    ]
                , footer
                ]
        ]
    , title = pageView.title
    }


header : UI.Element msg
header =
    UI.column
        [ UI.width UI.fill
        , UI.paddingEach { top = 0, left = 0, right = 0, bottom = 60 }
        ]
        [ UI.row
            [ UI.width UI.fill
            , UI.paddingXY 0 20
            ]
            [ UI.row
                [ UI.alignLeft
                , UI_Font.size 25
                , UI.spacing 13
                , UI.centerY
                ]
                [ UI.link [] { url = "/", label = UI.image [ UI.width (px 70), UI.height (px 70), UI_Border.rounded 5, UI.clip ] { src = "/images/caricatura.png", description = "" } }
                , Widgets.link [] { url = "/", label = UI.text "Asier Elorz" }
                ]
            , UI.row
                [ UI.alignRight
                , UI.spacing 26
                , UI.centerY
                ]
                [ Widgets.link [] { url = "/", label = UI.text "Recientes" }
                , Widgets.link [] { url = "/archive", label = UI.text "Todos" }
                , Widgets.link [] { url = "/tags", label = UI.text "Etiquetas" }
                , Widgets.link [] { url = "/about", label = UI.text "Sobre mí" }
                ]
            ]
        , Widgets.horizontalSeparator 1
        ]


footer : UI.Element msg
footer =
    UI.el
        [ UI_Background.color (rgb255 34 36 38)
        , UI_Border.widthXY 0 1
        , UI_Border.color (rgb255 58 62 65)
        , UI.width UI.fill
        , UI.height (px 89)
        , UI.alignBottom
        ]
        UI.none
