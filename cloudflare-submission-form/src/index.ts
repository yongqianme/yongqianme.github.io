type Submission = {
  name: string;
  email: string;
  company: string;
  robotWorkflow: string;
  businessImpact: string;
  decisionDeadline: string;
  availableEvidence: string;
  referral: string;
  inquiryContext: string;
  locale: "en" | "zh";
  website: string;
  turnstileToken: string;
};

const JSON_HEADERS = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
};

const MAX_BODY_BYTES = 12_000;
const TURNSTILE_ACTION = "physical_ai_inquiry";

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: JSON_HEADERS });
}

function secure(response: Response): Response {
  const secured = new Response(response.body, response);
  secured.headers.set("x-content-type-options", "nosniff");
  secured.headers.set("referrer-policy", "no-referrer");
  secured.headers.set("permissions-policy", "camera=(), microphone=(), geolocation=()");
  secured.headers.set("x-frame-options", "DENY");
  secured.headers.set("x-robots-tag", "noindex, nofollow");
  secured.headers.set("cross-origin-opener-policy", "same-origin");
  secured.headers.set("strict-transport-security", "max-age=31536000; includeSubDomains");
  secured.headers.set(
    "content-security-policy",
    "default-src 'self'; script-src 'self' https://challenges.cloudflare.com; style-src 'self'; frame-src https://challenges.cloudflare.com; connect-src 'self' https://challenges.cloudflare.com; img-src 'self' data:; base-uri 'none'; form-action 'self'; frame-ancestors 'none'",
  );
  return secured;
}

async function readJsonBody(request: Request): Promise<unknown> {
  const declaredLength = Number(request.headers.get("content-length") || "0");
  if (!Number.isFinite(declaredLength) || declaredLength > MAX_BODY_BYTES) {
    throw new RangeError("request_too_large");
  }
  if (!request.body) throw new SyntaxError("missing_body");

  const reader = request.body.getReader();
  const decoder = new TextDecoder();
  let total = 0;
  let body = "";
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      total += value.byteLength;
      if (total > MAX_BODY_BYTES) {
        await reader.cancel();
        throw new RangeError("request_too_large");
      }
      body += decoder.decode(value, { stream: true });
    }
    body += decoder.decode();
    return JSON.parse(body);
  } finally {
    reader.releaseLock();
  }
}

function text(value: unknown, max: number): string {
  return typeof value === "string" ? value.trim().slice(0, max) : "";
}

function parseSubmission(value: unknown): Submission | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) return null;
  const input = value as Record<string, unknown>;
  const submission: Submission = {
    name: text(input.name, 100),
    email: text(input.email, 160).toLowerCase(),
    company: text(input.company, 160),
    robotWorkflow: text(input.robotWorkflow, 2000),
    businessImpact: text(input.businessImpact, 500),
    decisionDeadline: text(input.decisionDeadline, 160),
    availableEvidence: text(input.availableEvidence, 1000),
    referral: text(input.referral, 200),
    inquiryContext: ["diagnostic", "recovery", "support", "physical-ai", "diligence"].includes(text(input.inquiryContext, 40))
      ? text(input.inquiryContext, 40)
      : "diagnostic",
    locale: input.locale === "zh" ? "zh" : "en",
    website: text(input.website, 200),
    turnstileToken: text(input.turnstileToken, 2048),
  };

  if (!submission.name || !submission.company || !submission.robotWorkflow) return null;
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(submission.email)) return null;
  return submission;
}

