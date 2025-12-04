import { Strategy } from '../../types';

export class FacebookStrategy {
    static create(): Strategy {
        return {
            id: 'facebook',
            name: 'Facebook',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'www.facebook.com' },
                { type: 'exact', pattern: 'facebook.com' },
                { type: 'exact', pattern: 'm.facebook.com' },
                { type: 'wildcard', pattern: '*.facebook.com' },
            ],
            paramPolicies: [
                { name: 'fbclid', action: 'deny', reason: 'Facebook click ID' },
                { name: 'fbid', action: 'deny', reason: 'Facebook ID tracking' },
                { name: 'ref', action: 'deny', reason: 'Facebook referral tracking' },
                { name: 'refid', action: 'deny', reason: 'Facebook referral ID' },
                { name: 'refsrc', action: 'deny', reason: 'Facebook referral source' },
                { name: 'refurl', action: 'deny', reason: 'Facebook referral URL' },
                { name: 'source', action: 'deny', reason: 'Facebook source tracking' },
                { name: 'campaign', action: 'deny', reason: 'Facebook campaign tracking' },
                { name: 'medium', action: 'deny', reason: 'Facebook medium tracking' },
                { name: 'content', action: 'deny', reason: 'Facebook content tracking' },
                { name: 'term', action: 'deny', reason: 'Facebook term tracking' },
                { name: 'utm_*', action: 'deny', reason: 'UTM tracking parameters' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
                { name: 'igshid', action: 'deny', reason: 'Instagram tracking parameter' },
                { name: 'si', action: 'deny', reason: 'Session tracking' },
                { name: 'rdid', action: 'deny', reason: 'Facebook redirect ID tracking' },
                { name: 'share_url', action: 'deny', reason: 'Facebook share URL tracking' },
                { name: 'locale', action: 'allow', reason: 'Locale setting' },
                { name: 'language', action: 'allow', reason: 'Language preference' },
                { name: 'hl', action: 'allow', reason: 'Language preference' },
            ],
            pathRules: [
                {
                    pattern: '^/posts/\\d+',
                    replacement: '/posts/',
                    type: 'regex',
                },
                {
                    pattern: '^/photo/\\d+',
                    replacement: '/photo/',
                    type: 'regex',
                },
                {
                    pattern: '^/videos/\\d+',
                    replacement: '/videos/',
                    type: 'regex',
                },
                {
                    pattern: '^/events/\\d+',
                    replacement: '/events/',
                    type: 'regex',
                },
                {
                    pattern: '^/groups/\\d+',
                    replacement: '/groups/',
                    type: 'regex',
                },
                {
                    pattern: '^/pages/\\d+',
                    replacement: '/pages/',
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
                { type: 'domain', template: 'www.facebook.com', required: true },
            ],
            notes: 'Facebook strategy removes tracking parameters while preserving content identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
