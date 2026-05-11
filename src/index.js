throw new Error("BUILD_CHECK_20260511");

const RAW_URL = 'https://raw.githubusercontent.com/lwhct/encode/main/encode/encode.bin';

export default {
    async fetch(request, env, ctx) {
        const response = await fetch(RAW_URL);
        const sub = (await response.text()).trim();

        return new Response(sub, {
            headers: {
                'content-type': 'text/plain; charset=utf-8',
                'cache-control': 'no-store'
            }
        });
    }
};