async function verifyTurnstile(token: string, request: Request, env: Env): Promise<boolean> {
  if (!env.TURNSTILE_SECRET_KEY) return false;
  const form = new FormData();
  form.set("secret", env.TURNSTILE_SECRET_KEY);
  form.set("response", token);
  form.set("idempotency_key", crypto.randomUUID());
  const ip = request.headers.get("CF-Connecting-IP");
  if (ip) form.set("remoteip", ip);

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 8_000);
  try {
    const response = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", {
      method: "POST",
      body: form,
      signal: controller.signal,
    });
    if (!response.ok) return false;
    const result = (await response.json()) as { success?: boolean; action?: string; hostname?: string };
    if (result.success !== true) return false;
    if (env.ENVIRONMENT === "production") {
      return result.action === TURNSTILE_ACTION && result.hostname === new URL(request.url).hostname;
    }
    return true;
  } finally {
    clearTimeout(timeout);
  }
}

async function submit(request: Request, env: Env): Promise<Response> {
  if (!request.headers.get("content-type")?.toLowerCase().startsWith("application/json")) {
    return json({ ok: false, error: "Content type must be application/json." }, 415);
  }
  const requestUrl = new URL(request.url);
  if (request.headers.get("origin") !== requestUrl.origin) {
    return json({ ok: false, error: "Request origin is not allowed." }, 403);
  }
  if (!env.TURNSTILE_SITE_KEY || !env.TURNSTILE_SECRET_KEY) {
    return json({ ok: false, error: "Submission protection is not configured." }, 503);
  }

  let input: unknown;
  try {
    input = await readJsonBody(request);
  } catch (error) {
    if (error instanceof RangeError) return json({ ok: false, error: "Request too large." }, 413);
    return json({ ok: false, error: "Invalid request." }, 400);
  }
  const submission = parseSubmission(input);
  if (!submission) return json({ ok: false, error: "Check the required fields." }, 422);
  if (submission.website) return json({ ok: true, reference: crypto.randomUUID() }, 201);

  let human = false;
  try {
    human = await verifyTurnstile(submission.turnstileToken, request, env);
  } catch (error) {
    console.error(JSON.stringify({ event: "turnstile_error", message: String(error) }));
  }
  if (!human) return json({ ok: false, error: "Verification failed. Please try again." }, 403);

  const id = crypto.randomUUID();
  const createdAt = new Date().toISOString();
  await env.DB.prepare(
    `INSERT INTO submissions
      (id, created_at, name, email, company, robot_workflow, business_impact,
       decision_deadline, available_evidence, referral, locale, expires_at, inquiry_context)
     VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13)`,
  ).bind(
    id,
    createdAt,
    submission.name,
    submission.email,
    submission.company,
    submission.robotWorkflow,
    submission.businessImpact || null,
    submission.decisionDeadline || null,
    submission.availableEvidence || null,
    submission.referral || null,
    submission.locale,
    new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(),
    submission.inquiryContext,
  ).run();

  console.log(JSON.stringify({ event: "submission_created", id, createdAt }));
  return json({ ok: true, reference: id }, 201);
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    try {
      const url = new URL(request.url);
      if (url.pathname === "/api/config") {
        if (request.method !== "GET") return secure(new Response(null, { status: 405, headers: { allow: "GET" } }));
        return secure(json({ turnstileSiteKey: env.TURNSTILE_SITE_KEY || null }));
      }
      if (url.pathname === "/api/submissions") {
        if (request.method !== "POST") return secure(new Response(null, { status: 405, headers: { allow: "POST" } }));
        return secure(await submit(request, env));
      }
      if (url.pathname.startsWith("/api/")) {
        return secure(json({ ok: false, error: "Not found." }, 404));
      }
      return secure(await env.ASSETS.fetch(request));
    } catch (error) {
      console.error(JSON.stringify({ event: "request_error", message: String(error) }));
      return secure(json({ ok: false, error: "Unable to process the request." }, 500));
    }
  },
  async scheduled(_controller: ScheduledController, env: Env): Promise<void> {
    await env.DB.prepare("DELETE FROM submissions WHERE expires_at IS NOT NULL AND expires_at <= ?1")
      .bind(new Date().toISOString())
      .run();
    console.log(JSON.stringify({ event: "expired_submissions_deleted" }));
  },
} satisfies ExportedHandler<Env>;
