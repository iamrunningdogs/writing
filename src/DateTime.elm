module DateTime exposing
    ( Date
    , compareNewer
    , compareOlder
    , fromPosix
    , intToMonth
    , jsonDecode
    , monthToInt
    , monthToString
    , parserISO8601
    , sortNewestToOldest
    , sortOldestToNewest
    , toStringText
    , toStringYYYYMMDD
    , toStringRss
    )

import Json.Decode
import Json.Encode
import Parser exposing ((|.), (|=), Parser, Problem(..), problem)
import Time
import Array exposing (Array)


type alias Date =
    { year : Int
    , month : Time.Month
    , day : Int
    }


intToMonth : Int -> Time.Month
intToMonth i =
    case i of
        1 ->
            Time.Jan

        2 ->
            Time.Feb

        3 ->
            Time.Mar

        4 ->
            Time.Apr

        5 ->
            Time.May

        6 ->
            Time.Jun

        7 ->
            Time.Jul

        8 ->
            Time.Aug

        9 ->
            Time.Sep

        10 ->
            Time.Oct

        11 ->
            Time.Nov

        _ ->
            Time.Dec


monthToInt : Time.Month -> Int
monthToInt m =
    case m of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


monthToString : Time.Month -> String
monthToString m =
    case m of
        Time.Jan ->
            "enero"

        Time.Feb ->
            "febrero"

        Time.Mar ->
            "marzo"

        Time.Apr ->
            "abril"

        Time.May ->
            "mayo"

        Time.Jun ->
            "junio"

        Time.Jul ->
            "julio"

        Time.Aug ->
            "agosto"

        Time.Sep ->
            "septiembre"

        Time.Oct ->
            "octubre"

        Time.Nov ->
            "noviembre"

        Time.Dec ->
            "diciembre"


monthToStringEngShort : Time.Month -> String
monthToStringEngShort m =
    case m of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"


weekdayToStringEngShort : Time.Weekday -> String
weekdayToStringEngShort d =
    case d of
        Time.Mon -> "Mon"
        Time.Tue -> "Tue"
        Time.Wed -> "Wed"
        Time.Thu -> "Thu"
        Time.Fri -> "Fri"
        Time.Sat -> "Sat"
        Time.Sun -> "Sun"


parserISO8601 : Parser Date
parserISO8601 =
    Parser.succeed Date
        |. Parser.symbol "\""
        -- Year
        |= Parser.int
        |. Parser.symbol "-"
        -- Month
        |. Parser.oneOf [ Parser.symbol "0", Parser.succeed () ]
        |= (Parser.int |> Parser.map intToMonth)
        |. Parser.symbol "-"
        -- Day
        |. Parser.oneOf [ Parser.symbol "0", Parser.succeed () ]
        |= Parser.int


jsonDecode : Json.Decode.Decoder Date
jsonDecode =
    Json.Decode.value
        |> Json.Decode.andThen
            (\v ->
                let
                    date_as_string =
                        Json.Encode.encode 0 v

                    parsed_date =
                        Parser.run parserISO8601 date_as_string
                in
                case parsed_date of
                    Ok date ->
                        Json.Decode.succeed date

                    Err err ->
                        Json.Decode.fail <| "Json value " ++ date_as_string ++ " does not represent an ISO 8601 date: " ++ deadEndsToString err
            )


toStringYYYYMMDD : Date -> String
toStringYYYYMMDD date =
    String.fromInt date.year
        ++ "-"
        ++ String.padLeft 2 '0' (String.fromInt (monthToInt date.month))
        ++ "-"
        ++ String.padLeft 2 '0' (String.fromInt date.day)


toStringText : Date -> String
toStringText date =
    String.fromInt date.day
        ++ " de "
        ++ monthToString date.month
        ++ " de "
        ++ String.fromInt date.year


toStringRss : Date -> String
toStringRss date = 
    let
        weekday = toMillis date
            |> Time.millisToPosix
            |> Time.toWeekday Time.utc
    in
        weekdayToStringEngShort weekday
        ++ ", "
        ++ String.fromInt date.day
        ++ " "
        ++ monthToStringEngShort date.month
        ++ " "
        ++ String.fromInt date.year
        ++ " 00:00:00 +0000"


problemToString : Parser.Problem -> String
problemToString problem =
    case problem of
        Expecting str ->
            "Expecting " ++ str

        ExpectingInt ->
            "Expecting int"

        ExpectingHex ->
            "Expecting hex"

        ExpectingOctal ->
            "Expecting octal"

        ExpectingBinary ->
            "Expecting binary"

        ExpectingFloat ->
            "Expecting float"

        ExpectingNumber ->
            "Expecting number"

        ExpectingVariable ->
            "Expecting variable"

        ExpectingSymbol str ->
            "Expecting symbol " ++ str

        ExpectingKeyword str ->
            "Expecting keyword " ++ str

        ExpectingEnd ->
            "Expecting end"

        UnexpectedChar ->
            "Unexpected char"

        Problem str ->
            "Problem: " ++ str

        BadRepeat ->
            "Bad repeat"


