import { CleanResult, CleanedUrl } from '../../types';
import { RedirectResolver } from '../RedirectResolver';

export class GenericStrategy {
    private redirectResolver: RedirectResolver;
    private readonly maxRedirectDepth = 10;
    private readonly redirectTimeoutMs = 8000;
    private readonly commonTrackingParams = [
        // Generic trackers
        'utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term',
        'fbclid', 'gclid', 'mc_eid', 'mc_cid', 'igshid', 'si', 'ref', 'ref_',
        'source', 'campaign', 'medium', 'content', 'term', 'affiliate',
        'partner', 'promo', 'discount', 'coupon', 'tracking', 'click_id',
        'clickid', 'click', 'link', 'redirect', 'goto', 'next', 'continue',
        'return', 'callback', 'success', 'error', 'status', 'result',
        'session', 'sessionid', 'sid', 'token', 'key', 'id', 'uid',
        'user', 'member', 'account', 'profile', 'settings', 'preferences',
        // Amazon / retailer specific
        'tag', 'ascsubtag', 'linkcode', 'creative', 'creativeasin', 'camp', 'smid', 'psc', 'qid', 'sr',
        'referrer', 'spm', 'scm'
    ];

    private readonly contentEssentialParams = [
        't', 'time', 'timestamp', 'start', 'end', 'duration', 'position',
        'page', 'offset', 'limit', 'size', 'width', 'height', 'quality',
        'format', 'type', 'lang', 'language', 'locale', 'region', 'country',
        'currency', 'price', 'amount', 'quantity', 'count', 'total',
        'sort', 'order', 'filter', 'search', 'query', 'q', 'term',
        'category', 'tag', 'label', 'name', 'title', 'description',
        'author', 'creator', 'publisher', 'date', 'year', 'month', 'day'
    ];

    constructor() {
        this.redirectResolver = new RedirectResolver();
    }

