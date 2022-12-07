import std/net
import strformat
import strutils
import std/tables
import routes

let socket = newSocket()
socket.bindAddr(Port(6969))
socket.listen()

var client: Socket
var address = ""

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