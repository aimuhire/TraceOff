import { Strategy } from '../../types';

export class MediumStrategy {
    static create(): Strategy {
        return {
            id: 'medium',
            name: 'Medium',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'medium.com' },
                { type: 'exact', pattern: 'www.medium.com' },
                { type: 'wildcard', pattern: '*.medium.com' },
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
                { name: 'source', action: 'deny', reason: 'Medium source tracking' },
                { name: 'via', action: 'deny', reason: 'Medium via tracking' },
                { name: 'share', action: 'deny', reason: 'Medium share tracking' },
                { name: 'shareId', action: 'deny', reason: 'Medium share ID tracking' },
                { name: 'userId', action: 'deny', reason: 'Medium user ID tracking' },
                { name: 'postId', action: 'deny', reason: 'Medium post ID tracking' },
                { name: 'collectionId', action: 'deny', reason: 'Medium collection ID tracking' },
                { name: 'publicationId', action: 'deny', reason: 'Medium publication ID tracking' },
                { name: 'locale', action: 'allow', reason: 'Locale setting' },
                { name: 'language', action: 'allow', reason: 'Language preference' },
                { name: 'hl', action: 'allow', reason: 'Language preference' },
            ],
            pathRules: [
                {
                    pattern: '^/@[^/]+/[^/]+',
                    replacement: '/@/',
                    type: 'regex',
                },
                {
                    pattern: '^/p/[^/]+',
                    replacement: '/p/',
                    type: 'regex',
                },
                {
                    pattern: '^/c/[^/]+',
                    replacement: '/c/',
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
                { type: 'domain', template: 'medium.com', required: true },
            ],
            notes: 'Medium strategy removes tracking parameters while preserving article and author identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
