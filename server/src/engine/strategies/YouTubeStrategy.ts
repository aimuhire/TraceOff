import { Strategy } from '../../types';

export class YouTubeStrategy {
    static create(): Strategy {
        return {
            id: 'youtube',
            name: 'YouTube',
            version: '1.0.0',
            enabled: true,
            priority: 100,
            matchers: [
                { type: 'exact', pattern: 'www.youtube.com' },
                { type: 'exact', pattern: 'youtube.com' },
                { type: 'exact', pattern: 'youtu.be' },
                { type: 'wildcard', pattern: '*.youtube.com' },
                { type: 'wildcard', pattern: '*.youtu.be' },
            ],
            paramPolicies: [
                { name: 'v', action: 'allow', reason: 'Video ID - essential for content' },
                { name: 't', action: 'allow', reason: 'Timestamp - preserves video position' },
                { name: 'list', action: 'allow', reason: 'Playlist ID - essential for playlists' },
                { name: 'index', action: 'allow', reason: 'Playlist index - preserves position' },
                { name: 'hl', action: 'allow', reason: 'Language preference' },
                { name: 'cc_lang_pref', action: 'allow', reason: 'Caption language preference' },
                { name: 'cc_load_policy', action: 'allow', reason: 'Caption load policy' },
                { name: 'iv_load_policy', action: 'allow', reason: 'Annotations policy' },
                { name: 'fs', action: 'allow', reason: 'Fullscreen control' },
                { name: 'rel', action: 'allow', reason: 'Related videos control' },
                { name: 'modestbranding', action: 'allow', reason: 'Branding control' },
                { name: 'playsinline', action: 'allow', reason: 'Mobile playback control' },
                { name: 'autoplay', action: 'allow', reason: 'Autoplay control' },
                { name: 'loop', action: 'allow', reason: 'Loop control' },
                { name: 'mute', action: 'allow', reason: 'Mute control' },
                { name: 'start', action: 'allow', reason: 'Start time' },
                { name: 'end', action: 'allow', reason: 'End time' },
                { name: 'si', action: 'deny', reason: 'YouTube tracking parameter' },
                { name: 'igshid', action: 'deny', reason: 'Instagram tracking parameter' },
                { name: 'utm_*', action: 'deny', reason: 'UTM tracking parameters' },
                { name: 'fbclid', action: 'deny', reason: 'Facebook click ID' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
                { name: 'ref', action: 'deny', reason: 'Referral parameter' },
                { name: 'source', action: 'deny', reason: 'Source tracking' },
                { name: 'campaign', action: 'deny', reason: 'Campaign tracking' },
                { name: 'medium', action: 'deny', reason: 'Medium tracking' },
                { name: 'content', action: 'deny', reason: 'Content tracking' },
                { name: 'term', action: 'deny', reason: 'Term tracking' },
                { name: 'feature', action: 'deny', reason: 'Feature tracking' },
                { name: 'app', action: 'deny', reason: 'App tracking' },
                { name: 'client', action: 'deny', reason: 'Client tracking' },
                { name: 'gl', action: 'deny', reason: 'Geographic tracking' },
                { name: 'gclid', action: 'deny', reason: 'Google click ID' },
            ],
            pathRules: [
                {
                    pattern: '^/watch\\?.*',
                    replacement: '/watch',
                    type: 'regex',
                },
                {
                    pattern: '^/playlist\\?.*',
                    replacement: '/playlist',
                    type: 'regex',
                },
                {
                    pattern: '^/embed/[^/]+',
                    replacement: '/embed/',
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
                { type: 'domain', template: 'www.youtube.com', required: true },
            ],
            notes: 'YouTube strategy preserves video/playlist identifiers and playback controls while removing tracking parameters',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        };
    }
}
