import { Strategy, CleanResult, CleanedUrl, TimingMetrics } from '../types';
import { UrlProcessor } from './UrlProcessor';
import { RedirectResolver } from './RedirectResolver';
import { GenericStrategy } from './strategies/GenericStrategy';

export class StrategyEngine {
    private strategies: Map<string, Strategy> = new Map();
    private urlProcessor: UrlProcessor;
    private redirectResolver: RedirectResolver;
    private genericStrategy: GenericStrategy;

    constructor() {
        this.urlProcessor = new UrlProcessor();
        this.redirectResolver = new RedirectResolver();
        this.genericStrategy = new GenericStrategy();
    }

    /**
     * Clean up any pending async operations
     * This is useful for test cleanup to prevent console logs after tests complete
     */
    async cleanup(): Promise<void> {
        // Wait for any pending operations to complete
        await new Promise(resolve => setImmediate(resolve));

        // Clean up redirect resolver
        if (this.redirectResolver && typeof this.redirectResolver.cleanup === 'function') {
            await this.redirectResolver.cleanup();
        }

        // Clean up generic strategy
        if (this.genericStrategy && typeof this.genericStrategy.cleanup === 'function') {
            await this.genericStrategy.cleanup();
        }
    }

    private ensureOriginalAlternative(result: CleanResult, originalUrl: string): CleanResult {
        try {
            // Ensure original URL is included in results
            if (result.primary.url !== originalUrl && !result.alternatives.find(a => a.url === originalUrl)) {
                result.alternatives.push({
                    url: originalUrl,
                    confidence: 0.7,
                    actions: ['Kept original input'],
                    reason: 'Original input URL',
                });
            }
        } catch {
            // ignore
        }
        return result;
    }

    private promoteHighestConfidence(result: CleanResult): CleanResult {
        try {
            const candidates = [result.primary, ...result.alternatives];
            candidates.sort((a, b) => (b.confidence || 0) - (a.confidence || 0));
            const newPrimary = candidates[0];
            const newAlternatives = candidates.slice(1);

            // Ensure alternatives never have higher confidence than primary
            const cappedAlternatives = newAlternatives.map(alt => ({
                ...alt,
                confidence: Math.min(alt.confidence || 0, newPrimary.confidence || 0)
            }));

            return {
                primary: newPrimary,
                alternatives: cappedAlternatives,
                meta: result.meta,
            };
        } catch {
            return result;
        }
    }

    addStrategy(strategy: Strategy): void {
        this.strategies.set(strategy.id, strategy);
    }

    removeStrategy(strategyId: string): void {
        this.strategies.delete(strategyId);
    }

    getStrategy(strategyId: string): Strategy | undefined {
        return this.strategies.get(strategyId);
    }

    getAllStrategies(): Strategy[] {
        return Array.from(this.strategies.values()).sort((a, b) => b.priority - a.priority);
    }

