import { Strategy } from '../../types';

export class LinkedInStrategy {
    static create(): Strategy {
        return {
            id: 'linkedin',
            name: 'LinkedIn',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'www.linkedin.com' },
                { type: 'exact', pattern: 'linkedin.com' },
                { type: 'wildcard', pattern: '*.linkedin.com' },
            ],
            paramPolicies: [
                { name: 'trk', action: 'deny', reason: 'LinkedIn tracking parameter' },
                { name: 'trkInfo', action: 'deny', reason: 'LinkedIn tracking info' },
                { name: 'trkData', action: 'deny', reason: 'LinkedIn tracking data' },
                { name: 'refId', action: 'deny', reason: 'LinkedIn referral ID' },
                { name: 'refUrl', action: 'deny', reason: 'LinkedIn referral URL' },
                { name: 'refsrc', action: 'deny', reason: 'LinkedIn referral source' },
                { name: 'source', action: 'deny', reason: 'LinkedIn source tracking' },
                { name: 'campaign', action: 'deny', reason: 'LinkedIn campaign tracking' },
                { name: 'medium', action: 'deny', reason: 'LinkedIn medium tracking' },
                { name: 'content', action: 'deny', reason: 'LinkedIn content tracking' },
                { name: 'term', action: 'deny', reason: 'LinkedIn term tracking' },
                { name: 'utm_*', action: 'deny', reason: 'UTM tracking parameters' },
                { name: 'fbclid', action: 'deny', reason: 'Facebook click ID' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
                { name: 'igshid', action: 'deny', reason: 'Instagram tracking parameter' },
                { name: 'si', action: 'deny', reason: 'Session tracking' },
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
                    pattern: '^/articles/\\d+',
                    replacement: '/articles/',
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
                    pattern: '^/company/\\d+',
                    replacement: '/company/',
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
                { type: 'domain', template: 'www.linkedin.com', required: true },
            ],
            notes: 'LinkedIn strategy removes tracking parameters while preserving content identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
