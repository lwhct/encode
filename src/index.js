var USER = "lwhct";
var REPO = "encode";
var BRANCH = "main";
var DIR = "encode";

async function getLatestTag(repo) {
  var resp = await fetch("https://github.com/" + repo + "/releases/latest", {
    headers: { "user-agent": "Cloudflare-Worker" },
    redirect: "manual"
  });
  var loc = resp.headers.get("location");
  if (loc) return loc.split("/").pop();
  return null;
}

function isMobile(ua) {
  return /android|mobile|phone/i.test(ua || "");
}

export default {
  async fetch(request, env, ctx) {
    var url = new URL(request.url);
    var path = url.pathname.replace(/^\/+/, "").replace(/\/+$/, "");
    var ua = request.headers.get("user-agent") || "";

    if (path.substring(0, 4) === "http") {
      var dlUrl = path + url.search;
      try { new URL(dlUrl); } catch (e) {
        return new Response("Invalid URL", { status: 400 });
      }
      var dlResp = await fetch(dlUrl, { headers: { "user-agent": ua || "Cloudflare-Worker" }, redirect: "follow" });
      if (!dlResp.ok) return new Response("Download failed: " + dlResp.status, { status: 502 });
      var filename = dlUrl.split("/").pop().split("?")[0] || "download";
      var dlHeaders = new Headers(dlResp.headers);
      dlHeaders.set("content-disposition", 'attachment; filename="' + filename + '"');
      dlHeaders.set("cache-control", "no-store");
      dlHeaders.delete("content-security-policy");
      return new Response(dlResp.body, { headers: dlHeaders });
    }

    var name = path;

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
        var tag = await getLatestTag("2dust/v2rayNG");
        if (!tag) return new Response("Failed to get latest version", { status: 502 });
        var arch = want32 ? "armeabi-v7a" : "arm64-v8a";
        downloadUrl = "https://github.com/2dust/v2rayNG/releases/download/" + tag + "/v2rayNG_" + tag + "_" + arch + ".apk";
      } else {
        var tag = await getLatestTag("2dust/v2rayN");
        if (!tag) return new Response("Failed to get latest version", { status: 502 });
        var variant = want32 ? "v2rayN-windows-86-desktop.zip" : "v2rayN-windows-64-desktop.zip";
        downloadUrl = "https://github.com/2dust/v2rayN/releases/download/" + tag + "/" + variant;
      }
      var dlResp = await fetch(downloadUrl, { headers: { "user-agent": "Cloudflare-Worker" }, redirect: "follow" });
      if (!dlResp.ok) return new Response("Download failed: " + dlResp.status, { status: 502 });
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
