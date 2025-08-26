#!/usr/bin/env python3
"""DNS + proxy traffic handler"""
#sudo ./mitmdump -v --mode regular@127.0.0.1:80 --mode  regular@127.0.0.1:443

from dnslib import DNSRecord, DNSHeader, RR, A
from dnslib.server import DNSServer, DNSHandler, BaseResolver
import socketserver

class CustomResolver(BaseResolver):
    def resolve(self, request, handler):
        reply = request.reply()
        reply.add_answer(*RR.fromZone(str(request.q.qname) + " 60 A 127.0.0.1") )
        return reply

# Create and start the DNS server
if __name__ == '__main__':
    resolver = CustomResolver()
    print("Starting DNS server on 0.0.0.0:53...")
    # Use ThreadingUDPServer for concurrent handling of requests
    server = DNSServer(resolver, port=53, address="127.0.0.1",
                       handler=DNSHandler)
    server.start_thread()
    try:
        while True:
            pass # Keep the main thread alive
    except KeyboardInterrupt:
        print("DNS server stopped.")
        server.stop()
