const RAW_URL = "https://raw.githubusercontent.com/lwhct/encode/refs/heads/main/encode/encode.bin"

export default {
    async fetch(request, env, ctx) {
        const response = await fetch(RAW_URL, {
            headers: {
                "user-agent": "Cloudflare-Worker-Subscription"
            },
            cf: {
                cacheTtl: 0,
                cacheEverything: false
            }
        });

        if (!response.ok) {
            return new Response("Subscription fetch failed", {
                status: 502,
                headers: {
                    "content-type": "text/plain; charset=utf-8",
                    "cache-control": "no-store"
                }
            });
        }

        let sub = await response.text();
        sub = sub.trim();

        return new Response(sub, {
            headers: {
                "content-type": "text/plain; charset=utf-8",
                "cache-control": "no-store"
            }
        });
    }
};
