import axios, { AxiosResponse, Method } from 'axios';

export interface RedirectResult {
    chain: string[];     // every hop including the start
    finalUrl: string;    // last url inspected or resolved
    success: boolean;
    error?: string;
}

export interface RedirectResolverOptions {
    maxDepth?: number;          // defaults to 10
    timeoutMs?: number;         // per-hop timeout, defaults to 8000
    maxBodyBytes?: number;      // defaults to 512 * 1024
    userAgent?: string;         // default UA to include in the fallback ladder
}

const DEFAULT_OPTS: Required<RedirectResolverOptions> = {
    maxDepth: 10,
    timeoutMs: 8000,
    maxBodyBytes: 512 * 1024,
    userAgent: 'curl/8.4.0',
};

type UAOption = string | undefined;

export class RedirectResolver {
    private readonly opts: Required<RedirectResolverOptions>;

    constructor(options?: RedirectResolverOptions) {
        this.opts = { ...DEFAULT_OPTS, ...(options || {}) };
    }

    /**
     * Clean up any pending async operations
     * This is useful for test cleanup to prevent console logs after tests complete
     */
    async cleanup(): Promise<void> {
        // Wait for any pending operations to complete
        await new Promise(resolve => setImmediate(resolve));
    }

    async resolve(url: string, options?: Partial<RedirectResolverOptions>): Promise<RedirectResult> {
        const runtimeOpts = { ...this.opts, ...(options || {}) };

        const chain: string[] = [url];
        let currentUrl = url;
        let redirects = 0;

        try {
            while (redirects < runtimeOpts.maxDepth) {
                // User-Agent fallback ladder (deduped, in order):
                const uaCandidates = dedupeUA([
                    undefined,                              // no UA header at all
                    runtimeOpts.userAgent,                  // caller's preference (default: curl/8.4.0)
                    'curl/8.4.0',
                    'Mozilla/5.0',
                ]);

                let nextUrlFromAnyUA: string | null = null;

                for (const ua of uaCandidates) {
                    // 1) Try HEAD with this UA
                    const headResp = await this.requestOnce('HEAD', currentUrl, ua, runtimeOpts);
                    if (isRedirect(headResp)) {
                        nextUrlFromAnyUA = resolveLocation(headResp.headers.location!, currentUrl);
                        break;
                    }

                    // 2) Try GET with this UA (no auto-redirects, streamed)
                    const getResp = await this.requestOnce('GET', currentUrl, ua, runtimeOpts);
                    if (isRedirect(getResp)) {
                        nextUrlFromAnyUA = resolveLocation(getResp.headers.location!, currentUrl);
                        break;
                    }

                    // If we get here, this UA did not produce a redirect.

                    // Bail early if content-length is huge (treat as final to avoid heavy download).
                    const cl = headerInt(getResp.headers['content-length']);
                    if (cl !== null && cl > runtimeOpts.maxBodyBytes) {
                        return { chain, finalUrl: currentUrl, success: true };
                    }
                }

                if (nextUrlFromAnyUA) {
                    // Loop detection
                    if (chain.includes(nextUrlFromAnyUA)) {
                        return { chain, finalUrl: currentUrl, success: false, error: 'Redirect loop detected' };
                    }
                    chain.push(nextUrlFromAnyUA);
                    currentUrl = nextUrlFromAnyUA;
                    redirects++;
                    continue;
                }

                // None of the UA attempts yielded a redirect → we're at the final URL.
                // Whether it's 2xx/4xx/5xx doesn’t matter; curl -L stops without Location.
                return { chain, finalUrl: currentUrl, success: true };
            }

            return { chain, finalUrl: currentUrl, success: false, error: 'Maximum redirect depth exceeded' };
        } catch (e: any) {
            return { chain, finalUrl: currentUrl, success: false, error: e?.message || 'Unknown error' };
        }
    }

    // Single request without following redirects; HEAD or GET.
    private async requestOnce(
        method: Method,
        url: string,
        ua: UAOption,
        opts: Required<RedirectResolverOptions>,
    ): Promise<AxiosResponse<any>> {
        // We don’t need the body; for GET use a stream to avoid buffering.
        // We also avoid auto redirects to inspect Location manually.
        const headers: Record<string, string> = { Accept: '*/*' };
        if (ua) headers['User-Agent'] = ua;

        const isGet = method.toUpperCase() === 'GET';

        try {
            const resp = await axios.request({
                method,
                url,
                timeout: opts.timeoutMs,
                maxRedirects: 0,
                responseType: isGet ? 'stream' : 'json',
                // Security: avoid sending cookies/credentials
                withCredentials: false,
                headers,
                // Always allow manual status inspection
                validateStatus: () => true,
            });

            // For GET/stream, we don't read the stream; headers are enough to check Location.
            // Axios will keep the socket open briefly; caller quickly discards response object.
            try {
                if (isGet && resp.data?.destroy && typeof resp.data.destroy === 'function') {
                    // Proactively destroy stream to free resources
                    resp.data.destroy();
                }
            } catch {
                // ignore
            }

            return resp;
        } catch (err: any) {
            // Return a synthetic response-like object so caller can decide to try other UAs.
            return {
                status: 599,
                statusText: err?.message || 'Network error',
                headers: {},
                config: {},
                data: null,
                request: undefined,
            } as AxiosResponse<any>;
        }
    }
}

/* --------------- helpers --------------- */

function isRedirect(resp: AxiosResponse<any>): boolean {
    const s = resp.status;
    return s >= 300 && s < 400 && typeof resp.headers?.location === 'string' && resp.headers.location.length > 0;
}

function resolveLocation(location: string, base: string): string {
    return new URL(location, base).toString();
}

function headerInt(v: any): number | null {
    if (v == null) return null;
    const n = parseInt(String(v), 10);
    return Number.isFinite(n) ? n : null;
}

function dedupeUA(list: UAOption[]): UAOption[] {
    const seen = new Set<string>();
    const out: UAOption[] = [];
    for (const ua of list) {
        const key = ua ?? '<none>';
        if (!seen.has(key)) {
            seen.add(key);
            out.push(ua);
        }
    }
    return out;
}
