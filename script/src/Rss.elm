module Rss exposing (run)

import Pages.Script as Script exposing (Script)
import BackendTask exposing (BackendTask)
import BackendTask.Time
import DateTime exposing (Date)
import Posts

run : Script
run =
    let
        posts = Posts.allBlogPosts
            |> BackendTask.andThen (List.map Posts.loadPost >> BackendTask.combine)
            |> BackendTask.map (List.sortWith <| \a b -> DateTime.compareNewer a.header.date b.header.date)
    in
        BackendTask.map2 (compose_rss_xml) today posts
            |> BackendTask.map make_rss_file
            |> BackendTask.andThen (Script.writeFile >> BackendTask.allowFatal)
            |> Script.doThen (Script.log "rss.xml file successfully written")
            |> Script.withoutCliOptions


compose_rss_xml : Date -> List Posts.Post -> String
compose_rss_xml date posts =
    let
        posts_xml = posts
            |> List.map post_to_xml
            |> String.join "\n" 
    in
        xml_header date ++ posts_xml ++ xml_footer


make_rss_file : String -> { path : String, body : String }
make_rss_file body = 
    { path = "./public/rss.xml"
    , body = body
    }


post_to_xml : Posts.Post -> String
post_to_xml post = "    <item>\n"
    ++ ("      <title>" ++ post.header.title ++ "</title>\n")
    ++ ("      <link>" ++ absolute_url post.header.url ++ "</link>\n")
    ++ ("      <guid>" ++ absolute_url post.header.url ++ "</guid>\n")
    ++ ("      <pubDate>" ++ DateTime.toStringRss post.header.date ++ "</pubDate>\n")
    ++ image_url_to_xml post.header.image
    ++ ("      <description>" ++ Posts.description post ++ "</description>\n")
    ++ "    </item>"


image_url_to_xml : Maybe String -> String
image_url_to_xml maybe_url = case maybe_url of
    Nothing -> ""
    Just url -> "      <image>" ++ absolute_url url ++ "</image>\n"


absolute_url : String -> String
absolute_url relative_url = "https://asielorz.github.io" ++ relative_url


xml_header : Date -> String
xml_header build_date = """<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
  <channel>
    <title>Asier Elorz</title>
    <description>Un blog en el que escribo sobre lo que me apetece.</description>
    <link>https://asielorz.github.io</link>
    <copyright>2024 Asier Elorz Hernáez All rights reserved</copyright>
    <language>es-es</language>
""" 
    ++ ("    <lastBuildDate>" ++ DateTime.toStringRss build_date ++ "</lastBuildDate>")


xml_footer : String
xml_footer = """
  </channel>
</rss>
"""

today : BackendTask error Date
today = BackendTask.Time.now
    |> BackendTask.map DateTime.fromPosix
