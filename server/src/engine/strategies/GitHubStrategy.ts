import { Strategy } from '../../types';

export class GitHubStrategy {
    static create(): Strategy {
        return {
            id: 'github',
            name: 'GitHub',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'github.com' },
                { type: 'exact', pattern: 'www.github.com' },
                { type: 'wildcard', pattern: '*.github.com' },
            ],
            paramPolicies: [
                { name: 'utm_*', action: 'deny', reason: 'UTM tracking parameters' },
                { name: 'fbclid', action: 'deny', reason: 'Facebook click ID' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
                { name: 'igshid', action: 'deny', reason: 'Instagram tracking parameter' },
                { name: 'si', action: 'deny', reason: 'Session tracking' },
                { name: 'ref', action: 'deny', reason: 'Referral parameter' },
                { name: 'source', action: 'deny', reason: 'Source tracking' },
                { name: 'campaign', action: 'deny', reason: 'Campaign tracking' },
                { name: 'medium', action: 'deny', reason: 'Medium tracking' },
                { name: 'content', action: 'deny', reason: 'Content tracking' },
                { name: 'term', action: 'deny', reason: 'Term tracking' },
                { name: 'tab', action: 'allow', reason: 'GitHub tab parameter' },
                { name: 'branch', action: 'allow', reason: 'GitHub branch parameter' },
                { name: 'path', action: 'allow', reason: 'GitHub path parameter' },
                { name: 'line', action: 'allow', reason: 'GitHub line parameter' },
                { name: 'startLine', action: 'allow', reason: 'GitHub start line parameter' },
                { name: 'endLine', action: 'allow', reason: 'GitHub end line parameter' },
                { name: 'q', action: 'allow', reason: 'GitHub search query' },
                { name: 'type', action: 'allow', reason: 'GitHub type parameter' },
                { name: 'language', action: 'allow', reason: 'GitHub language parameter' },
                { name: 'sort', action: 'allow', reason: 'GitHub sort parameter' },
                { name: 'order', action: 'allow', reason: 'GitHub order parameter' },
                { name: 'per_page', action: 'allow', reason: 'GitHub pagination' },
                { name: 'page', action: 'allow', reason: 'GitHub pagination' },
                { name: 'state', action: 'allow', reason: 'GitHub state parameter' },
                { name: 'labels', action: 'allow', reason: 'GitHub labels parameter' },
                { name: 'milestone', action: 'allow', reason: 'GitHub milestone parameter' },
                { name: 'assignee', action: 'allow', reason: 'GitHub assignee parameter' },
                { name: 'creator', action: 'allow', reason: 'GitHub creator parameter' },
                { name: 'mentioned', action: 'allow', reason: 'GitHub mentioned parameter' },
                { name: 'locale', action: 'allow', reason: 'Locale setting' },
                { name: 'hl', action: 'allow', reason: 'Language preference' },
            ],
            pathRules: [
                {
                    pattern: '^/[^/]+/[^/]+/blob/[^/]+',
                    replacement: '/',
                    type: 'regex',
                },
                {
                    pattern: '^/[^/]+/[^/]+/tree/[^/]+',
                    replacement: '/',
                    type: 'regex',
                },
                {
                    pattern: '^/[^/]+/[^/]+/commit/[^/]+',
                    replacement: '/',
                    type: 'regex',
                },
                {
                    pattern: '^/[^/]+/[^/]+/pull/\\d+',
                    replacement: '/',
                    type: 'regex',
                },
                {
                    pattern: '^/[^/]+/[^/]+/issues/\\d+',
                    replacement: '/',
                    type: 'regex',
                },
            ],
            redirectPolicy: {
                follow: true,
                maxDepth: 2,
                timeoutMs: 3000,
                allowedSchemes: ['http', 'https'],
            },
            canonicalBuilders: [
                { type: 'domain', template: 'github.com', required: true },
            ],
            notes: 'GitHub strategy removes tracking parameters while preserving repository and content identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
