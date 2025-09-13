#!/usr/bin/env node

const { RedirectResolver } = require("../server/dist/engine/RedirectResolver");

async function testRedirectResolver() {
  const resolver = new RedirectResolver({
    maxDepth: 5,
    timeoutMs: 5000,
    maxBodyBytes: 524288,
  });

  const url = "https://www.instagram.com/share/BASdbDGwpY";
  console.log(`Testing redirect resolution for: ${url}`);

  try {
    const result = await resolver.resolve(url);
    console.log("Result:", JSON.stringify(result, null, 2));
  } catch (error) {
    console.error("Error:", error);
  }
}

testRedirectResolver();
