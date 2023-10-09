module DateTime exposing
    ( Date
    , compareNewer
    , compareOlder
    , intToMonth
    , jsonDecode
    , monthToInt
    , monthToString
    , parserISO8601
    , sortNewestToOldest
    , sortOldestToNewest
    , toStringText
    , toStringYYYYMMDD
    )

import Json.Decode
import Json.Encode
import Parser exposing ((|.), (|=), Parser, Problem(..), problem)
import Time


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
