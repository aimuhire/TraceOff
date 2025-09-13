import { Strategy } from '../../types';

export class RedditStrategy {
    static create(): Strategy {
        return {
            id: 'reddit',
            name: 'Reddit',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'www.reddit.com' },
                { type: 'exact', pattern: 'reddit.com' },
                { type: 'exact', pattern: 'old.reddit.com' },
                { type: 'exact', pattern: 'new.reddit.com' },
                { type: 'exact', pattern: 'm.reddit.com' },
                { type: 'wildcard', pattern: '*.reddit.com' },
            ],
            paramPolicies: [
                { name: 'ref', action: 'deny', reason: 'Reddit referral tracking' },
                { name: 'ref_source', action: 'deny', reason: 'Reddit referral source' },
                { name: 'ref_campaign', action: 'deny', reason: 'Reddit campaign tracking' },
                { name: 'utm_*', action: 'deny', reason: 'UTM tracking parameters' },
                { name: 'fbclid', action: 'deny', reason: 'Facebook click ID' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
                { name: 'igshid', action: 'deny', reason: 'Instagram tracking parameter' },
                { name: 'si', action: 'deny', reason: 'Session tracking' },
                { name: 'source', action: 'deny', reason: 'Source tracking' },
                { name: 'campaign', action: 'deny', reason: 'Campaign tracking' },
                { name: 'medium', action: 'deny', reason: 'Medium tracking' },
                { name: 'content', action: 'deny', reason: 'Content tracking' },
                { name: 'term', action: 'deny', reason: 'Term tracking' },
                { name: 'context', action: 'allow', reason: 'Reddit context parameter' },
                { name: 'sort', action: 'allow', reason: 'Reddit sort parameter' },
                { name: 't', action: 'allow', reason: 'Reddit time filter' },
                { name: 'limit', action: 'allow', reason: 'Reddit limit parameter' },
                { name: 'after', action: 'allow', reason: 'Reddit pagination' },
                { name: 'before', action: 'allow', reason: 'Reddit pagination' },
                { name: 'count', action: 'allow', reason: 'Reddit count parameter' },
                { name: 'raw_json', action: 'allow', reason: 'Reddit JSON format' },
                { name: 'locale', action: 'allow', reason: 'Locale setting' },
                { name: 'language', action: 'allow', reason: 'Language preference' },
                { name: 'hl', action: 'allow', reason: 'Language preference' },
            ],
            pathRules: [
                {
                    pattern: '^/r/[^/]+/comments/[^/]+',
                    replacement: '/r/',
                    type: 'regex',
                },
                {
                    pattern: '^/user/[^/]+',
                    replacement: '/user/',
                    type: 'regex',
                },
                {
                    pattern: '^/u/[^/]+',
                    replacement: '/u/',
                    type: 'regex',
                },
            ],
            redirectPolicy: {
                follow: true,
                maxDepth: 3,
                timeoutMs: 3000,
                allowedSchemes: ['http', 'https'],
            },
            canonicalBuilders: [
                { type: 'domain', template: 'www.reddit.com', required: true },
            ],
            notes: 'Reddit strategy removes tracking parameters while preserving subreddit and post identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
