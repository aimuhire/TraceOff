#!/usr/bin/env node

/**
 * Generate Admin Secret Script
 *
 * This script generates a secure 64-character admin secret for the Detrack server.
 * Run this script to generate a new admin secret for your environment.
 */

const crypto = require("crypto");

function generateAdminSecret() {
  // Generate 64 random bytes and convert to base64, then take first 64 characters
  const randomBytes = crypto.randomBytes(48); // 48 bytes = 64 base64 characters
  const secret = randomBytes.toString("base64").substring(0, 64);

  // Ensure it's exactly 64 characters
  if (secret.length !== 64) {
    throw new Error("Generated secret is not 64 characters long");
  }

  return secret;
}

function main() {
  try {
    const secret = generateAdminSecret();

    console.log("🔐 Generated 64-character admin secret:");
    console.log("");
    console.log(`ADMIN_SECRET=${secret}`);
    console.log("");
    console.log("📝 Add this to your .env file:");
    console.log("1. Copy the ADMIN_SECRET line above");
    console.log("2. Paste it into your .env file");
    console.log("3. Restart your server");
    console.log("");
    console.log(
      "⚠️  Keep this secret secure and do not commit it to version control!"
    );
  } catch (error) {
    console.error("❌ Error generating admin secret:", error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { generateAdminSecret };