    async clean(url: string): Promise<CleanResult> {
        const actions: string[] = [];
        const t0 = Date.now();
        let processedUrl = url;
        let redirectMs = 0;
        console.log(`[Generic] START url=${url}`);

        try {
            // Step 0: Extract embedded destination URL from wrapper links (e.g., Google /url?q=...)
            const extracted = this.extractEmbeddedUrl(url);
            if (extracted && extracted !== url) {
                processedUrl = extracted;
                actions.push('Extracted destination URL from wrapper link');
                console.log(`[Generic] Extracted embedded destination: ${processedUrl}`);
            }

            // Step 1: Follow redirects
            const r0 = Date.now();
            const redirectResult = await this.redirectResolver.resolve(
                processedUrl,
                { maxDepth: this.maxRedirectDepth, timeoutMs: this.redirectTimeoutMs }
            );
            redirectMs = Date.now() - r0;
            console.log(`[Generic] Redirect resolve: success=${redirectResult.success} depth=${redirectResult.chain?.length || 0} finalUrl=${redirectResult.finalUrl || 'n/a'} error=${redirectResult.error || 'none'}`);
            if (redirectResult.success && redirectResult.chain.length > 0) {
                processedUrl = redirectResult.finalUrl || processedUrl;
                const hops = Math.max(0, redirectResult.chain.length - 1);
                actions.push(hops > 0 ? `Followed ${hops} redirects` : 'No redirects');
            } else {
                actions.push('Redirect resolution failed or incomplete');
            }

            // Step 2: Parse URL
            const urlObj = new URL(processedUrl);
            const originalParams = new Map(urlObj.searchParams);

            // Step 3: Remove common tracking parameters
            let removedCount = 0;
            const removedKeys: string[] = [];
            for (const [key] of urlObj.searchParams) {
                if (this.isTrackingParam(key)) {
                    urlObj.searchParams.delete(key);
                    removedCount++;
                    removedKeys.push(key);
                    console.log(`[Generic] Removed tracking param: ${key}`);
                }
            }

            if (removedCount > 0) {
                actions.push(`Removed ${removedCount} tracking parameters`);
                actions.push(`Removed tracking parameters: ${removedKeys.join(', ')}`);
            }

            // Step 4: Clean up empty parameters and normalize
            const before = urlObj.toString();
            this.normalizeUrl(urlObj);
            const after = urlObj.toString();
            if (before !== after) {
                console.log(`[Generic] Normalized URL before=${before} after=${after}`);
            }
            actions.push('Normalized URL structure');

            const cleanedUrl = urlObj.toString();

            // Calculate primary confidence first
            const primaryConfidence = this.calculateConfidence(cleanedUrl, originalParams);

            // Generate alternatives (include domain-only and parameter-free versions)
            const alternatives = this.generateAlternatives(url, cleanedUrl, originalParams, primaryConfidence);
            // Ensure a parameter-less canonical alternative exists
            const paramFree = new URL(cleanedUrl);
            paramFree.search = '';
            paramFree.hash = '';
            if (paramFree.toString() !== cleanedUrl && !alternatives.find(a => a.url === paramFree.toString())) {
                alternatives.push({
                    url: paramFree.toString(),
                    confidence: Math.min(1.0, primaryConfidence), // Cap to primary confidence
                    reason: 'Parameter-free canonical',
                    actions: ['Removed all parameters and fragments'],
                });
            }

            // Always include the original input URL among considered alternatives
            if (!alternatives.find(a => a.url === url) && url !== cleanedUrl) {
                alternatives.push({
                    url,
                    confidence: 0.55,
                    reason: 'Original input URL',
                    actions: ['Kept original input for reference'],
                });
            }

            // If redirect chain exists, add each hop as a low-confidence alternative (deduped)
            if (redirectResult?.chain?.length) {
                const seen = new Set(alternatives.map(a => a.url));
                for (const hop of redirectResult.chain) {
                    if (!seen.has(hop)) {
                        alternatives.push({
                            url: hop,
                            confidence: 0.5,
                            reason: 'Redirect hop considered',
                            actions: ['Observed during redirect resolution'],
                        });
                        console.log(`[Generic] Added redirect hop alternative: ${hop}`);
                        seen.add(hop);
                    }
                }
            }

            // Prefer parameter-free canonical as PRIMARY when safe:
            // if there are remaining params and ALL of them are non-essential, promote param-free.
            let primaryUrl = cleanedUrl;
            const remainingKeys = Array.from(new URL(cleanedUrl).searchParams.keys());
            const hasParams = remainingKeys.length > 0;
            const allNonEssential = hasParams && remainingKeys.every(k => !this.isContentEssential(k));
            if (allNonEssential) {
                primaryUrl = paramFree.toString();
                actions.push('Promoted parameter-free canonical to primary (non-essential params only)');
                // Ensure the with-params cleaned URL is present as an alternative
                if (!alternatives.find(a => a.url === cleanedUrl)) {
                    alternatives.push({
                        url: cleanedUrl,
                        confidence: primaryConfidence * 0.95,
                        reason: 'With non-essential parameters',
                        actions: ['Kept cleaned URL with non-essential params as fallback'],
                    });
                    console.log(`[Generic] Promoted param-free canonical. With-params kept as alternative.`);
                }
            }

            // Cap all alternatives to not exceed primary confidence
            const finalPrimaryConfidence = this.calculateConfidence(primaryUrl, originalParams);
            const cappedAlternatives = alternatives.map(alt => ({
                ...alt,
                confidence: Math.min(alt.confidence || 0, finalPrimaryConfidence)
            }));

            const result = {
                primary: {
                    url: primaryUrl,
                    confidence: finalPrimaryConfidence,
                    actions,
                    redirectionChain: redirectResult?.chain?.length ? redirectResult.chain : undefined,
                },
                alternatives: cappedAlternatives,
                meta: {
                    domain: urlObj.hostname,
                    strategyId: 'generic',
                    strategyVersion: '1.1.0',
                    timing: {
                        totalMs: Date.now() - t0,
                        redirectMs,
                        processingMs: (Date.now() - t0) - redirectMs,
                    },
                    appliedAt: new Date().toISOString(),
                },
            };
            console.log(`[Generic] END primary=${result.primary.url} confidence=${result.primary.confidence} alternatives=${result.alternatives.length}`);
            return result;
        } catch (error) {
            // Return original URL if processing fails
            console.error(`[Generic] ERROR: ${String((error as any)?.message || error)}`);
            return {
                primary: {
                    url,
                    confidence: 0.1,
                    actions: ['Processing failed, returned original URL'],
                },
                alternatives: [],
                meta: {
                    domain: new URL(url).hostname,
                    strategyId: 'generic-error',
                    strategyVersion: '1.1.0',
                    timing: {
                        totalMs: 0,
                        redirectMs: 0,
                        processingMs: 0,
                    },
                    appliedAt: new Date().toISOString(),
                },
            };
        }
    }

