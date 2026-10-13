/**
 * Audit seed: create an email + password account for the person-like UI audit
 * with the address ALREADY confirmed.
 *
 * Why: the signup flow emails a 6-digit code, and a UI audit cannot open a
 * mailbox. The password goes through the real /auth/signup (real scrypt hash,
 * real POPIA consent rows); only the `emailVerified` flag is stamped — the
 * exact same shortcut the backend's own e2e fixtures (e2e/fixtures.ts) use.
 * The unverified → code → verified path itself is exercised by
 * integration_test/audit/verify_email_audit_test.dart.
 *
 * Usage (run with the backend checkout as cwd so @prisma/client resolves):
 *   AUDIT_BACKEND_URL=http://127.0.0.1:8080 node tool/audit/seed_audit_user.mjs <email> <password>
 */
import { createRequire } from "node:module";

const [email, password] = process.argv.slice(2);
if (!email || !password) {
  console.error("usage: node seed_audit_user.mjs <email> <password>");
  process.exit(1);
}
const baseUrl = process.env.AUDIT_BACKEND_URL ?? "http://127.0.0.1:8080";

// 1) Real signup — the password is hashed by the backend, never by us.
const res = await fetch(`${baseUrl}/auth/signup`, {
  method: "POST",
  headers: { "content-type": "application/json" },
  body: JSON.stringify({ email, password, acceptTerms: true }),
});
if (res.status === 409) {
  console.log(`signup: ${email} already exists — reusing the account`);
} else if (!res.ok) {
  console.error(`signup failed: ${res.status} ${await res.text()}`);
  process.exit(1);
} else {
  console.log(`signup: account created for ${email}`);
}

// 2) Stamp the confirmed address (the emailed code needs a mailbox).
const require = createRequire(process.cwd() + "/package.json");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
try {
  await prisma.user.update({
    where: { email },
    data: { emailVerified: true },
  });
  console.log(`seeded: ${email} is verified and ready to sign in`);
} finally {
  await prisma.$disconnect();
}
