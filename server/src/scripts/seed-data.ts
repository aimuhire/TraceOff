import { StrategyEngine } from '../engine/StrategyEngine';
import { StrategyFactory } from '../engine/strategies';
import fs from 'fs';
import path from 'path';

async function seedData() {
    console.log('🌱 Seeding Link Cleaner data...');

    // Initialize strategy engine
    const strategyEngine = new StrategyEngine();

    // Load all prebuilt strategies
    const strategies = StrategyFactory.createAllStrategies();
    console.log(`📋 Loaded ${strategies.length} prebuilt strategies`);

    // Add strategies to engine
    strategies.forEach(strategy => {
        strategyEngine.addStrategy(strategy);
        console.log(`✅ Added strategy: ${strategy.name} (${strategy.id})`);
    });

    // Load sample URLs
    const sampleUrlsPath = path.join(__dirname, '../data/sample-urls.json');
    const sampleUrls = JSON.parse(fs.readFileSync(sampleUrlsPath, 'utf8'));

    console.log('🧪 Testing strategies with sample URLs...');

    let totalTests = 0;
    let passedTests = 0;

    for (const [domain, urls] of Object.entries(sampleUrls)) {
        console.log(`\n🔍 Testing ${domain} strategy:`);

        for (const url of urls as string[]) {
            totalTests++;
            try {
                const result = await strategyEngine.cleanUrl(url);

                if (result.primary && result.primary.url) {
                    console.log(`  ✅ ${url.substring(0, 50)}...`);
                    console.log(`     → ${result.primary.url.substring(0, 50)}...`);
                    console.log(`     Confidence: ${(result.primary.confidence * 100).toFixed(1)}%`);
                    passedTests++;
                } else {
                    console.log(`  ❌ ${url.substring(0, 50)}... (No result)`);
                }
            } catch (error) {
                console.log(`  ❌ ${url.substring(0, 50)}... (Error: ${error})`);
            }
        }
    }

    console.log(`\n📊 Test Results: ${passedTests}/${totalTests} tests passed`);

    if (passedTests === totalTests) {
        console.log('🎉 All tests passed! Data seeding completed successfully.');
    } else {
        console.log('⚠️  Some tests failed. Check the output above for details.');
    }

    // Export strategies to JSON for backup
    const exportPath = path.join(__dirname, '../data/strategies-export.json');
    const strategiesData = strategyEngine.getAllStrategies();
    fs.writeFileSync(exportPath, JSON.stringify(strategiesData, null, 2));
    console.log(`💾 Exported strategies to ${exportPath}`);

    console.log('\n✨ Seeding completed!');
}

// Run if called directly
if (require.main === module) {
    seedData().catch(console.error);
}

export { seedData };
