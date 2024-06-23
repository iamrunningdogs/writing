module SeoConfig exposing (defaultSeo, imageFromUrl, makeHeadTags)

import Head
import Head.Seo as Seo
import LanguageTag.Region
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
        , locale = Just ( LanguageTag.Language.es, LanguageTag.Region.es )
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


last : List a -> Maybe a
last l =
    List.drop (List.length l - 1) l |> List.head


inferImageMimeType : String -> Maybe MimeType.MimeImage
inferImageMimeType image_url =
    let
        extension =
            image_url
                |> String.split "/"
                |> last
                {- Should never happen -} |> Maybe.withDefault ""
                |> String.split "."
                |> last
                |> Maybe.withDefault ""
                |> String.toLower
    in
    if extension == "png" then
        Just MimeType.Png

    else if extension == "jpg" || extension == "jpeg" then
        Just MimeType.Jpeg

    else if extension == "gif" then
        Just MimeType.Gif

    else if not <| String.isEmpty extension then
        Just <| MimeType.OtherImage extension

    else
        Nothing


imageFromUrl : String -> Maybe String -> Seo.Image
imageFromUrl url alt_text =
    { url = Pages.Url.external url
    , alt = alt_text |> Maybe.withDefault ""
    , dimensions = Nothing
    , mimeType = inferImageMimeType url |> Maybe.map MimeType.Image
    }
