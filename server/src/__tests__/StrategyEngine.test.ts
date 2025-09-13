import { StrategyEngine } from '../engine/StrategyEngine';
import { Strategy } from '../types';
import { RedirectResolver } from '../engine/RedirectResolver';
import { StrategyFactory } from '../engine/strategies';

describe('StrategyEngine', () => {
    let strategyEngine: StrategyEngine;

    beforeEach(async () => {
        strategyEngine = new StrategyEngine();

        // Initialize with default strategies like the real app does
        const strategies = StrategyFactory.createAllStrategies();
        strategies.forEach(strategy => strategyEngine.addStrategy(strategy));
    });

    afterEach(async () => {
        // Clean up any pending async operations
        if (strategyEngine) {
            await strategyEngine.cleanup();
        }
    });

    describe('cleanUrl', () => {
        it('should clean a simple URL with tracking parameters', async () => {
            const url = 'https://example.com?utm_source=google&utm_campaign=test&id=123';
            const result = await strategyEngine.cleanUrl(url);

            expect(result.primary).toBeDefined();
            expect(result.primary.url).toContain('example.com');
            expect(result.primary.url).not.toContain('utm_source');
            expect(result.primary.url).not.toContain('utm_campaign');
        });

        it('should preserve essential parameters', async () => {
            const url = 'https://example.com?utm_source=google&id=123&timestamp=456';
            const result = await strategyEngine.cleanUrl(url);

            expect(result.primary).toBeDefined();
            expect(result.primary.url).toContain('id=123');
            expect(result.primary.url).toContain('timestamp=456');
        });

        it('should handle invalid URLs gracefully', async () => {
            const url = 'not-a-valid-url';

            // Should throw an error for invalid URL
            await expect(strategyEngine.cleanUrl(url)).rejects.toThrow();
        });

        it('should return alternatives', async () => {
            const url = 'https://example.com?utm_source=google&utm_campaign=test&id=123';
            const result = await strategyEngine.cleanUrl(url);

            expect(result.alternatives).toBeDefined();
            expect(Array.isArray(result.alternatives)).toBe(true);
        });

        it('resolves Amazon shortlink and promotes canonical dp URL; includes input as alternative', async () => {
            const input = 'https://a.co/d/2q0ZfPn';
            const finalWithParams = 'https://www.amazon.com/dp/B00OV0VYHI?ref_=cm_sw_r_mwn_dp_A1PBMKY1ZXKTB4697935&social_share=cm_sw_r_mwn_dp_A1PBMKY1ZXKTB4697935';
            const canonical = 'https://www.amazon.com/dp/B00OV0VYHI';

            const spy = jest
                .spyOn(RedirectResolver.prototype, 'resolve')
                .mockResolvedValue({
                    chain: [input, finalWithParams],
                    finalUrl: finalWithParams,
                    success: true,
                });

            const result = await strategyEngine.cleanUrl(input);

            // Primary should be canonical dp URL (parameter-free)
            expect(result.primary.url).toBe(canonical);

            // Alternatives should include the original short link input
            const altUrls = result.alternatives.map(a => a.url);
            expect(altUrls).toContain(input);

            spy.mockRestore();
        });

        it('follows Instagram share redirect to reel canonical and includes input as alternative', async () => {
            const input = 'https://www.instagram.com/share/BASdbDGwpY/';
            const reel = 'https://www.instagram.com/reel/DORiL7_jKc_';

            const spy = jest
                .spyOn(RedirectResolver.prototype, 'resolve')
                .mockResolvedValue({
                    chain: [input, reel],
                    finalUrl: reel,
                    success: true,
                });

            const result = await strategyEngine.cleanUrl(input);

            expect(result.primary.url).toBe(reel);
            const altUrls = result.alternatives.map(a => a.url);
            expect(altUrls).toContain(input);

            spy.mockRestore();
        });

        it('cleans Instagram post URL with ig_mid parameter using Instagram strategy', async () => {
            const input = 'https://www.instagram.com/p/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB';

            const spy = jest
                .spyOn(RedirectResolver.prototype, 'resolve')
                .mockResolvedValue({
                    chain: [input],
                    finalUrl: input,
                    success: true,
                });

            const result = await strategyEngine.cleanUrl(input);

            expect(result.primary.url).toBe('https://www.instagram.com/p/DOhILIkjjC3');
            expect(result.primary.url).not.toContain('ig_mid=');
            expect(result.meta.strategyId).toBe('instagram');

            spy.mockRestore();
        });

        it('cleans Instagram post URL with multiple tracking parameters', async () => {
            const input = 'https://www.instagram.com/p/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB&utm_source=share&ref=home&keep=this';

            const spy = jest
                .spyOn(RedirectResolver.prototype, 'resolve')
                .mockResolvedValue({
                    chain: [input],
                    finalUrl: input,
                    success: true,
                });

            const result = await strategyEngine.cleanUrl(input);

            expect(result.primary.url).toBe('https://www.instagram.com/p/DOhILIkjjC3?keep=this');
            expect(result.primary.url).not.toContain('ig_mid=');
            expect(result.primary.url).not.toContain('utm_source=');
            expect(result.primary.url).not.toContain('ref=');
            expect(result.primary.url).toContain('keep=this');
            expect(result.meta.strategyId).toBe('instagram');

            spy.mockRestore();
        });

        it('cleans Instagram reel URL with tracking parameters', async () => {
            const input = 'https://www.instagram.com/reel/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB&igsh=abc123';

            const spy = jest
                .spyOn(RedirectResolver.prototype, 'resolve')
                .mockResolvedValue({
                    chain: [input],
                    finalUrl: input,
                    success: true,
                });

            const result = await strategyEngine.cleanUrl(input);

            expect(result.primary.url).toBe('https://www.instagram.com/reel/DOhILIkjjC3');
            expect(result.primary.url).not.toContain('ig_mid=');
            expect(result.primary.url).not.toContain('igsh=');
            expect(result.meta.strategyId).toBe('instagram');

            spy.mockRestore();
        });
    });

    describe('strategy management', () => {
        it('should add and retrieve strategies', () => {
            const strategy: Strategy = {
                id: 'test-strategy',
                name: 'Test Strategy',
                version: '1.0.0',
                enabled: true,
                priority: 100,
                matchers: [{ type: 'exact', pattern: 'test.com' }],
                paramPolicies: [],
                pathRules: [],
                redirectPolicy: {
                    follow: true,
                    maxDepth: 5,
                    timeoutMs: 5000,
                    allowedSchemes: ['http', 'https'],
                },
                canonicalBuilders: [],
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString(),
            };

            strategyEngine.addStrategy(strategy);
            const retrieved = strategyEngine.getStrategy('test-strategy');

            expect(retrieved).toBeDefined();
            expect(retrieved?.id).toBe('test-strategy');
        });

        it('should remove strategies', () => {
            const strategy: Strategy = {
                id: 'test-strategy',
                name: 'Test Strategy',
                version: '1.0.0',
                enabled: true,
                priority: 100,
                matchers: [{ type: 'exact', pattern: 'test.com' }],
                paramPolicies: [],
                pathRules: [],
                redirectPolicy: {
                    follow: true,
                    maxDepth: 5,
                    timeoutMs: 5000,
                    allowedSchemes: ['http', 'https'],
                },
                canonicalBuilders: [],
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString(),
            };

            strategyEngine.addStrategy(strategy);
            expect(strategyEngine.getStrategy('test-strategy')).toBeDefined();

            strategyEngine.removeStrategy('test-strategy');
            expect(strategyEngine.getStrategy('test-strategy')).toBeUndefined();
        });
    });
});
