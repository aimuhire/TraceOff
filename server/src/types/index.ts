export interface CleanResult {
    primary: CleanedUrl;
    alternatives: CleanedUrl[];
    meta: CleanMeta;
}

export interface CleanedUrl {
    url: string;
    confidence: number;
    actions: string[];
    redirectionChain?: string[] | undefined;
    reason?: string | undefined;
}

export interface CleanMeta {
    domain: string;
    strategyId: string;
    strategyVersion: string;
    timing: TimingMetrics;
    appliedAt: string;
}

export interface TimingMetrics {
    totalMs: number;
    redirectMs: number;
    processingMs: number;
}

export interface Strategy {
    id: string;
    name: string;
    version: string;
    enabled: boolean;
    priority: number;
    matchers: Matcher[];
    paramPolicies: ParamPolicy[];
    pathRules: PathRule[];
    redirectPolicy: RedirectPolicy;
    canonicalBuilders: CanonicalBuilder[];
    notes?: string | undefined;
    createdAt: string;
    updatedAt: string;
}

export interface Matcher {
    type: 'exact' | 'wildcard' | 'regex';
    pattern: string;
    caseSensitive?: boolean | undefined;
}

export interface ParamPolicy {
    name: string;
    action: 'allow' | 'deny' | 'conditional';
    condition?: string | undefined;
    reason?: string | undefined;
}

export interface PathRule {
    pattern: string;
    replacement: string;
    type: 'regex' | 'exact';
}

export interface RedirectPolicy {
    follow: boolean;
    maxDepth: number;
    timeoutMs: number;
    allowedSchemes: string[];
}

export interface CanonicalBuilder {
    type: 'domain' | 'path' | 'query';
    template: string;
    required?: boolean | undefined;
}

export interface CleanRequest {
    url: string;
    strategyId?: string | undefined;
}

export interface PreviewRequest {
    url: string;
    strategyId?: string | undefined;
}

export interface StrategyRequest {
    name: string;
    matchers: Matcher[];
    paramPolicies: ParamPolicy[];
    pathRules: PathRule[];
    redirectPolicy: RedirectPolicy;
    canonicalBuilders: CanonicalBuilder[];
    notes?: string | undefined;
}

export interface StrategyUpdateRequest extends Partial<StrategyRequest> {
    enabled?: boolean | undefined;
    priority?: number | undefined;
}

export interface ApiResponse<T = any> {
    success: boolean;
    data?: T | undefined;
    error?: string | undefined;
    timestamp: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
    pagination: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}