    // Extract embedded destination URL from common wrapper parameters
    private extractEmbeddedUrl(inputUrl: string): string | null {
        try {
            const urlObj = new URL(inputUrl);
            const candidates = ['q', 'url', 'u', 'redirect', 'target', 'r', 'dest', 'destination', 'to', 'next', 'continue', 'link'];

            // Google specific: /url path often uses 'q' or 'url'
            if (urlObj.pathname === '/url' || urlObj.pathname.startsWith('/url/')) {
                const q = urlObj.searchParams.get('q');
                const u = urlObj.searchParams.get('url') || urlObj.searchParams.get('u');
                const first = q || u;
                const extracted = this.decodeIfUrl(first);
                if (extracted) return extracted;
            }

            for (const key of candidates) {
                const value = urlObj.searchParams.get(key);
                const extracted = this.decodeIfUrl(value);
                if (extracted) return extracted;
            }
        } catch {
            // ignore
        }
        return null;
    }

    private decodeIfUrl(value: string | null): string | null {
        if (!value) return null;
        const tryDecode = (v: string): string => {
            try { return decodeURIComponent(v); } catch { return v; }
        };

        let candidate = value.trim();
        // Decode repeatedly up to 3 times to handle nested encodings
        for (let i = 0; i < 3; i++) {
            const decoded = tryDecode(candidate);
            if (decoded === candidate) break;
            candidate = decoded;
        }

        if (this.isHttpUrl(candidate)) return candidate;
        // Remove angle brackets if present
        const stripped = candidate.replace(/^<(.+)>$/, '$1');
        if (this.isHttpUrl(stripped)) return stripped;
        return null;
    }

    private isHttpUrl(text: string): boolean {
        try {
            const u = new URL(text);
            return (u.protocol === 'http:' || u.protocol === 'https:') && !!u.hostname;
        } catch {
            return false;
        }
    }

    private isTrackingParam(paramName: string): boolean {
        const lowerParam = paramName.toLowerCase();

        // Check against common tracking parameters
        if (this.commonTrackingParams.includes(lowerParam)) {
            return true;
        }

        // Check for UTM parameters
        if (lowerParam.startsWith('utm_')) {
            return true;
        }

        // Check for common tracking patterns
        const trackingPatterns = [
            /^utm_/,
            /^fbclid$/,
            /^gclid$/,
            /^mc_eid$/,
            /^mc_cid$/,
            /^igshid$/,
            /^si$/,
            /^ref_/,            // e.g., Amazon ref_
            /^pf_rd_/,          // Amazon referral detail
            /^ascsubtag$/,      // Amazon affiliate subtag
            /^linkcode$/,       // Amazon link code
            /^creative(?:asin)?$/, // Amazon creative/creativeASIN
            /^camp$/,           // Amazon campaign
            /^smid$/, /^psc$/, /^qid$/, /^sr$/, // Amazon misc
            /_id$/,
            /_token$/,
            /_key$/,
            /_session$/,
            /_tracking$/,
            /_click$/,
            /_ref$/,
            /_source$/,
            /_campaign$/,
            /_medium$/,
            /_content$/,
            /_term$/,
        ];

        return trackingPatterns.some(pattern => pattern.test(lowerParam));
    }

