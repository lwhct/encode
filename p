const TARGET = "www.pornhub.com";
const KEY = "myProxy2026key";
const PROXY_RE = /\.(?:pornhub|phncdn|phprcdn)\.com$/;

function enc(s) {
  var o = "";
  for (var i = 0; i < s.length; i++) {
    var c = (s.charCodeAt(i) ^ KEY.charCodeAt(i % KEY.length)).toString(16);
    if (c.length < 2) c = "0" + c;
    o += c;
  }
  return o;
}

function dec(hex) {
  var o = "";
  for (var i = 0; i < hex.length; i += 2) {
    o += String.fromCharCode(parseInt(hex.substr(i, 2), 16) ^ KEY.charCodeAt((i / 2) % KEY.length));
  }
  return o;
}

const INJECT_SCRIPT = `<script>
(function(){
  var oh=location.hash;
  history.replaceState({},"",location.pathname+location.search+"#.pornhub.com");
  document.addEventListener("DOMContentLoaded",function(){history.replaceState({},"",location.pathname+location.search+(oh||""))});
  var W=location.host,S=location.protocol+"//",K="${KEY}",T="${TARGET}";
  function enc(s){var o="";for(var i=0;i<s.length;i++){var c=(s.charCodeAt(i)^K.charCodeAt(i%K.length)).toString(16);if(c.length<2)c="0"+c;o+=c}return o}
  function dec(x){var o="";for(var i=0;i<x.length;i+=2){o+=String.fromCharCode(parseInt(x.substr(i,2),16)^K.charCodeAt((i/2)%K.length))}return o}
  function isP(h){return h.indexOf(".phncdn.com")!==-1||h.indexOf(".pornhub.com")!==-1||h.indexOf(".phprcdn.com")!==-1||h==="pornhub.com"}
  function rw(u){try{var o=new URL(u,location.href);if(o.host!==W&&isP(o.host)){var si=o.pathname.lastIndexOf("/");if(si>=0&&si<o.pathname.length-1)return S+W+"/_/"+enc(o.origin+o.pathname.substring(0,si+1))+"/"+o.pathname.substring(si+1)+o.search;return S+W+"/_/"+enc(o.origin+o.pathname+o.search)}}catch(e){}return u}
  try{var _r=document.referrer;if(_r){var _u=new URL(_r);if(_u.host===W){var nr;if(_u.pathname.startsWith("/_/")){var hx=_u.pathname.slice(3).split("/")[0];try{nr=new URL(dec(hx)).href}catch(e){nr="https://"+T+_u.pathname+_u.search}}else{nr="https://"+T+_u.pathname+_u.search}Object.defineProperty(document,"referrer",{get:function(){return nr}})}}}catch(e){}
  var _f=window.fetch;window.fetch=function(i,o){if(typeof i==="string")i=rw(i);else if(i instanceof Request)i=new Request(rw(i.url),i);return _f.call(this,i,o)};
  var _xo=XMLHttpRequest.prototype.open;XMLHttpRequest.prototype.open=function(m,u){arguments[1]=rw(u);return _xo.apply(this,arguments)};
  var _wo=window.open;window.open=function(u){if(typeof u==="string")arguments[0]=rw(u);return _wo.apply(this,arguments)};
  var _sa=Element.prototype.setAttribute;Element.prototype.setAttribute=function(a,v){if(typeof v==="string"&&/^(src|href|poster|action)$/.test(a))v=rw(v);return _sa.call(this,a,v)};
  [HTMLMediaElement,HTMLSourceElement,HTMLImageElement].forEach(function(C){var d=Object.getOwnPropertyDescriptor(C.prototype,"src");if(d&&d.set)Object.defineProperty(C.prototype,"src",{set:function(v){d.set.call(this,rw(v))},get:d.get,configurable:true})});
  var _sSrc=Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype,"src");if(_sSrc&&_sSrc.set)Object.defineProperty(HTMLScriptElement.prototype,"src",{get:function(){var v=_sSrc.get.call(this);if(v&&v.indexOf(W+"/_/")!==-1){try{var u=new URL(v);if(u.host===W&&u.pathname.startsWith("/_/")){var ps=u.pathname.slice(3).split("/"),h=ps[0];if(/^[0-9a-f]+$/.test(h)&&h.length>10){var d=dec(h);try{if(new URL(d).host)return ps.length>1?d+ps.slice(1).join("/"):d}catch(e){}}}}catch(e){}}return v},set:function(v){if(typeof v==="string")v=rw(v);_sSrc.set.call(this,v)},configurable:true});
  var _lHref=Object.getOwnPropertyDescriptor(HTMLLinkElement.prototype,"href");if(_lHref&&_lHref.set)Object.defineProperty(HTMLLinkElement.prototype,"href",{get:_lHref.get,set:function(v){if(typeof v==="string")v=rw(v);_lHref.set.call(this,v)},configurable:true});
  function fixEl(n){if(!n||!n.tagName)return;["src","href","poster","action"].forEach(function(a){var v=n.getAttribute(a);if(v){try{var nv=rw(v);if(nv!==v)_sa.call(n,a,nv)}catch(x){}}})}
  new MutationObserver(function(ms){ms.forEach(function(m){m.addedNodes.forEach(function(n){fixEl(n);if(n.querySelectorAll)try{n.querySelectorAll("[src],[href],[poster],[action]").forEach(fixEl)}catch(x){}})})}).observe(document.documentElement,{childList:true,subtree:true});
})();
</script>`;

