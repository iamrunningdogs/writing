module View exposing (View, map)

import Element as UI


type alias View msg =
    { title : String
    , body : UI.Element msg
    }


map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = UI.map fn doc.body
    }
