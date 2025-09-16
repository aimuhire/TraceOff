import axios, { AxiosResponse, Method } from 'axios';
import { load as loadHtml } from 'cheerio';

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

                    // Only for known interstitial hosts (e.g., LinkedIn), inspect small HTML snippet
                    // to extract the intended external destination. Avoid doing this for arbitrary hosts
                    // to prevent accidentally following asset links (e.g., fonts, images, svgs).
                    const ct = String((getResp.headers as any)['content-type'] || '');
                    const snippet = (getResp as any).bodySnippet as string | undefined;
                    const currentHost = (() => { try { return new URL(currentUrl).hostname.toLowerCase(); } catch { return ''; } })();
                    if (snippet && _isLikelyHtml(ct) && isLinkedInHost(currentHost)) {
                        const found = extractExternalUrlFromHtml(snippet) || extractUrlFromText(snippet);
                        if (found) {
                            nextUrlFromAnyUA = resolveLocation(found, currentUrl);
                            break;
                        }
                    }

                    // (Intentionally no Pinterest-specific HTML parsing here; path rules handle normalization)

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
        } catch (e: unknown) {
            const errorMessage = e instanceof Error ? e.message : 'Unknown error';
            return { chain, finalUrl: currentUrl, success: false, error: errorMessage };
        }
    }

    // Single request without following redirects; HEAD or GET.
    private async requestOnce(
        method: Method,
        url: string,
        ua: UAOption,
        opts: Required<RedirectResolverOptions>,
    ): Promise<AxiosResponse<unknown>> {
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

            // For GET/stream, capture a small snippet so we can parse HTML-based redirects
            // like LinkedIn interstitial pages. Keep it bounded by maxBodyBytes, then destroy stream.
            if (isGet && resp.data && typeof (resp.data as any).on === 'function') {
                await new Promise<void>((resolve) => {
                    try {
                        const stream: any = resp.data;
                        const chunks: Buffer[] = [];
                        let received = 0;
                        const maxBytes = opts.maxBodyBytes;

                        const onData = (chunk: Buffer) => {
                            if (!Buffer.isBuffer(chunk)) chunk = Buffer.from(String(chunk));
                            const remaining = Math.max(0, maxBytes - received);
                            if (remaining > 0) {
                                const toPush = chunk.length > remaining ? chunk.subarray(0, remaining) : chunk;
                                chunks.push(toPush);
                                received += toPush.length;
                            }
                            if (received >= maxBytes) {
                                cleanup();
                            }
                        };

                        const onEnd = () => cleanup();
                        const onError = () => cleanup();

                        const cleanup = () => {
                            try { stream.off('data', onData); } catch { /* ignore: best-effort detach */ }
                            try { stream.off('end', onEnd); } catch { /* ignore: best-effort detach */ }
                            try { stream.off('error', onError); } catch { /* ignore: best-effort detach */ }
                            try { if (typeof stream.destroy === 'function') stream.destroy(); } catch { /* ignore: best-effort destroy */ }
                            try { (resp as any).bodySnippet = Buffer.concat(chunks).toString('utf8'); } catch { /* ignore: best-effort capture */ }
                            resolve();
                        };

                        stream.on('data', onData);
                        stream.on('end', onEnd);
                        stream.on('error', onError);
                    } catch {
                        // Best-effort; ensure resolution
                        try { if (resp.data?.destroy) resp.data.destroy(); } catch { /* ignore: destroy may fail */ }
                        resolve();
                    }
                });
            } else {
                // Non-stream case or no data; nothing to capture
            }

            return resp;
        } catch (err: unknown) {
            // Return a synthetic response-like object so caller can decide to try other UAs.
            const errorMessage = err instanceof Error ? err.message : 'Network error';
            return {
                status: 599,
                statusText: errorMessage,
                headers: {},
                config: {},
                data: null,
                request: undefined,
            } as AxiosResponse<unknown>;
        }
    }
}

/* --------------- helpers --------------- */

function isRedirect(resp: AxiosResponse<unknown>): boolean {
    const s = resp.status;
    return s >= 300 && s < 400 && typeof resp.headers?.location === 'string' && resp.headers.location.length > 0;
}

function resolveLocation(location: string, base: string): string {
    return new URL(location, base).toString();
}

function headerInt(v: unknown): number | null {
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

// Heuristics
function _isLikelyHtml(contentType: string): boolean {
    const ct = contentType.toLowerCase();
    return ct.includes('text/html') || ct.includes('application/xhtml');
}

// Extract first external href from HTML (skip LinkedIn/lnkd.in domains) using a DOM parser for reliability
function extractExternalUrlFromHtml(html: string): string | null {
    try {
        const $ = loadHtml(html);
        // Prefer LinkedIn interstitial button selector if present
        const preferred = $('a[data-tracking-control-name="external_url_click"][href]')
            .map((_, el) => ($(el).attr('href') || '').trim())
            .get();
        const anchors = preferred.length > 0
            ? preferred
            : $('a[href]')
                .map((_, el) => ($(el).attr('href') || '').trim())
                .get();

        for (const href of anchors) {
            if (!href) continue;
            try {
                const u = new URL(href);
                const host = u.hostname.toLowerCase();
                if (!isLinkedInHost(host)) return href;
            } catch {
                // skip invalid
            }
        }

        // As a last resort, scan visible text nodes for absolute URLs
        const text = $('body').text();
        const fromText = extractUrlFromText(text);
        if (fromText) return fromText;
    } catch {
        // ignore parser failures
    }
    return null;
}

function isLinkedInHost(host: string): boolean {
    return host === 'lnkd.in' || host === 'linkedin.com' || host.endsWith('.linkedin.com');
}

// Note: no Pinterest-specific parsing required; keep resolver generic

// Plain text URL extraction (fallback)
function extractUrlFromText(text?: string): string | null {
    if (!text) return null;
    const re = /(https?:\/\/[^\s"'<>]+)/gim;
    let m: RegExpExecArray | null;
    while ((m = re.exec(text))) {
        const candidate = m[1];
        try {
            const host = new URL(candidate).hostname.toLowerCase();
            if (!isLinkedInHost(host)) return candidate;
        } catch {
            // ignore
        }
    }
    return null;
}

// (No site-specific HTML canonical extraction to keep resolver generic)
