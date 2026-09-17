"""Local-only static preview: python tools/serve_web.py [port]."""
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from functools import partial
from pathlib import Path
import sys
import webbrowser

directory = Path(__file__).resolve().parents[1] / 'build' / 'web'
port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
if not (directory / 'index.html').exists():
    raise SystemExit('Export the Web preset to build/web/index.html first.')
server = ThreadingHTTPServer(('127.0.0.1', port), partial(SimpleHTTPRequestHandler, directory=str(directory)))
url = f'http://127.0.0.1:{port}/'
print(f'Yokodori Days: {url}\nCtrl+C to stop.')
webbrowser.open(url)
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
finally:
    server.server_close()