    private isContentEssential(paramName: string): boolean {
        const lowerParam = paramName.toLowerCase();
        return this.contentEssentialParams.includes(lowerParam);
    }

    private normalizeUrl(urlObj: URL): void {
        // Remove empty parameters
        for (const [key, value] of urlObj.searchParams) {
            if (!value || value.trim() === '') {
                urlObj.searchParams.delete(key);
            }
        }

        // Sort parameters for consistency
        const sortedParams = new URLSearchParams();
        const paramKeys = Array.from(urlObj.searchParams.keys()).sort();
        for (const key of paramKeys) {
            sortedParams.set(key, urlObj.searchParams.get(key)!);
        }
        urlObj.search = sortedParams.toString();

        // Remove trailing slash from path (except for root)
        if (urlObj.pathname.length > 1 && urlObj.pathname.endsWith('/')) {
            urlObj.pathname = urlObj.pathname.slice(0, -1);
        }
    }

    private generateAlternatives(_originalUrl: string, cleanedUrl: string, originalParams: Map<string, string>, maxConfidence: number = 1.0): CleanedUrl[] {
        const alternatives: CleanedUrl[] = [];
        // Generic strategy never re-introduces trackers.

        // Alternative 1: Keep essential parameters
        const essentialAlternative = new URL(cleanedUrl);
        let essentialCount = 0;

        for (const [key, value] of originalParams) {
            if (this.isContentEssential(key) && !essentialAlternative.searchParams.has(key)) {
                essentialAlternative.searchParams.set(key, value);
                essentialCount++;
            }
        }

        if (essentialCount > 0) {
            alternatives.push({
                url: essentialAlternative.toString(),
                confidence: Math.min(0.8, maxConfidence),
                reason: `Kept ${essentialCount} content-essential parameters`,
                actions: ['Preserved essential parameters'],
            });
        }

        // We intentionally skip a "keep tracker-ish params" variant for generic.
        // Generic must never suggest a tracker-containing URL.

        // Alternative 2: Domain-only version (highest confidence)
        const domainOnly = new URL(cleanedUrl);
        domainOnly.search = '';
        domainOnly.hash = '';

        if (domainOnly.toString() !== cleanedUrl) {
            alternatives.push({
                url: domainOnly.toString(),
                confidence: Math.min(1.0, maxConfidence), // Cap to max confidence
                reason: 'Domain-only version - removed all parameters',
                actions: ['Removed all parameters and fragments'],
            });
        }

        // Sort alternatives by confidence (highest first) to rank cleaner URLs higher
        return alternatives.sort((a, b) => b.confidence - a.confidence);
    }

    private calculateConfidence(cleanedUrl: string, originalParams: Map<string, string>): number {
        const cleanedUrlObj = new URL(cleanedUrl);
        const remainingParams = cleanedUrlObj.searchParams.size;
        const originalParamCount = originalParams.size;

        // Check if this is a root domain URL (no path beyond / and no query params)
        const isRootDomain = cleanedUrlObj.pathname === '/' && remainingParams === 0;

        if (isRootDomain) {
            return 1.0; // 100% confidence for root domain without trackers
        }

        if (originalParamCount === 0) {
            return 1.0; // Perfect if no parameters to begin with
        }

        // Higher confidence for URLs without trackers (no remaining parameters)
        if (remainingParams === 0) {
            return 0.95; // Very high confidence if all parameters removed
        }

        // Calculate confidence based on how many tracking parameters were removed
        const removalRatio = (originalParamCount - remainingParams) / originalParamCount;
        let confidence = 0.5 + (removalRatio * 0.4); // Scale confidence based on removal ratio

        // Boost confidence if we removed many tracking parameters
        if (removalRatio > 0.7) {
            confidence += 0.1;
        }

        return Math.min(1.0, Math.max(0.0, confidence));
    }
}
