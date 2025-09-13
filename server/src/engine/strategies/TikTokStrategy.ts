import { Strategy } from '../../types';

export class TikTokStrategy {
    static create(): Strategy {
        return {
            id: 'tiktok',
            name: 'TikTok',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'www.tiktok.com' },
                { type: 'exact', pattern: 'tiktok.com' },
                { type: 'wildcard', pattern: '*.tiktok.com' },
            ],
            paramPolicies: [
                { name: 'is_from_webapp', action: 'deny', reason: 'TikTok webapp tracking' },
                { name: 'sender_device', action: 'deny', reason: 'TikTok device tracking' },
                { name: 'sender_web_id', action: 'deny', reason: 'TikTok web ID tracking' },
                { name: 'share_app_id', action: 'deny', reason: 'TikTok app tracking' },
                { name: 'share_link_id', action: 'deny', reason: 'TikTok link tracking' },
                { name: 'share_item_id', action: 'deny', reason: 'TikTok item tracking' },
                { name: 'timestamp', action: 'deny', reason: 'TikTok timestamp tracking' },
                { name: 'utm_*', action: 'deny', reason: 'UTM tracking parameters' },
                { name: 'fbclid', action: 'deny', reason: 'Facebook click ID' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
                { name: 'ref', action: 'deny', reason: 'Referral parameter' },
                { name: 'source', action: 'deny', reason: 'Source tracking' },
                { name: 'campaign', action: 'deny', reason: 'Campaign tracking' },
                { name: 'medium', action: 'deny', reason: 'Medium tracking' },
                { name: 'content', action: 'deny', reason: 'Content tracking' },
                { name: 'term', action: 'deny', reason: 'Term tracking' },
                { name: 'lang', action: 'allow', reason: 'Language preference' },
                { name: 'locale', action: 'allow', reason: 'Locale setting' },
            ],
            pathRules: [
                {
                    pattern: '^/@[^/]+/video/\\d+',
                    replacement: '/@/video/',
                    type: 'regex',
                },
                {
                    pattern: '^/t/[^/]+',
                    replacement: '/t/',
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
                { type: 'domain', template: 'www.tiktok.com', required: true },
            ],
            notes: 'TikTok strategy removes tracking parameters while preserving video identifiers',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