    async cleanUrl(url: string, strategyId?: string): Promise<CleanResult> {
        const startTime = Date.now();
        const urlObj = new URL(url);
        const domain = urlObj.hostname;

        let strategy: Strategy | undefined;
        let timing: TimingMetrics;

        if (strategyId) {
            strategy = this.getStrategy(strategyId);
            console.log(`[Engine] Strategy requested: id=${strategyId} found=${!!strategy}`);
        } else {
            strategy = this.findMatchingStrategy(domain);
            console.log(`[Engine] Strategy matched by domain: domain=${domain} id=${strategy?.id || 'none'}`);
        }

        if (!strategy || !strategy.enabled) {
            // Fallback path: follow redirects up to 5 and re-evaluate against strategies
            try {
                const redirectStart = Date.now();
                const redirectResult = await this.redirectResolver.resolve(url);
                const redirectMsLocal = Date.now() - redirectStart;
                console.log(`[Engine] Fallback redirect resolve: success=${redirectResult.success} finalUrl=${redirectResult.finalUrl || 'n/a'} depth=${redirectResult.chain?.length || 0} error=${redirectResult.error || 'none'}`);

                const chain = redirectResult.chain && redirectResult.chain.length > 0
                    ? redirectResult.chain
                    : [url];

                for (const candidateUrl of chain) {
                    try {
                        const cUrl = new URL(candidateUrl);
                        const cDomain = cUrl.hostname;
                        const matched = this.findMatchingStrategy(cDomain);
                        console.log(`[Engine] Fallback chain candidate: ${candidateUrl} -> matched=${matched?.id || 'none'}`);
                        if (matched && matched.enabled) {
                            const processed = await this.processWithStrategy(candidateUrl, matched);
                            timing = {
                                totalMs: Date.now() - startTime,
                                redirectMs: (processed.redirectMs || 0) + redirectMsLocal,
                                processingMs: (Date.now() - startTime) - ((processed.redirectMs || 0) + redirectMsLocal),
                            };
                            return this.promoteHighestConfidence(this.ensureOriginalAlternative({
                                primary: processed.primary,
                                alternatives: processed.alternatives,
                                meta: {
                                    domain: cDomain,
                                    strategyId: matched.id,
                                    strategyVersion: matched.version,
                                    timing,
                                    appliedAt: new Date().toISOString(),
                                },
                            }, url));
                        }
                    } catch {
                        // ignore bad candidate
                    }
                }

                // If none matched, prefer using the final observed URL even on error
                const targetUrl = redirectResult.finalUrl || url;
                if (!redirectResult.success) {
                    timing = {
                        totalMs: Date.now() - startTime,
                        redirectMs: redirectMsLocal,
                        processingMs: (Date.now() - startTime) - redirectMsLocal,
                    };
                    console.warn(`[Engine] Redirect tracing error: error=${redirectResult.error || 'unknown'} using targetUrl=${targetUrl}`);
                    // Even on redirect error, run generic cleaning on the final observed URL
                    const genericPartial = await this.genericStrategy.clean(targetUrl);
                    // Ensure we attach the observed chain to primary
                    genericPartial.primary.redirectionChain = chain;
                    genericPartial.primary.actions = [
                        ...(genericPartial.primary.actions || []),
                        chain.length > 1 ? `Followed ${chain.length - 1} redirects (partial)` : 'No redirects',
                        `Redirect tracing error: ${redirectResult.error || 'unknown'}`,
                    ];
                    return {
                        primary: genericPartial.primary,
                        alternatives: genericPartial.alternatives,
                        meta: {
                            domain: new URL(targetUrl).hostname,
                            strategyId: 'generic-partial',
                            strategyVersion: '1.0.0',
                            timing,
                            appliedAt: new Date().toISOString(),
                        },
                    };
                }

                const genericResult = await this.genericStrategy.clean(targetUrl);
                console.log(`[Engine] Fallback generic applied on ${targetUrl}`);
                timing = {
                    totalMs: Date.now() - startTime,
                    redirectMs: redirectMsLocal,
                    processingMs: (Date.now() - startTime) - redirectMsLocal,
                };
                return this.promoteHighestConfidence(this.ensureOriginalAlternative({
                    primary: genericResult.primary,
                    alternatives: genericResult.alternatives,
                    meta: {
                        domain: new URL(targetUrl).hostname,
                        strategyId: 'generic',
                        strategyVersion: '1.0.0',
                        timing,
                        appliedAt: new Date().toISOString(),
                    },
                }, url));
            } catch {
                // As a last resort, use generic strategy on original URL
                const genericResult = await this.genericStrategy.clean(url);
                timing = {
                    totalMs: Date.now() - startTime,
                    redirectMs: 0,
                    processingMs: Date.now() - startTime,
                };
                return this.ensureOriginalAlternative({
                    primary: genericResult.primary,
                    alternatives: genericResult.alternatives,
                    meta: {
                        domain,
                        strategyId: 'generic',
                        strategyVersion: '1.0.0',
                        timing,
                        appliedAt: new Date().toISOString(),
                    },
                }, url);
            }
        }

        try {
            const result = await this.processWithStrategy(url, strategy);
            timing = {
                totalMs: Date.now() - startTime,
                redirectMs: result.redirectMs || 0,
                processingMs: (Date.now() - startTime) - (result.redirectMs || 0),
            };

            return this.promoteHighestConfidence(this.ensureOriginalAlternative({
                primary: result.primary,
                alternatives: result.alternatives,
                meta: {
                    domain,
                    strategyId: strategy.id,
                    strategyVersion: strategy.version,
                    timing,
                    appliedAt: new Date().toISOString(),
                },
            }, url));
        } catch (error) {
            console.error(`[Engine] Error processing with strategy id=${strategy?.id}: ${String((error as any)?.message || error)}`);
            // On error, attempt the same redirect-based re-evaluation as the fallback
            try {
                const redirectStart = Date.now();
                const redirectResult = await this.redirectResolver.resolve(url);
                const redirectMsLocal = Date.now() - redirectStart;
                console.log(`[Engine] Error-path redirect resolve: success=${redirectResult.success} finalUrl=${redirectResult.finalUrl || 'n/a'} depth=${redirectResult.chain?.length || 0} error=${redirectResult.error || 'none'}`);
                const chain = redirectResult.chain && redirectResult.chain.length > 0
                    ? redirectResult.chain
                    : [url];
                for (const candidateUrl of chain) {
                    try {
                        const cUrl = new URL(candidateUrl);
                        const cDomain = cUrl.hostname;
                        const matched = this.findMatchingStrategy(cDomain);
                        console.log(`[Engine] Error-path chain candidate: ${candidateUrl} -> matched=${matched?.id || 'none'}`);
                        if (matched && matched.enabled) {
                            const processed = await this.processWithStrategy(candidateUrl, matched);
                            timing = {
                                totalMs: Date.now() - startTime,
                                redirectMs: (processed.redirectMs || 0) + redirectMsLocal,
                                processingMs: (Date.now() - startTime) - ((processed.redirectMs || 0) + redirectMsLocal),
                            };
                            return this.promoteHighestConfidence(this.ensureOriginalAlternative({
                                primary: processed.primary,
                                alternatives: processed.alternatives,
                                meta: {
                                    domain: cDomain,
                                    strategyId: matched.id,
                                    strategyVersion: matched.version,
                                    timing,
                                    appliedAt: new Date().toISOString(),
                                },
                            }, url));
                        }
                    } catch {
                        // ignore
                    }
                }
                const targetUrl = redirectResult.finalUrl || url;
                if (!redirectResult.success) {
                    timing = {
                        totalMs: Date.now() - startTime,
                        redirectMs: redirectMsLocal,
                        processingMs: (Date.now() - startTime) - redirectMsLocal,
                    };
                    console.warn(`[Engine] Error-path redirect tracing error: error=${redirectResult.error || 'unknown'} using targetUrl=${targetUrl}`);
                    const genericPartial = await this.genericStrategy.clean(targetUrl);
                    genericPartial.primary.redirectionChain = chain;
                    genericPartial.primary.actions = [
                        ...(genericPartial.primary.actions || []),
                        chain.length > 1 ? `Followed ${chain.length - 1} redirects (partial)` : 'No redirects',
                        `Redirect tracing error: ${redirectResult.error || 'unknown'}`,
                    ];
                    return {
                        primary: genericPartial.primary,
                        alternatives: genericPartial.alternatives,
                        meta: {
                            domain: new URL(targetUrl).hostname,
                            strategyId: 'generic-fallback-partial',
                            strategyVersion: '1.0.0',
                            timing,
                            appliedAt: new Date().toISOString(),
                        },
                    };
                }

                const genericResult = await this.genericStrategy.clean(targetUrl);
                console.log(`[Engine] Error-path generic applied on ${targetUrl}`);
                timing = {
                    totalMs: Date.now() - startTime,
                    redirectMs: redirectMsLocal,
                    processingMs: (Date.now() - startTime) - redirectMsLocal,
                };
                return this.promoteHighestConfidence(this.ensureOriginalAlternative({
                    primary: genericResult.primary,
                    alternatives: genericResult.alternatives,
                    meta: {
                        domain: new URL(targetUrl).hostname,
                        strategyId: 'generic-fallback',
                        strategyVersion: '1.0.0',
                        timing,
                        appliedAt: new Date().toISOString(),
                    },
                }, url));
            } catch {
                const genericResult = await this.genericStrategy.clean(url);
                timing = {
                    totalMs: Date.now() - startTime,
                    redirectMs: 0,
                    processingMs: Date.now() - startTime,
                };
                console.warn('[Engine] Falling back to generic without redirects due to error');
                return this.promoteHighestConfidence(this.ensureOriginalAlternative({
                    primary: genericResult.primary,
                    alternatives: genericResult.alternatives,
                    meta: {
                        domain,
                        strategyId: 'generic-fallback',
                        strategyVersion: '1.0.0',
                        timing,
                        appliedAt: new Date().toISOString(),
                    },
                }, url));
            }
        }
    }

