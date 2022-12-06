import std/net
import std/times
import strformat
import strutils
import std/tables

let socket = newSocket()
socket.bindAddr(Port(6969))
socket.listen()

var client: Socket
var address = ""

const error404Content = readFile("error404.html")

proc getResponse(code: int, txt: string, contentType: string = "text/html"): string =
    let date = now().format("ddd, dd MMM yyyy HH:mm:ss zzz")
    let len = len(txt)
    return fmt("HTTP/1.1 {code} I'm lazy\nServer: MinemobsNim/0.1\nDate: {date}\nContent-type: {contentType}\nContent-Length: {len}\n\n{txt}")

proc error404(client: Socket) =
    var response = getResponse(404, error404Content)
    discard client.trySend(response)

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

proc getMediaType(page: string): string =
    let extension = page.split(".")
    return mediaTypes.getOrDefault(extension[extension.len() - 1], "text/plain")

proc displayStaticPage(client: Socket, page: string) =
    var content: string = ""
    try:
        content = readFile(page)
    except:
        error404(client)
        return
    discard client.trySend(getResponse(200, content, getMediaType(page)))

proc helloWorld(client: Socket) {.procvar.} =
    var response = getResponse(200, "<!DOCTYPE html><html><body><p>Hello World</p></body></html>")
    discard client.trySend(response)

type
    RouteMethod = proc(self: Socket)

var redirects = {
    "": helloWorld
}.toTable

while true:
    socket.acceptAddr(client, address)
    echo "Client connected from: ", address
    var headers: string
    try:
        discard client.recv(headers, 4096, 300)
    except TimeoutError:
        discard
    var page = split(headers, "\n")[0]
    if(page.len() > 1): page = splitWhitespace(page)[1].substr(1)
    echo fmt"Asking for page: '{page}'"
    if page.startsWith("static/"): displayStaticPage(client, page)
    elif not redirects.hasKey(page): error404(client)
    else:
        let route : RouteMethod = redirects[page]
        client.route()
    client.close()