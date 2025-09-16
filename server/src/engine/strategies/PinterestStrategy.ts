import { Strategy } from '../../types';

export class PinterestStrategy {
    static create(): Strategy {
        return {
            id: 'pinterest',
            name: 'Pinterest',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'www.pinterest.com' },
                { type: 'exact', pattern: 'pinterest.com' },
                { type: 'exact', pattern: 'pin.it' },
                { type: 'wildcard', pattern: '*.pinterest.com' },
                { type: 'wildcard', pattern: '*.pin.it' },
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
                { name: 'pin_id', action: 'deny', reason: 'Pinterest pin tracking' },
                { name: 'board_id', action: 'deny', reason: 'Pinterest board tracking' },
                { name: 'user_id', action: 'deny', reason: 'Pinterest user tracking' },
                { name: 'session_id', action: 'deny', reason: 'Pinterest session tracking' },
                // Pinterest invite/share specific params
                { name: 'invite_code', action: 'deny', reason: 'Pinterest invite code' },
                { name: 'sender', action: 'deny', reason: 'Pinterest sender identifier' },
                { name: 'sfo', action: 'deny', reason: 'Pinterest share flag' },
                { name: 'locale', action: 'allow', reason: 'Locale setting' },
                { name: 'language', action: 'allow', reason: 'Language preference' },
                { name: 'hl', action: 'allow', reason: 'Language preference' },
            ],
            pathRules: [
                // Normalize pin sent/share pages to canonical pin path
                {
                    pattern: '^/pin/(\\d+)/sent/.*$',
                    replacement: '/pin/$1/',
                    type: 'regex',
                },
                // Normalize verbose slug pins that embed numeric id at the end: ...--{id}/
                {
                    pattern: '^/pin/.+--(\\d+)/?$',
                    replacement: '/pin/$1/',
                    type: 'regex',
                },
                {
                    pattern: '^/pin/(\\d+).*$',
                    replacement: '/pin/$1/',
                    type: 'regex',
                },
                {
                    pattern: '^/board/\\d+',
                    replacement: '/board/',
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
                { type: 'domain', template: 'www.pinterest.com', required: true },
            ],
            notes: 'Pinterest strategy removes tracking parameters while preserving pin and board identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
