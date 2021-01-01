module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Browser
import Html exposing (Html, button, div, input, li, text, ul)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Length exposing (Length)
import Parser exposing (..)
import Parser.Advanced exposing (chompIf)
import Regex
import Round
import Speed exposing (Speed)



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type CalcMode
    = DistanceCalcMode
    | VelocityCalcMode
    | TimeCalcMode


type DistanceUnit
    = Meter
    | Kilometer
    | Yard
    | Mile


type alias Distance =
    { value : Float
    , unit : DistanceUnit
    }


type VelocityUnit
    = MetersPerSecond
    | KilometersPerHour
    | MilesPerHour


type alias Velocity =
    { value : Float
    , unit : VelocityUnit
    }


type alias Duration =
    { h : Maybe Int
    , m : Maybe Int
    , s : Float
    }


type alias Pace =
    { s : Float
    , unit : DistanceUnit
    }


type alias TimeDistanceVelocity =
    { time : Float
    , distance : Float
    , velocity : Float
    }


type alias Model =
    { calcMode : CalcMode
    , distanceInput : String
    , velocityInput : String
    , paceInput : String
    , timeInput : String
    }


init : Model
init =
    { calcMode = DistanceCalcMode
    , distanceInput = "0"
    , velocityInput = "0"
    , paceInput = "0"
    , timeInput = "0"
    }



-- UPDATE


type Msg
    = SetMode CalcMode
    | SetDistance String
    | SetTime String
    | SetVelocity String
    | SetPace String


calcTDV : String -> String -> String -> TimeDistanceVelocity
calcTDV time distance velocity =
    let
        d =
            case normalizeDistance distance of
                Just dist ->
                    dist.value

                Nothing ->
                    0.0

        t =
            case normalizeTime time of
                Just duration ->
                    duration

                Nothing ->
                    0.0

        v =
            case normalizeVelocity velocity of
                Just velo ->
                    velo

                Nothing ->
                    0.0
    in
    { time = t
    , distance = d
    , velocity = v
    }


