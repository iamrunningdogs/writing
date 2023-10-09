module SeoConfig exposing (defaultSeo, imageFromUrl)

import Head.Seo as Seo
import LanguageTag.Country
import LanguageTag.Language
import MimeType
import Pages.Url
import UrlPath


defaultSeo : Seo.Common
defaultSeo =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Asier Elorz"
        , image =
            { url = [ "images", "caricatura.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "Logo de la página. Es una caricatura del autor dibujada a lápiz en un papel."
            , dimensions = Just { width = 237, height = 237 }
            , mimeType = Just <| MimeType.Image MimeType.Png
            }
        , description = "Blog personal de Asier Elorz, en el que escribo sobre cosas que me interesan."
        , locale = Just ( LanguageTag.Language.es, LanguageTag.Country.es )
        , title = "Página principal — Asier Elorz"
        }


imageFromUrl : String -> Seo.Image
imageFromUrl url =
    { url = Pages.Url.external url
    , alt = ""
    , dimensions = Nothing
    , mimeType = Nothing
    }
