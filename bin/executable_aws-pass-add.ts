#!/usr/bin/env bun
import { $ } from "bun";

const profile = process.argv[2];
const accessLevel = process.argv[3];

if (!profile || !accessLevel) {
  console.error("Usage: aws-pass-add <profile-name> <ro|admin>");
  process.exit(1);
}

// Validate profile name (alphanumeric, hyphens, underscores only)
if (!/^[a-zA-Z0-9_-]+$/.test(profile)) {
  console.error("Error: Profile name must be alphanumeric with hyphens or underscores only");
  process.exit(1);
}

if (accessLevel !== "ro" && accessLevel !== "admin") {
  console.error("Error: Access level must be 'ro' or 'admin'");
  process.exit(1);
}

const passPath = `aws/profiles/${profile}-${accessLevel}`;

// Check if entry already exists
try {
  await $`pass show ${passPath}`.quiet();
  console.error(`Error: pass entry '${passPath}' already exists`);
  console.error("Remove it first with: pass rm -f " + passPath);
  process.exit(1);
} catch {
  // Entry doesn't exist, continue
}

// Prompt for credentials
const accessKeyId = await prompt("AWS Access Key ID: ");
if (!accessKeyId || !accessKeyId.startsWith("AKIA") && !accessKeyId.startsWith("ASIA")) {
  console.error("Error: Access Key ID must start with AKIA or ASIA");
  process.exit(1);
}

const secretAccessKey = await prompt("AWS Secret Access Key: ");
if (!secretAccessKey || secretAccessKey.length < 20) {
  console.error("Error: Secret Access Key too short");
  process.exit(1);
}

const sessionToken = await prompt("Session Token (optional, press Enter to skip): ");

// Build JSON credential object
const credentials: {
  Version: number;
  AccessKeyId: string;
  SecretAccessKey: string;
  SessionToken?: string;
} = {
  Version: 1,
  AccessKeyId: accessKeyId,
  SecretAccessKey: secretAccessKey,
};

if (sessionToken && sessionToken.trim().length > 0) {
  credentials.SessionToken = sessionToken.trim();
}

const jsonCredentials = JSON.stringify(credentials, null, 2);

console.log("\nStoring credentials to pass...");
console.log(`Path: ${passPath}`);
console.log(`JSON:\n${jsonCredentials}`);

// Store in pass using stdin
const passProcess = Bun.spawn(["pass", "insert", "-m", passPath], {
  stdin: "pipe",
  stdout: "inherit",
  stderr: "inherit",
});

// Write credentials to stdin
const writer = passProcess.stdin;
await writer.write(jsonCredentials);
await writer.end();

const exitCode = await passProcess.exited;

if (exitCode !== 0) {
  console.error(`\nError: pass command failed with exit code ${exitCode}`);
  process.exit(1);
}

console.log(`\nSuccess! Credentials stored at: ${passPath}`);
