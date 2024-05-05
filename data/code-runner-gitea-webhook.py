from http.server import BaseHTTPRequestHandler, HTTPServer
import subprocess
import shutil
import threading
import json
import os

builddir="/tmp/code-runner"
class WebhookHandler(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()


    def run_code_runner(self, target, **kwargs):
        subprocess.run(["ymp", "code-runner", target+"/build.yaml"])

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        payload = json.loads(post_data.decode('utf-8'))

        repo=payload["repository"]["clone_url"]
        target=builddir+"/"+payload["repository"]["full_name"]
        if os.path.exists(target):
            shutil.rmtree(target)
        if not os.path.isdir(os.path.dirname(target)):
            os.makedirs(os.path.dirname(target))
        subprocess.run(["git", "clone", repo, target])
        thread = threading.Thread(target=self.run_code_runner, args=(target,))
        thread.start()


        self._set_headers()
        self.wfile.write(json.dumps({'status': 'success'}).encode('utf-8'))

def run(server_class=HTTPServer, handler_class=WebhookHandler, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Starting server on port {port}...')
    httpd.serve_forever()

if __name__ == '__main__':
    run()

