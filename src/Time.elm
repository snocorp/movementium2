module Time exposing (durationToSeconds, formatTime, normalizeTime, parseTime, timeView)

import Html exposing (Html, div, input, li, span, text, ul)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Model exposing (..)
import Regex
import Round
import View exposing (inputView)


{-|

    A duration record broken down into hours, minutes, and seconds.
    Hours and minutes are optional.

-}
type alias Duration =
    { h : Maybe Int
    , m : Maybe Int
    , s : Float
    }


{-|

    Build a view that displays the time input.

-}
timeView : Model -> Html Msg
timeView model =
    inputView model
        { calcMode = TimeCalcMode
        , label = "Time"
        , id = "time"
        , value = model.timeInput
        , example = "1:23:45"
        , action = SetTime
        , dropdownMenu =
            -- the drop down menu is empty but useful to take up the same vertical space
            div [ class "pure-menu pure-menu-horizontal mm-float" ]
                [ ul [ class "pure-menu-list" ]
                    [ li [ class "pure-menu-item" ]
                        [ span [ class "pure-menu-link" ] [ text "hh:mm:ss" ] ]
                    ]
                ]
        }


{-|

    Formats the time in seconds as hh:mm:ss.
    Returns "(invalid)" if the time is missing

-}
formatTime : Maybe Float -> String
formatTime time =
    case time of
        Just t ->
            formatSecondsAsHMMSS t

        Nothing ->
            "(invalid)"


{-|

    Formats a number of seconds into hh:mm:ss format.

-}
formatSecondsAsHMMSS : Float -> String
formatSecondsAsHMMSS seconds =
    let
        h : Int
        h =
            floor (seconds / 3600)

        m : Int
        m =
            floor ((seconds - toFloat h * 3600) / 60)

        s : Float
        s =
            seconds - toFloat (h * 3600 + m * 60)

        minutePrefix : String
        minutePrefix =
            if m < 10 then
                "0"

            else
                ""

        secondPrefix : String
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


{-|

    Converts a duration into seconds as a float.

-}
durationToSeconds : Duration -> Float
durationToSeconds duration =
    let
        hours : Int
        hours =
            Maybe.withDefault 0 duration.h

        minutes : Int
        minutes =
            Maybe.withDefault 0 duration.m
    in
    toFloat (3600 * hours + 60 * minutes) + duration.s


{-|

    Converts a list of submatches from a regular expression into a duration.

-}
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


{-|

    Parse a time string using a regular expression.

-}
parseTime : String -> Result String Duration
parseTime input =
    let
        -- regular expression that parses h:mm:ss.sss strings, hours and minutes being optional
        colonRegex : Regex.Regex
        colonRegex =
            Maybe.withDefault Regex.never <|
                Regex.fromString "(?:(?:(\\d+):)?(\\d{1,2}):)?(\\d{1,2}(?:\\.\\d+)?)$"

        -- regular expression that parses h hours m minutes s seconds strings, hours and minutes being optional
        textRegex : Regex.Regex
        textRegex =
            Maybe.withDefault Regex.never <|
                Regex.fromString "(?:(\\d+)\\s*(?:hours|hr|hrs|h)\\s*)?(?:(\\d+)\\s*(?:minutes|min|mins|m)\\s*)?(?:(\\d+)(?:\\.\\d+)?\\s*(?:seconds|sec|s))?"

        t : String
        t =
            String.trim input

        colonMatches : List Regex.Match
        colonMatches =
            Regex.find colonRegex t

        matches : List Regex.Match
        matches =
            if List.length colonMatches == 0 then
                Regex.find textRegex t

            else
                colonMatches
    in
    case matches of
        [ a ] ->
            Ok (submatchesToDuration a.submatches)

        _ ->
            Err "invalid"


{-|

    Parses a time string and converts it to seconds.

-}
normalizeTime : String -> Maybe Float
normalizeTime input =
    Maybe.map durationToSeconds <|
        Result.toMaybe (parseTime input)
