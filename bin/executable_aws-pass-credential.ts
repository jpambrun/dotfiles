#!/usr/bin/env bun
import { $ } from "bun";

type AccessLevel = "ro" | "admin";

const profile = process.argv[2];

if (!profile) {
  console.error("Usage: aws-pass-credential <profile-name>");
  process.exit(1);
}

if (!/^[a-zA-Z0-9_-]+$/.test(profile)) {
  console.error("Error: Profile name must be alphanumeric with hyphens or underscores only");
  process.exit(1);
}

async function readAccessLevel(): Promise<AccessLevel> {
  const mode = process.env.AWS_ACCESS_LEVEL?.trim();

  if (!mode) {
    return "ro";
  }

  if (mode === "ro" || mode === "admin") {
    return mode;
  }

  throw new Error(`Invalid AWS_ACCESS_LEVEL '${mode}'. Expected 'ro' or 'admin'`);
}

function validateCredentialProcessJson(raw: string) {
  const parsed = JSON.parse(raw) as Record<string, unknown>;

  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error("Credential payload must be a JSON object");
  }

  if (parsed.Version !== 1) {
    throw new Error("Credential payload must contain Version: 1");
  }

  if (typeof parsed.AccessKeyId !== "string" || parsed.AccessKeyId.trim() === "") {
    throw new Error("Credential payload must contain AccessKeyId");
  }

  if (typeof parsed.SecretAccessKey !== "string" || parsed.SecretAccessKey.trim() === "") {
    throw new Error("Credential payload must contain SecretAccessKey");
  }

  if ("SessionToken" in parsed && typeof parsed.SessionToken !== "string") {
    throw new Error("SessionToken must be a string when present");
  }
}

try {
  const accessLevel = await readAccessLevel();
  const passPath = `aws/profiles/${profile}-${accessLevel}`;
  const credentials = await $`pass show ${passPath}`.text();

  validateCredentialProcessJson(credentials);
  process.stdout.write(credentials.trimEnd() + "\n");
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`aws-pass-credential: ${message}`);
  process.exit(1);
}
