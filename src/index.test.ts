import { describe, expect, it } from "vitest"
import {
  env,
  createExecutionContext,
  waitOnExecutionContext,
} from "cloudflare:test"
import worker from "./index"

describe("Worker", () => {
	it("should return 404 response", async () => {
		const ctx = createExecutionContext()
		const req = new Request("https://example.com", { method: "GET" })
		// @ts-expect-error
		const resp = await worker.fetch(req, env, ctx)
		await waitOnExecutionContext(ctx)
		expect(resp.status).toBe(404)

		const text = await resp.text()
		expect(text).toBeDefined()
	})
})
