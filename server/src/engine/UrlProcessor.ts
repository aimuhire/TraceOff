import { Strategy, ParamPolicy } from '../types';
import { URL } from 'url';

export class UrlProcessor {
    process(url: string, strategy: Strategy): string {
        const processedUrl = url;
        console.log(`[Processor] START url=${url} strategy=${strategy.id}`);
        const urlObj = new URL(processedUrl);

        // Apply path rules
        for (const pathRule of strategy.pathRules) {
            if (pathRule.type === 'regex') {
                // Use single replacement to avoid unintended repeated rewrites
                const regex = new RegExp(pathRule.pattern);
                const before = urlObj.pathname;
                urlObj.pathname = urlObj.pathname.replace(regex, pathRule.replacement);
                if (before !== urlObj.pathname) {
                    console.log(`[Processor] PATH regex rule applied pattern=${pathRule.pattern} replacement=${pathRule.replacement} before=${before} after=${urlObj.pathname}`);
                }
            } else if (pathRule.type === 'exact') {
                if (urlObj.pathname === pathRule.pattern) {
                    const before = urlObj.pathname;
                    urlObj.pathname = pathRule.replacement;
                    console.log(`[Processor] PATH exact rule applied pattern=${pathRule.pattern} replacement=${pathRule.replacement} before=${before} after=${urlObj.pathname}`);
                }
            }
        }

        // Apply parameter policies
        const allowedParams = new Map<string, string>();

        for (const [key, value] of urlObj.searchParams) {
            const policy = this.findParamPolicy(key, strategy.paramPolicies);

            if (policy) {
                switch (policy.action) {
                    case 'allow':
                        allowedParams.set(key, value);
                        console.log(`[Processor] QUERY allow ${key}=${value}`);
                        break;
                    case 'deny':
                        // Skip this parameter
                        console.log(`[Processor] QUERY deny ${key}`);
                        break;
                    case 'conditional':
                        if (this.evaluateCondition(key, value, policy.condition || '')) {
                            allowedParams.set(key, value);
                            console.log(`[Processor] QUERY conditional-allow ${key}=${value} condition=${policy.condition}`);
                        }
                        break;
                }
            } else {
                // Default: allow parameter if no policy exists
                allowedParams.set(key, value);
                console.log(`[Processor] QUERY default-allow ${key}=${value}`);
            }
        }

        // Rebuild query string with allowed parameters
        urlObj.search = '';
        for (const [key, value] of allowedParams) {
            urlObj.searchParams.set(key, value);
        }

        // Apply canonical builders
        for (const builder of strategy.canonicalBuilders) {
            switch (builder.type) {
                case 'domain':
                    if (builder.required || urlObj.hostname !== builder.template) {
                        const before = urlObj.hostname;
                        urlObj.hostname = builder.template;
                        console.log(`[Processor] CANON domain before=${before} after=${urlObj.hostname}`);
                    }
                    break;
                case 'path':
                    if (builder.required || urlObj.pathname !== builder.template) {
                        const before = urlObj.pathname;
                        urlObj.pathname = builder.template;
                        console.log(`[Processor] CANON path before=${before} after=${urlObj.pathname}`);
                    }
                    break;
                case 'query':
                    // For query builders, we might want to add specific parameters
                    if (builder.required) {
                        const queryParams = new URLSearchParams(builder.template);
                        for (const [key, value] of queryParams) {
                            urlObj.searchParams.set(key, value);
                            console.log(`[Processor] CANON query set ${key}=${value}`);
                        }
                    }
                    break;
            }
        }

        const finalUrl = urlObj.toString();
        console.log(`[Processor] END url=${finalUrl}`);
        return finalUrl;
    }

    private findParamPolicy(paramName: string, policies: ParamPolicy[]): ParamPolicy | undefined {
        return policies.find(policy => {
            if (policy.name === paramName) return true;
            if (policy.name.includes('*')) {
                const pattern = policy.name.replace(/\*/g, '.*');
                const regex = new RegExp(`^${pattern}$`);
                return regex.test(paramName);
            }
            return false;
        });
    }

    private evaluateCondition(_paramName: string, paramValue: string, condition: string): boolean {
        // Simple condition evaluation - can be extended
        if (condition.includes('length > 0')) {
            return paramValue.length > 0;
        }
        if (condition.includes('is_numeric')) {
            return !isNaN(Number(paramValue));
        }
        if (condition.includes('contains:')) {
            const substring = condition.split('contains:')[1];
            return paramValue.includes(substring);
        }

        // Default: allow if condition is not specified
        return true;
    }
}
