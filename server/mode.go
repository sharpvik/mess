package server

// toDevServer returns a server that runs on localhost port 8080.
func toDevServer(serv *Server) {
	serv.server.Addr = "127.0.0.1:8080"
}

// toProdServer returns a server that will be listening on the publically
// available standard HTTP port.
func toProdServer(serv *Server) {
	serv.server.Addr = "0.0.0.0:80"
}