deadEndToString : Parser.DeadEnd -> String
deadEndToString dead_end =
    "(" ++ String.fromInt dead_end.row ++ ", " ++ String.fromInt dead_end.col ++ ") " ++ problemToString dead_end.problem


deadEndsToString : List Parser.DeadEnd -> String
deadEndsToString dead_ends =
    List.map deadEndToString dead_ends |> String.join "\n"


compareOlder : Date -> Date -> Order
compareOlder a b =
    let
        a_month_int =
            monthToInt a.month

        b_month_int =
            monthToInt b.month
    in
    if a.year < b.year then
        LT

    else if b.year < a.year then
        GT

    else if a_month_int < b_month_int then
        LT

    else if b_month_int < a_month_int then
        GT

    else
        compare a.day b.day


compareNewer : Date -> Date -> Order
compareNewer a b =
    compareOlder b a


sortOldestToNewest : List Date -> List Date
sortOldestToNewest dates =
    List.sortWith compareOlder dates


sortNewestToOldest : List Date -> List Date
sortNewestToOldest dates =
    List.sortWith compareNewer dates


fromPosix : Time.Posix -> Date
fromPosix posix = 
    { year = Time.toYear Time.utc posix
    , month = Time.toMonth Time.utc posix
    , day = Time.toDay Time.utc posix
    }


-- All functions below have been copied from PanagiotisGeorgiadis/elm-datetime
toMillis : Date -> Int
toMillis { year, month, day } =
    millisSinceEpoch year
        + millisSinceStartOfTheYear year month
        + millisSinceStartOfTheMonth day


millisSinceEpoch : Int -> Int
millisSinceEpoch year =
    let
        epochYear =
            1970

        getTotalMillis =
            List.sum << List.map millisInYear
    in
    if year >= 1970 then
        -- We chose (year - 1) here because we want the milliseconds
        -- in the start of the target year in order to add
        -- the months + days + hours + minutes + secs + millis if we want to.
        getTotalMillis (List.range epochYear (year - 1))

    else
        -- We chose (epochYear - 1) here because we want to
        -- get the total milliseconds of all the previous years,
        -- including the target year which we'll then add
        -- the months + days + hours + minutes + secs + millis in millis
        -- in order to get the desired outcome.
        -- Example: Target date = 26 Aug 1950.
        -- totalMillis from 1/1/1950 - 1/1/1969 = -631152000000
        -- 26 Aug date millis = 20476800000
        -- Resulting millis will be = -631152000000 + 20476800000 == -610675200000 == 26 Aug 1950
        Basics.negate <| getTotalMillis (List.range year (epochYear - 1))


millisInYear : Int -> Int
millisInYear year =
    if isLeapYear year then
        millisInADay * 366

    else
        millisInADay * 365


isLeapYear : Int -> Bool
isLeapYear year =
    (modBy 4 year == 0) && ((modBy 400 year == 0) || not (modBy 100 year == 0))


millisInADay : Int
millisInADay =
    1000 * 60 * 60 * 24


millisSinceStartOfTheYear : Int -> Time.Month -> Int
millisSinceStartOfTheYear year month =
    List.foldl
        (\m res ->
            res + (millisInADay * lastDayOf year m)
        )
        0
        (getPrecedingMonths month)


lastDayOf : Int -> Time.Month -> Int
lastDayOf year month =
    case month of
        Time.Jan ->
            31

        Time.Feb ->
            if isLeapYear year then
                29

            else
                28

        Time.Mar ->
            31

        Time.Apr ->
            30

        Time.May ->
            31

        Time.Jun ->
            30

        Time.Jul ->
            31

        Time.Aug ->
            31

        Time.Sep ->
            30

        Time.Oct ->
            31

        Time.Nov ->
            30

        Time.Dec ->
            31


months : Array Time.Month
months =
    Array.fromList
        [ Time.Jan
        , Time.Feb
        , Time.Mar
        , Time.Apr
        , Time.May
        , Time.Jun
        , Time.Jul
        , Time.Aug
        , Time.Sep
        , Time.Oct
        , Time.Nov
        , Time.Dec
        ]


getPrecedingMonths : Time.Month -> List Time.Month
getPrecedingMonths month =
    Array.toList <|
        Array.slice 0 (monthToInt month - 1) months
    

millisSinceStartOfTheMonth : Int -> Int
millisSinceStartOfTheMonth day =
    -- -1 on the day because we are currently on that day and it hasn't passed yet.
    -- We also need time in order to construct the full posix.
    millisInADay * day - 1