updateInputs : Model -> Model
updateInputs model =
    let
        tdv =
            calcTDV model.timeInput model.distanceInput model.velocityInput

        distanceInput =
            case model.calcMode of
                DistanceCalcMode ->
                    formatDistance
                        (Just { value = tdv.time * tdv.velocity, unit = Meter })

                _ ->
                    model.distanceInput

        timeInput =
            case model.calcMode of
                TimeCalcMode ->
                    formatTime (Just (tdv.distance / tdv.velocity))

                _ ->
                    model.timeInput

        velocityInput =
            case model.calcMode of
                VelocityCalcMode ->
                    if tdv.time == 0.0 then
                        ""

                    else
                        formatVelocity (Just (tdv.distance / tdv.time))

                _ ->
                    model.velocityInput

        paceInput =
            case model.calcMode of
                VelocityCalcMode ->
                    if tdv.distance == 0.0 then
                        ""

                    else
                        formatPace (Just (tdv.time / tdv.distance))

                _ ->
                    model.paceInput
    in
    { model
        | distanceInput = distanceInput
        , timeInput = timeInput
        , velocityInput = velocityInput
        , paceInput = paceInput
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetMode calcMode ->
            { model | calcMode = calcMode }

        SetDistance newValue ->
            updateInputs { model | distanceInput = newValue }

        SetTime newValue ->
            updateInputs { model | timeInput = newValue }

        SetVelocity newValue ->
            let
                velocity =
                    normalizeVelocity newValue

                paceInput =
                    case velocity of
                        Just v ->
                            formatPace (Just (1 / v))

                        Nothing ->
                            ""
            in
            updateInputs { model | velocityInput = newValue, paceInput = paceInput }

        SetPace newValue ->
            let
                pace =
                    normalizePace newValue

                velocityInput =
                    case pace of
                        Just p ->
                            formatVelocity (Just (1 / p))

                        Nothing ->
                            ""
            in
            updateInputs { model | paceInput = newValue, velocityInput = velocityInput }



-- VIEW


distanceView : Model -> Html Msg
distanceView model =
    let
        roAttr =
            case model.calcMode of
                DistanceCalcMode ->
                    [ readonly True ]

                _ ->
                    []

        inputAttrs =
            List.append
                [ value model.distanceInput
                , onInput SetDistance
                ]
                roAttr
    in
    div []
        [ text "Distance"
        , input inputAttrs []
        , div []
            [ text "Distance"
            , ul []
                [ li [] [ text model.distanceInput ]
                , li [] [ text (formatDistance (normalizeDistance model.distanceInput)) ]
                ]
            ]
        ]


timeView : Model -> Html Msg
timeView model =
    let
        roAttr =
            case model.calcMode of
                TimeCalcMode ->
                    [ readonly True ]

                _ ->
                    []

        inputAttrs =
            List.append
                [ value model.timeInput
                , onInput SetTime
                ]
                roAttr
    in
    div []
        [ text "Time"
        , input inputAttrs []
        , div []
            [ text "Time"
            , ul []
                [ li [] [ text model.timeInput ]
                , li [] [ text (formatTime (normalizeTime model.timeInput)) ]
                , li [] [ text (Debug.toString (parseTime model.timeInput)) ]
                ]
            ]
        ]


velocityView : Model -> Html Msg
velocityView model =
    let
        roAttr =
            case model.calcMode of
                VelocityCalcMode ->
                    [ readonly True ]

                _ ->
                    []

        inputAttrs =
            List.append
                [ value model.velocityInput
                , onInput SetVelocity
                ]
                roAttr
    in
    div []
        [ text "Velocity"
        , input inputAttrs []
        , div []
            [ text "Velocity"
            , ul []
                [ li [] [ text model.velocityInput ]
                , li [] [ text (formatVelocity (normalizeVelocity model.velocityInput)) ]
                ]
            ]
        ]


paceView : Model -> Html Msg
paceView model =
    let
        roAttr =
            case model.calcMode of
                VelocityCalcMode ->
                    [ readonly True ]

                _ ->
                    []

        inputAttrs =
            List.append
                [ value model.paceInput
                , onInput SetPace
                ]
                roAttr
    in
    div []
        [ text "Pace"
        , input inputAttrs []
        , div []
            [ text "Pace"
            , ul []
                [ li [] [ text model.paceInput ]
                , li [] [ text (formatPace (normalizePace model.paceInput)) ]
                , li [] [ text (Debug.toString (String.split "/" model.paceInput)) ]
                ]
            ]
        ]


calcModePickerView : Model -> Html Msg
calcModePickerView model =
    div []
        [ button [ onClick (SetMode DistanceCalcMode) ] [ text "Distance" ]
        , button [ onClick (SetMode VelocityCalcMode) ] [ text "Velocity" ]
        , button [ onClick (SetMode TimeCalcMode) ] [ text "Time" ]
        , div [] [ text (calcModeText model.calcMode) ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ calcModePickerView model
        , distanceView model
        , timeView model
        , velocityView model
        , paceView model
        ]


calcModeText : CalcMode -> String
calcModeText calcMode =
    case calcMode of
        DistanceCalcMode ->
            "Distance"

        VelocityCalcMode ->
            "Velocity"

        TimeCalcMode ->
            "Time"


distanceUnitSymbol : DistanceUnit -> String
distanceUnitSymbol unit =
    case unit of
        Meter ->
            "m"

        Kilometer ->
            "km"

        Yard ->
            "yd"

        Mile ->
            "mi"


formatDistance : Maybe Distance -> String
formatDistance distance =
    case distance of
        Just dist ->
            Round.round 2 dist.value ++ " " ++ distanceUnitSymbol dist.unit

        Nothing ->
            "(invalid)"


formatVelocity : Maybe Float -> String
formatVelocity velocity =
    case velocity of
        Just v ->
            Round.round 2 v

        Nothing ->
            "(invalid)"


formatTime : Maybe Float -> String
formatTime time =
    case time of
        Nothing ->
            "(invalid)"

        Just t ->
            formatSecondsAsHMMSS t


formatSecondsAsHMMSS : Float -> String
formatSecondsAsHMMSS seconds =
    let
        h =
            floor (seconds / 3600)

        m =
            floor ((seconds - toFloat h * 3600) / 60)

        s =
            seconds - toFloat h * 3600 - toFloat m * 60

        minutePrefix =
            if m < 10 then
                "0"

            else
                ""

        secondPrefix =
            if s < 10 then
                "0"

            else
                ""
    in
    String.fromInt h
        ++ ":"
        ++ minutePrefix
        ++ String.fromInt m
        ++ ":"
        ++ secondPrefix
        ++ Round.round 2 s


parseDistance : String -> Result (List DeadEnd) Distance
parseDistance input =
    let
        value : Parser Float
        value =
            float

        unit : Parser DistanceUnit
        unit =
            oneOf
                [ Parser.map (\_ -> Meter) (keyword "m")
                , Parser.map (\_ -> Kilometer) (keyword "km")
                , Parser.map (\_ -> Yard) (keyword "yd")
                , Parser.map (\_ -> Mile) (keyword "mi")
                ]

        parser =
            succeed Distance
                |= value
                |. spaces
                |= unit
    in
    run parser input


distanceToMeters : Distance -> Float
distanceToMeters dist =
    Length.inMeters
        (case dist.unit of
            Meter ->
                Length.meters dist.value

            Kilometer ->
                Length.kilometers dist.value

            Yard ->
                Length.yards dist.value

            Mile ->
                Length.miles dist.value
        )


normalizeDistance : String -> Maybe Distance
normalizeDistance input =
    case parseDistance input of
        Ok dist ->
            Just
                { value = distanceToMeters dist
                , unit = Meter
                }

        Err _ ->
            Nothing


parseVelocity : String -> Result (List DeadEnd) Velocity
parseVelocity input =
    let
        value : Parser Float
        value =
            float

        unit : Parser VelocityUnit
        unit =
            oneOf
                [ Parser.map (\_ -> MetersPerSecond) (keyword "m/s")
                , Parser.map (\_ -> KilometersPerHour) (keyword "km/h")
                , Parser.map (\_ -> MilesPerHour) (keyword "mph")
                ]

        parser =
            succeed Velocity
                |= value
                |. spaces
                |= unit
    in
    run parser input


normalizeVelocity : String -> Maybe Float
normalizeVelocity input =
    case parseVelocity input of
        Ok dist ->
            Just
                (Speed.inMetersPerSecond
                    (case dist.unit of
                        MetersPerSecond ->
                            Speed.metersPerSecond dist.value

                        KilometersPerHour ->
                            Speed.kilometersPerHour dist.value

                        MilesPerHour ->
                            Speed.milesPerHour dist.value
                    )
                )

        Err _ ->
            Nothing


durationToSeconds : Duration -> Float
durationToSeconds duration =
    let
        hours =
            case duration.h of
                Just h ->
                    toFloat h

                Nothing ->
                    0.0

        minutes =
            case duration.m of
                Just m ->
                    toFloat m

                Nothing ->
                    0.0
    in
    3600 * hours + 60 * minutes + duration.s


submatchesToDuration : List (Maybe String) -> Duration
submatchesToDuration submatches =
    case submatches of
        h :: m :: s :: _ ->
            { h =
                case h of
                    Just hours ->
                        String.toInt hours

                    Nothing ->
                        Nothing
            , m =
                case m of
                    Just minutes ->
                        String.toInt minutes

                    Nothing ->
                        Nothing
            , s =
                case s of
                    Just secondsStr ->
                        case String.toFloat secondsStr of
                            Just seconds ->
                                seconds

                            Nothing ->
                                0.0

                    Nothing ->
                        0.0
            }

        _ ->
            { h = Nothing, m = Nothing, s = 0.0 }


parseTime : String -> Result String Duration
parseTime input =
    let
        colon_re =
            Maybe.withDefault Regex.never <|
                Regex.fromString "(?:(?:(\\d+):)?(\\d{1,2}):)?(\\d{1,2}(?:\\.\\d+)?)$"

        text_re =
            Maybe.withDefault Regex.never <|
                Regex.fromString "(?:(\\d+)\\s*(?:hours|hr|hrs|h)\\s*)?(?:(\\d+)\\s*(?:minutes|min|mins|m)\\s*)?(?:(\\d+)(?:\\.\\d+)?\\s*(?:seconds|sec|s))?"

        t =
            String.trim input

        colon_matches =
            Regex.find colon_re t

        matches =
            if List.length colon_matches == 0 then
                Regex.find text_re t

            else
                colon_matches
    in
    case matches of
        [ a ] ->
            Ok (submatchesToDuration a.submatches)

        _ ->
            Err "invalid"


normalizeTime : String -> Maybe Float
normalizeTime input =
    case parseTime input of
        Ok duration ->
            Just (durationToSeconds duration)

        Err _ ->
            Nothing


matchesToSeconds : Regex.Match -> Float
matchesToSeconds match =
    List.foldl (+) 0 (List.indexedMap submatchToSeconds (List.reverse match.submatches))


submatchToSeconds : Int -> Maybe String -> Float
submatchToSeconds index submatch =
    case submatch of
        Just s ->
            case String.toFloat s of
                Just f ->
                    f * (60 ^ toFloat index)

                Nothing ->
                    0.0

        Nothing ->
            0.0


parsePace : String -> Maybe Pace
parsePace input =
    let
        split =
            String.split "/" input
    in
    case split of
        [ time, unitSymbol ] ->
            let
                seconds =
                    case parseTime time of
                        Ok duration ->
                            Just (durationToSeconds duration)

                        Err _ ->
                            Nothing

                unit =
                    case unitSymbol of
                        "m" ->
                            Just Meter

                        "km" ->
                            Just Kilometer

                        "yd" ->
                            Just Yard

                        "mi" ->
                            Just Mile

                        _ ->
                            Nothing
            in
            case ( seconds, unit ) of
                ( Nothing, _ ) ->
                    Nothing

                ( _, Nothing ) ->
                    Nothing

                ( Just s, Just u ) ->
                    Just { s = s, unit = u }

        _ ->
            Nothing


normalizePace : String -> Maybe Float
normalizePace input =
    let
        pace =
            parsePace input
    in
    case pace of
        Just p ->
            Just
                (p.s
                    / Length.inMeters
                        (case p.unit of
                            Meter ->
                                Length.meter

                            Kilometer ->
                                Length.kilometer

                            Yard ->
                                Length.yard

                            Mile ->
                                Length.mile
                        )
                )

        Nothing ->
            Nothing


formatPace : Maybe Float -> String
formatPace pace =
    case pace of
        Just s ->
            formatSecondsAsHMMSS s ++ "/m"

        Nothing ->
            "(invalid)"
