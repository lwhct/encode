const RAW_URL = 'https://raw.githubusercontent.com/lwhct/encode/main/encode/encode.bin';

export default {
    async fetch(request, env, ctx) {
        const response = await fetch(RAW_URL, {
            headers: {
                'user-agent': 'Cloudflare-Worker-Subscription'
            }
        });

        if (!response.ok) {
            return new Response('Subscription fetch failed', {
                status: 502,
                headers: {
                    'content-type': 'text/plain; charset=utf-8',
                    'cache-control': 'no-store'
                }
            });
        }

        const sub = (await response.text()).trim();

        return new Response(sub, {
            headers: {
                'content-type': 'text/plain; charset=utf-8',
                'cache-control': 'no-store'
            }
        });
    }
};
