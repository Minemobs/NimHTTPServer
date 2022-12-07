import std/times
import tables
import strformat
import strutils

const mediaTypes = {
    "png": "image/png",
    "zip": "application/zip",
    "json": "application/json",
    "css": "text/css",
    "": "application/octet-stream",
    "jar": "application/java-archive",
    "html": "text/html",
    "txt": "text/plain",
    "mp4": "video/mp4",
    "js": "application/javascript"
}.toTable

proc getResponse*(code: int, txt: string, contentType: string = "text/html"): string =
    let date = now().format("ddd, dd MMM yyyy HH:mm:ss zzz")
    let len = len(txt)
    return fmt("HTTP/1.1 {code} I'm lazy\nServer: MinemobsNim/0.1\nDate: {date}\nContent-type: {contentType}\nContent-Length: {len}\n\n{txt}")

proc getMediaType*(page: string): string =
    let extension = page.split(".")
    return mediaTypes.getOrDefault(extension[extension.len() - 1], "text/plain")