    private findMatchingStrategy(domain: string): Strategy | undefined {
        const strategies = this.getAllStrategies();

        for (const strategy of strategies) {
            if (this.matchesDomain(domain, strategy.matchers)) {
                return strategy;
            }
        }

        return undefined;
    }

    private matchesDomain(domain: string, matchers: any[]): boolean {
        for (const matcher of matchers) {
            switch (matcher.type) {
                case 'exact':
                    if (matcher.caseSensitive) {
                        if (domain === matcher.pattern) return true;
                    } else {
                        if (domain.toLowerCase() === matcher.pattern.toLowerCase()) return true;
                    }
                    break;
                case 'wildcard': {
                    const pattern = matcher.pattern.replace(/\*/g, '.*');
                    const regex = new RegExp(`^${pattern}$`, matcher.caseSensitive ? '' : 'i');
                    if (regex.test(domain)) return true;
                    break;
                }
                case 'regex': {
                    const regexPattern = new RegExp(matcher.pattern, matcher.caseSensitive ? '' : 'i');
                    if (regexPattern.test(domain)) return true;
                    break;
                }
            }
        }
        return false;
    }

    private async processWithStrategy(url: string, strategy: Strategy): Promise<{
        primary: CleanedUrl;
        alternatives: CleanedUrl[];
        redirectMs?: number;
    }> {
        const actions: string[] = [];
        let currentUrl = url;
        let redirectChain: string[] = [];
        let redirectMs = 0;

        // Step 1: Follow redirects if enabled
        if (strategy.redirectPolicy.follow) {
            const redirectStart = Date.now();
            const redirectResult = await this.redirectResolver.resolve(
                currentUrl,
                {
                    maxDepth: strategy.redirectPolicy.maxDepth ?? 10,
                    timeoutMs: strategy.redirectPolicy.timeoutMs ?? 8000,
                }
            );
            redirectMs = Date.now() - redirectStart;
            console.log(`[Engine] Redirect resolve: success=${redirectResult.success} depth=${redirectResult.chain?.length || 0} finalUrl=${redirectResult.finalUrl || 'n/a'} error=${redirectResult.error || 'none'}`);
            if (redirectResult.chain.length > 0) {
                currentUrl = redirectResult.chain[redirectResult.chain.length - 1];
                redirectChain = redirectResult.chain;
                const hops = Math.max(0, redirectResult.chain.length - 1);
                actions.push(hops > 0 ? `Followed ${hops} redirects` : 'No redirects');
            } else {
                actions.push('No redirects observed');
            }
        }

        // Step 2: Process URL with strategy rules
        console.log(`[Engine] Processing with strategy id=${strategy.id} on url=${currentUrl}`);
        const processedUrl = await this.urlProcessor.process(currentUrl, strategy);
        console.log(`[Engine] Processed URL: ${processedUrl}`);
        actions.push('Applied strategy rules');

        // Step 3: Generate alternatives
        const alternatives = this.generateAlternatives(url, processedUrl, strategy);

        return {
            primary: {
                url: processedUrl,
                confidence: this.calculateConfidence(processedUrl, strategy),
                actions,
                redirectionChain: redirectChain.length > 0 ? redirectChain : undefined,
            },
            alternatives,
            redirectMs,
        };
    }

