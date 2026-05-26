const http = require('http');

const PORT = 3000;

const USERS = {
  admin: 'rahasia123',
  mahasiswa: 'network2026',
};

function html(body) {
  return `<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8">
<title>Demo Login — Packet Sniffing</title>
<style>
  body { font-family: system-ui, sans-serif; max-width: 560px; margin: 2em auto; padding: 0 1em; line-height: 1.5; }
  h1 { margin-bottom: .2em; }
  input { display: block; width: 100%; padding: .5em; margin-top: .25em; box-sizing: border-box; font-size: 1em; }
  label { display: block; margin: .75em 0; }
  button { padding: .6em 1.2em; font-size: 1em; cursor: pointer; }
  pre { background: #f4f4f4; padding: .75em 1em; overflow-x: auto; }
  .ok { color: #1a7f37; }
  .fail { color: #c0392b; }
  .notice { background: #fffae6; border-left: 4px solid #f5a623; padding: .5em 1em; margin: 1em 0; }
  code { background: #eee; padding: .1em .3em; border-radius: 3px; }
</style>
</head>
<body>${body}</body>
</html>`;
}

function loginForm(error) {
  return html(`
    <h1>Demo Login</h1>
    <p class="notice"><strong>HTTP plaintext</strong> — form submission akan terbaca utuh oleh sniffer di network path antara browser dan server ini.</p>
    ${error ? `<p class="fail">${error}</p>` : ''}
    <form method="POST" action="/login">
      <label>Username
        <input name="username" autofocus autocomplete="off">
      </label>
      <label>Password
        <input name="password" type="password" autocomplete="off">
      </label>
      <button type="submit">Login</button>
    </form>
    <p>Akun demo:</p>
    <ul>
      <li><code>admin</code> / <code>rahasia123</code></li>
      <li><code>mahasiswa</code> / <code>network2026</code></li>
    </ul>
  `);
}

function resultPage(ok, username, password) {
  const status = ok
    ? `<h1 class="ok">Login Sukses</h1><p>Selamat datang, <strong>${escapeHtml(username)}</strong>.</p>`
    : `<h1 class="fail">Login Gagal</h1><p>Username atau password salah.</p>`;
  return html(`
    ${status}
    <h2>Yang dilihat server</h2>
    <p>Body POST yang masuk ke handler:</p>
    <pre>username=${escapeHtml(username)}&amp;password=${escapeHtml(password)}</pre>
    <p class="notice"><strong>Insight sniffing</strong>: nilai di atas terkirim apa adanya melalui jaringan. Siapa pun yang dapat membaca paket di jalur (rogue WiFi AP, switch port mirror, router yang terkompromi, ISP) bisa langsung membaca username dan password. Solusi: HTTPS — TLS mengenkripsi seluruh HTTP message body sehingga sniffer hanya mendapat ciphertext.</p>
    <p><a href="/login">Coba lagi</a></p>
  `);
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let buf = '';
    req.on('data', chunk => {
      buf += chunk;
      if (buf.length > 64 * 1024) {
        reject(new Error('body too large'));
        req.destroy();
      }
    });
    req.on('end', () => resolve(buf));
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  const pathname = new URL(req.url, `http://${req.headers.host || 'localhost'}`).pathname;
  const ts = new Date().toISOString();
  console.log(`${ts} ${req.method} ${pathname}`);

  try {
    if (req.method === 'GET' && (pathname === '/' || pathname === '/login')) {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(loginForm());
      return;
    }

    if (req.method === 'POST' && pathname === '/login') {
      const raw = await readBody(req);
      const params = new URLSearchParams(raw);
      const username = params.get('username');
      const password = params.get('password');

      if (username === null || password === null) {
        res.writeHead(400, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(loginForm('Form fields username dan password wajib diisi.'));
        return;
      }

      console.log(`  raw body: ${raw}`);
      console.log(`  parsed: username="${username}" password="${password}"`);

      const expected = USERS[username];
      const ok = expected !== undefined && expected === password;

      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(resultPage(ok, username, password));
      return;
    }

    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Not Found\n');
  } catch (err) {
    console.error(`${ts} error:`, err);
    res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end(`Internal Server Error: ${err.message}\n`);
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Demo login server listening on http://0.0.0.0:${PORT}`);
  console.log(`Sniff:   sudo tcpdump -i any -A -s 0 -nn 'tcp port ${PORT} and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`);
  console.log(`Or:      sudo tcpdump -i any -A -s 0 -nn 'tcp port ${PORT}'`);
});
