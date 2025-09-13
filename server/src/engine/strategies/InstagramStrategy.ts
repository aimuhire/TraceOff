import { Strategy } from '../../types';

export class InstagramStrategy {
    static create(): Strategy {
        return {
            id: 'instagram',
            name: 'Instagram',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'www.instagram.com' },
                { type: 'exact', pattern: 'instagram.com' },
                { type: 'wildcard', pattern: '*.instagram.com' },
            ],
            paramPolicies: [
                { name: 'igshid', action: 'deny', reason: 'Instagram tracking parameter' },
                { name: 'igsh', action: 'deny', reason: 'Instagram tracking parameter' },
                { name: 'ig_mid', action: 'deny', reason: 'Instagram message ID tracking' },
                { name: 'si', action: 'deny', reason: 'Instagram session parameter' },
                { name: 'utm_*', action: 'deny', reason: 'UTM tracking parameters' },
                { name: 'fbclid', action: 'deny', reason: 'Facebook click ID' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
                { name: 'ref', action: 'deny', reason: 'Referral parameter' },
                { name: 'source', action: 'deny', reason: 'Source tracking' },
                { name: 'campaign', action: 'deny', reason: 'Campaign tracking' },
                { name: 'medium', action: 'deny', reason: 'Medium tracking' },
                { name: 'content', action: 'deny', reason: 'Content tracking' },
                { name: 'term', action: 'deny', reason: 'Term tracking' },
                { name: 'hl', action: 'allow', reason: 'Language preference' },
                { name: 'locale', action: 'allow', reason: 'Locale setting' },
            ],
            pathRules: [
                // Normalize to canonical content path without trailing slash
                {
                    pattern: '^/p/([^/?#]+).*$', 'replacement': '/p/$1',
                    type: 'regex',
                },
                {
                    pattern: '^/reel/([^/?#]+).*$', 'replacement': '/reel/$1',
                    type: 'regex',
                },
                {
                    pattern: '^/tv/([^/?#]+).*$', 'replacement': '/tv/$1',
                    type: 'regex',
                },
                {
                    pattern: '^/stories/([^/]+)/([^/]+)/.*$', 'replacement': '/stories/$1/$2',
                    type: 'regex',
                },
                // Clean share URLs - remove trailing slash but preserve share format
                {
                    pattern: '^/share/([^/?#]+)/?.*$', 'replacement': '/share/$1',
                    type: 'regex',
                },
            ],
            redirectPolicy: {
                follow: true,
                maxDepth: 5,
                timeoutMs: 5000,
                allowedSchemes: ['http', 'https'],
            },
            canonicalBuilders: [
                { type: 'domain', template: 'www.instagram.com', required: true },
            ],
            notes: 'Instagram strategy removes tracking parameters while preserving content identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
