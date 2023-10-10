module SeoConfig exposing (defaultSeo, imageFromUrl, makeHeadTags)

import Head
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


{-| Use this instead of Seo.website to ensure that the Twitter card
is updated to match the other fields. This way it is easier for a page
to change some fields on the defaultSeo and have the correct behavior
without having to remember to update the Twitter card as well.
-}
makeHeadTags : Seo.Common -> List Head.Tag
makeHeadTags config =
    let
        summary =
            Seo.summary
                { canonicalUrlOverride = config.canonicalUrlOverride
                , siteName = config.siteName
                , image = config.image
                , description = config.description
                , locale = config.locale
                , title = config.title
                }
    in
    Seo.website
        { summary
            | audio = config.audio
            , video = config.video
            , alternateLocales = config.alternateLocales
        }


imageFromUrl : String -> Seo.Image
imageFromUrl url =
    { url = Pages.Url.external url
    , alt = ""
    , dimensions = Nothing
    , mimeType = Nothing
    }
