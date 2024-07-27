module Utils exposing (..)


capitalize : String -> String
capitalize str =
    if String.isEmpty str then
        str

    else
        String.toUpper (String.left 1 str) ++ String.dropLeft 1 str


kebab_case_to_sentence : String -> String
kebab_case_to_sentence str = str |> String.replace "-" " "