function rewriteUrls(text, workerHost, scheme) {
  function se(host, p) {
    var qi = p.indexOf("?"), pp = qi >= 0 ? p.substring(0, qi) : p, q = qi >= 0 ? p.substring(qi) : "";
    var si = pp.lastIndexOf("/");
    if (si >= 0 && si < pp.length - 1) {
      return enc("https://" + host + pp.substring(0, si + 1)) + "/" + pp.substring(si + 1) + q;
    }
    return enc("https://" + host + p);
  }
  text = text.replace(/https?:\/\/([a-z0-9][-a-z0-9.]*\.(?:phncdn|pornhub|phprcdn)\.com)([^\s"'<>#`{}\\]*)/gi, function(m, host, path) {
    var p = (path || "").replace(/&amp;/g, "&");
    return scheme + "://" + workerHost + "/_/" + se(host.toLowerCase(), p);
  });
  text = text.replace(/\/\/([a-z0-9][-a-z0-9.]*\.(?:phncdn|pornhub|phprcdn)\.com)([^\s"'<>#`{}\\]*)/gi, function(m, host, path) {
    var p = (path || "").replace(/&amp;/g, "&");
    return "//" + workerHost + "/_/" + se(host.toLowerCase(), p);
  });
  text = text.replace(/https?:\\\/\\\/([a-z0-9][-a-z0-9.]*\.(?:phncdn|pornhub|phprcdn)\.com)((?:[^\s"'<>#`{}\\]|\\\/)*)/gi, function(m, host, path) {
    var p = (path || "").replace(/\\\//g, "/").replace(/&amp;/g, "&");
    return scheme + ":\\/\\/" + workerHost + "\\/_\\/" + se(host.toLowerCase(), p).replace(/\//g, "\\/");
  });
  text = text.replace(/\\\/\\\/([a-z0-9][-a-z0-9.]*\.(?:phncdn|pornhub|phprcdn)\.com)((?:[^\s"'<>#`{}\\]|\\\/)*)/gi, function(m, host, path) {
    var p = (path || "").replace(/\\\//g, "/").replace(/&amp;/g, "&");
    return "\\/\\/" + workerHost + "\\/_\\/" + se(host.toLowerCase(), p).replace(/\//g, "\\/");
  });
  return text;
}

function deriveReferer(browserRef, workerHost) {
  if (!browserRef) return null;
  try {
    var ru = new URL(browserRef);
    if (ru.host !== workerHost) return browserRef;
    if (ru.pathname.startsWith("/_/")) {
      var rest = ru.pathname.slice(3);
      var idx = rest.indexOf("/");
      var hex = idx > -1 ? rest.slice(0, idx) : rest;
      var extra = idx > -1 ? rest.slice(idx) : "";
      var d = dec(hex);
      try {
        var tu = new URL(d);
        return extra
          ? tu.origin + tu.pathname.replace(/\/$/, "") + extra + ru.search
          : tu.href;
      } catch (e) {
        return "https://" + TARGET + ru.pathname + ru.search;
      }
    }
    return "https://" + TARGET + ru.pathname + ru.search;
  } catch (e) {}
  return null;
}

function buildHeaders(request, targetHost, workerHost) {
  var h = new Headers();
  h.set("host", targetHost);
  var ref = deriveReferer(request.headers.get("referer"), workerHost);
  h.set("referer", ref || "https://" + targetHost + "/");
  h.set("origin", "https://" + targetHost);
  ["user-agent", "accept", "accept-language", "range", "cookie", "content-type",
   "if-none-match", "if-modified-since"].forEach(function (k) {
    var v = request.headers.get(k);
    if (v) h.set(k, v);
  });
  h.set("accept-encoding", "gzip, deflate, br");
  return h;
}

export default {
  async fetch(request) {
    try {
      var url = new URL(request.url);
      var workerHost = url.host;
      var scheme = url.protocol.replace(":", "");
      var targetUrl, targetHost;

      if (request.method === "OPTIONS") {
        return new Response(null, {
          headers: {
            "access-control-allow-origin": "*",
            "access-control-allow-methods": "GET, POST, PUT, DELETE, OPTIONS",
            "access-control-allow-headers": "*",
            "access-control-max-age": "86400"
          }
        });
      }

      if (url.pathname === "/_test") {
        var td = "https://di.phncdn.com/test/path?a=1";
        var e = enc(td);
        return new Response(JSON.stringify({ ok: dec(e) === td, encoded: e, decoded: dec(e) }), {
          headers: { "content-type": "application/json" }
        });
      }

      if (url.pathname.startsWith("/_/")) {
        var rest = url.pathname.slice(3);
        var idx = rest.indexOf("/");
        var hex = idx > -1 ? rest.slice(0, idx) : rest;
        var extra = idx > -1 ? rest.slice(idx) : "";
        var decrypted = dec(hex);
        var parsed = false;
        try {
          var tu = new URL(decrypted);
          if (tu.host && tu.host.includes(".")) {
            targetHost = tu.host;
            targetUrl = extra
              ? tu.origin + tu.pathname.replace(/\/$/, "") + extra + url.search
              : tu.href;
            parsed = true;
          }
        } catch (e) {}
        if (!parsed) {
          var ref = deriveReferer(request.headers.get("referer"), workerHost);
          try {
            var ru = ref ? new URL(ref) : null;
            if (ru && PROXY_RE.test(ru.host)) {
              var basePath = ru.pathname.replace(/\/[^\/]*$/, "/");
              targetHost = ru.host;
              targetUrl = ru.origin + basePath + rest + url.search;
            } else {
              targetHost = TARGET;
              targetUrl = "https://" + TARGET + "/_/" + rest + url.search;
            }
          } catch (e2) {
            targetHost = TARGET;
            targetUrl = "https://" + TARGET + "/_/" + rest + url.search;
          }
        }
      } else {
        targetHost = TARGET;
        targetUrl = "https://" + TARGET + url.pathname + url.search;
      }

      var reqHeaders = buildHeaders(request, targetHost, workerHost);
      var resp, redirects = 0, allCookies = [];
      while (redirects < 5) {
        resp = await fetch(targetUrl, {
          method: redirects === 0 ? request.method : "GET",
          headers: reqHeaders,
          body: redirects === 0 && request.method !== "GET" && request.method !== "HEAD" ? request.body : null,
          redirect: "manual"
        });
        var rc = resp.headers.getSetCookie ? resp.headers.getSetCookie() : [];
        if (rc.length) allCookies.push.apply(allCookies, rc);
        if (![301, 302, 303, 307, 308].includes(resp.status)) break;
        var loc = resp.headers.get("location");
        if (!loc) break;
        if (loc.startsWith("/")) loc = "https://" + targetHost + loc;
        try {
          var lu = new URL(loc);
          if (PROXY_RE.test(lu.host)) {
            targetHost = lu.host;
            targetUrl = lu.href;
            reqHeaders.set("host", targetHost);
            reqHeaders.set("referer", "https://" + targetHost + "/");
            redirects++;
            continue;
          }
        } catch (e) {}
        var rh = new Headers({ location: loc });
        allCookies.forEach(function(c) {
          rh.append("set-cookie", c.replace(/;\s*domain=[^;]*/gi, ""));
        });
        return new Response(null, { status: resp.status, headers: rh });
      }

      var ct = (resp.headers.get("content-type") || "").toLowerCase();
      var respHeaders = new Headers(resp.headers);
      respHeaders.delete("content-security-policy");
      respHeaders.delete("content-security-policy-report-only");
      respHeaders.delete("strict-transport-security");
      respHeaders.delete("x-frame-options");
      respHeaders.set("access-control-allow-origin", "*");
      if (allCookies.length) {
        respHeaders.delete("set-cookie");
        allCookies.forEach(function(c) {
          c = c.replace(/;\s*domain=[^;]*/gi, "");
          respHeaders.append("set-cookie", c);
        });
      }

      if (ct.includes("text/html")) {
        var text = await resp.text();
        text = rewriteUrls(text, workerHost, scheme);
        text = text.replace(/<head([^>]*)>/i, "<head$1>" + INJECT_SCRIPT);
        respHeaders.delete("content-encoding");
        respHeaders.delete("content-length");
        respHeaders.set("cache-control", "no-cache");
        return new Response(text, { status: resp.status, headers: respHeaders });
      }

      var isTextRes = /javascript|text\/css|application\/json/i.test(ct);
      var isManifest = /mpegurl|m3u|dash\+xml/i.test(ct) || /\.(m3u8|mpd)(\?|$)/.test(targetUrl);
      if (isTextRes || isManifest) {
        var body = await resp.text();
        if (/text\/css/i.test(ct)) {
          try {
            var cssBaseDir = new URL(targetUrl).origin + new URL(targetUrl).pathname.replace(/\/[^\/]*$/, "/");
          } catch(e) { var cssBaseDir = null; }
          if (cssBaseDir) {
            body = body.replace(/url\(\s*(['"]?)([^)'"]+)\1\s*\)/gi, function(m, q, u) {
              u = u.trim();
              if (/^(data:|#)/.test(u)) return m;
              if (/^(https?:\/\/|\/\/)/.test(u)) return 'url("' + u + '")';
              try { return 'url("' + new URL(u, cssBaseDir).href + '")'; }
              catch(e) { return m; }
            });
          }
        }
        if (isManifest) {
          try {
            var mBase = new URL(targetUrl).origin + new URL(targetUrl).pathname.replace(/\/[^\/]*$/, "/");
          } catch(e) { var mBase = null; }
          if (mBase) {
            body = body.replace(/^(?!#)(\S+)$/gm, function(line) {
              line = line.trim();
              if (!line || /^https?:\/\//.test(line)) return line;
              try { return new URL(line, mBase).href; } catch(e) { return line; }
            });
            body = body.replace(/URI="([^"]+)"/gi, function(m, u) {
              if (/^https?:\/\//.test(u)) return m;
              try { return 'URI="' + new URL(u, mBase).href + '"'; } catch(e) { return m; }
            });
          }
        }
        if (/javascript/i.test(ct) && body.indexOf("chunks/") !== -1) {
          try {
            var jsBase = new URL(targetUrl);
            if (PROXY_RE.test(jsBase.host)) {
              var jsBaseDir = jsBase.origin + jsBase.pathname.replace(/\/[^\/]*$/, "/");
              var proxyBase = scheme + "://" + workerHost + "/_/" + enc(jsBaseDir);
              body = body.replace(
                /,(\w+)\.p=\w+\}\)\(\)/,
                function(m, v) { return "," + v + '.p="' + proxyBase + '/"})()'; }
              );
            }
          } catch(e) {}
        }
        body = rewriteUrls(body, workerHost, scheme);
        respHeaders.delete("content-encoding");
        respHeaders.delete("content-length");
        respHeaders.set("cache-control", "public, max-age=3600");
        return new Response(body, { status: resp.status, headers: respHeaders });
      }

      return new Response(resp.body, { status: resp.status, headers: respHeaders });
    } catch (err) {
      return new Response(err.stack || err.message, { status: 500, headers: { "content-type": "text/plain" } });
    }
  }
};
