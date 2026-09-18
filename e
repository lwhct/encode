var USER = "lwhct";
var REPO = "encode";
var BRANCH = "main";
var DIR = "encode";

var V2RAYN_REPO = "2dust/v2rayN";
var V2RAYNG_REPO = "2dust/v2rayNG";

async function getLatestRelease(repo, assetFilter) {
  var resp = await fetch("https://api.github.com/repos/" + repo + "/releases/latest", {
    headers: { "user-agent": "Cloudflare-Worker" }
  });
  if (!resp.ok) return null;
  var data = await resp.json();
  var asset = data.assets.find(assetFilter);
  return asset ? asset.browser_download_url : null;
}

function isMobile(ua) {
  return /android|mobile|phone/i.test(ua || "");
}


export default {
  async fetch(request, env, ctx) {
    var url = new URL(request.url);
    var name = url.pathname.replace(/^\/+|\/+$/g, "");
    var ua = request.headers.get("user-agent") || "";

    if (!name) {
      var rawUrl = ["https://raw.githubusercontent.com", USER, REPO, BRANCH, DIR, "encode.bin"].join("/");
      var response = await fetch(rawUrl, { headers: { "user-agent": "Cloudflare-Worker-Subscription" } });
      if (!response.ok) {
        return new Response("Subscription not found", { status: 404, headers: { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" } });
      }
      var sub = (await response.text()).trim();
      return new Response(sub, { headers: { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" } });
    }

    if (name === "bin" || name === "bin32") {
      var want32 = name === "bin32";
      var mobile = isMobile(ua);
      var downloadUrl;
      if (mobile) {
        downloadUrl = await getLatestRelease(V2RAYNG_REPO, function(a) {
          if (want32) return /v2rayNG_[^_]+_armeabi-v7a\.apk$/i.test(a.name);
          return /v2rayNG_[^_]+_arm64-v8a\.apk$/i.test(a.name);
        });
      } else {
        downloadUrl = await getLatestRelease(V2RAYN_REPO, function(a) {
          if (want32) return /^v2rayN-windows-86-desktop\.zip$/i.test(a.name);
          return /^v2rayN-windows-64-desktop\.zip$/i.test(a.name);
        });
      }
      if (!downloadUrl) return new Response("Release not found", { status: 404 });
      var dlResp = await fetch(downloadUrl, { headers: { "user-agent": "Cloudflare-Worker" }, redirect: "follow" });
      if (!dlResp.ok) return new Response("Download failed", { status: 502 });
      var filename = downloadUrl.split("/").pop();
      var dlHeaders = new Headers(dlResp.headers);
      dlHeaders.set("content-disposition", 'attachment; filename="' + filename + '"');
      dlHeaders.set("cache-control", "no-store");
      return new Response(dlResp.body, { headers: dlHeaders });
    }

    if (name === "mas") {
      var masUrl = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/refs/heads/master/MAS/All-In-One-Version-KL/MAS_AIO.cmd";
      var resp = await fetch(masUrl, { headers: { "user-agent": "Cloudflare-Worker" } });
      if (!resp.ok) return new Response("File not found", { status: 404 });
      return new Response(resp.body, {
        headers: {
          "content-type": "application/octet-stream",
          "content-disposition": 'attachment; filename="MAS_AIO.cmd"',
          "cache-control": "no-store"
        }
      });
    }

    if (!/^[A-Za-z0-9_-]+$/.test(name)) {
      return new Response("Not Found", { status: 404, headers: { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" } });
    }

    var rawUrl = ["https://raw.githubusercontent.com", USER, REPO, BRANCH, DIR, "encode." + name].join("/");
    var response = await fetch(rawUrl, { headers: { "user-agent": "Cloudflare-Worker-Subscription" } });
    if (!response.ok) {
      return new Response("Subscription not found", { status: 404, headers: { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" } });
    }
    var sub = (await response.text()).trim();
    return new Response(sub, { headers: { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" } });
  }
};
