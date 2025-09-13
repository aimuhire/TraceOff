import { Strategy } from '../../types';
import { InstagramStrategy } from './InstagramStrategy';
import { YouTubeStrategy } from './YouTubeStrategy';
import { TwitterStrategy } from './TwitterStrategy';
import { TikTokStrategy } from './TikTokStrategy';
import { FacebookStrategy } from './FacebookStrategy';
import { LinkedInStrategy } from './LinkedInStrategy';
import { RedditStrategy } from './RedditStrategy';
import { PinterestStrategy } from './PinterestStrategy';
import { GitHubStrategy } from './GitHubStrategy';
import { MediumStrategy } from './MediumStrategy';

export class StrategyFactory {
    static createAllStrategies(): Strategy[] {
        return [
            InstagramStrategy.create(),
            YouTubeStrategy.create(),
            TwitterStrategy.create(),
            TikTokStrategy.create(),
            FacebookStrategy.create(),
            LinkedInStrategy.create(),
            RedditStrategy.create(),
            PinterestStrategy.create(),
            GitHubStrategy.create(),
            MediumStrategy.create(),
        ];
    }

    static createStrategy(domain: string): Strategy | undefined {
        const strategies = this.createAllStrategies();
        return strategies.find(s => s.id === domain);
    }
}

export {
    InstagramStrategy,
    YouTubeStrategy,
    TwitterStrategy,
    TikTokStrategy,
    FacebookStrategy,
    LinkedInStrategy,
    RedditStrategy,
    PinterestStrategy,
    GitHubStrategy,
    MediumStrategy,
};
