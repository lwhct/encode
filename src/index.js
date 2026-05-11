const USER = 'lwhct';
const REPO = 'encode';
const BRANCH = 'main';
const DIR = 'encode';

export default {
    async fetch(request, env, ctx) {
        const url = new URL(request.url);
        let name = url.pathname.replace(/^\/+|\/+$/g, '');

        if (!name) {
            name = 'bin';
        }

        if (!/^[A-Za-z0-9_-]+$/.test(name)) {
            return new Response('Not Found', {
                status: 404,
                headers: {
                    'content-type': 'text/plain; charset=utf-8',
                    'cache-control': 'no-store'
                }
            });
        }

        const rawUrl = [
            'https://raw.githubusercontent.com',
            USER,
            REPO,
            BRANCH,
            DIR,
            `encode.${name}`
        ].join('/');

        const response = await fetch(rawUrl, {
            headers: {
                'user-agent': 'Cloudflare-Worker-Subscription'
            }
        });

        if (!response.ok) {
            return new Response('Subscription not found', {
                status: 404,
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
