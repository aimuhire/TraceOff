import { Strategy } from '../../types';

export class TwitterStrategy {
    static create(): Strategy {
        return {
            id: 'twitter',
            name: 'X (Twitter)',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'twitter.com' },
                { type: 'exact', pattern: 'www.twitter.com' },
                { type: 'exact', pattern: 'x.com' },
                { type: 'exact', pattern: 'www.x.com' },
                { type: 'wildcard', pattern: '*.twitter.com' },
                { type: 'wildcard', pattern: '*.x.com' },
            ],
            paramPolicies: [
                { name: 's', action: 'deny', reason: 'Twitter tracking parameter' },
                { name: 't', action: 'deny', reason: 'Twitter tracking parameter' },
                { name: 'ref_src', action: 'deny', reason: 'Twitter referral source' },
                { name: 'ref_url', action: 'deny', reason: 'Twitter referral URL' },
                { name: 'via', action: 'deny', reason: 'Twitter via parameter' },
                { name: 'hashtags', action: 'deny', reason: 'Twitter hashtag tracking' },
                { name: 'text', action: 'deny', reason: 'Twitter text tracking' },
                { name: 'url', action: 'deny', reason: 'Twitter URL tracking' },
                { name: 'related', action: 'deny', reason: 'Twitter related tracking' },
                { name: 'lang', action: 'allow', reason: 'Language preference' },
                { name: 'locale', action: 'allow', reason: 'Locale setting' },
                { name: 'utm_*', action: 'deny', reason: 'UTM tracking parameters' },
                { name: 'fbclid', action: 'deny', reason: 'Facebook click ID' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
                { name: 'ref', action: 'deny', reason: 'Referral parameter' },
                { name: 'source', action: 'deny', reason: 'Source tracking' },
                { name: 'campaign', action: 'deny', reason: 'Campaign tracking' },
                { name: 'medium', action: 'deny', reason: 'Medium tracking' },
                { name: 'content', action: 'deny', reason: 'Content tracking' },
                { name: 'term', action: 'deny', reason: 'Term tracking' },
            ],
            pathRules: [
                {
                    pattern: '^/status/\\d+',
                    replacement: '/status/',
                    type: 'regex',
                },
                {
                    pattern: '^/i/status/\\d+',
                    replacement: '/i/status/',
                    type: 'regex',
                },
                {
                    pattern: '^/intent/.*',
                    replacement: '/intent/',
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
                { type: 'domain', template: 'twitter.com', required: true },
            ],
            notes: 'Twitter/X strategy removes tracking parameters while preserving tweet identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