    private generateAlternatives(originalUrl: string, processedUrl: string, _strategy: Strategy): CleanedUrl[] {
        const alternatives: CleanedUrl[] = [];

        // Alternative 1: More aggressive cleaning (drop common UTMs if somehow still present)
        const aggressiveUrl = new URL(processedUrl);
        // Remove more parameters
        const paramsToRemove = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term'];
        paramsToRemove.forEach(param => {
            aggressiveUrl.searchParams.delete(param);
        });

        if (aggressiveUrl.toString() !== processedUrl) {
            alternatives.push({
                url: aggressiveUrl.toString(),
                confidence: 0.9,
                reason: 'More aggressive parameter removal',
                actions: ['Removed additional UTM parameters'],
            });
        }

        // Always consider the original input URL as a reference alternative (engine-wide)
        if (originalUrl !== processedUrl) {
            alternatives.push({
                url: originalUrl,
                confidence: 0.55,
                reason: 'Original input URL',
                actions: ['Kept original input for reference'],
            });
        }

        return alternatives;
    }

    private calculateConfidence(url: string, strategy: Strategy): number {
        let confidence = 0.8; // Base confidence

        // Increase confidence based on strategy specificity
        if (strategy.matchers.some(m => m.type === 'exact')) {
            confidence += 0.1;
        }

        // Decrease confidence if many parameters were removed
        const urlObj = new URL(url);
        const paramCount = urlObj.searchParams.size;
        if (paramCount === 0) {
            confidence += 0.1;
        } else if (paramCount > 5) {
            confidence -= 0.1;
        }

        return Math.min(1.0, Math.max(0.0, confidence));
    }
}
