import http
import std/net
import tables

const error404Content = readFile("pages/error404.html")

proc error404*(client: Socket) =
    var response = getResponse(404, error404Content)
    discard client.trySend(response)

proc displayStaticPage*(client: Socket, page: string) =
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

proc otherIndex(client: Socket) {.procvar.} =
    var response = getResponse(200, readFile("pages/index.html"))
    discard client.trySend(response)

type
    RouteMethod* = proc(self: Socket)

const redirects* = {
    "": helloWorld,
    "index": otherIndex
}.toTable