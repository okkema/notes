import { unstable_dev } from "wrangler"
import type { UnstableDevWorker } from "wrangler"
import { describe, expect, it, beforeAll, afterAll } from "vitest"

describe("Worker", () => {
	let worker: UnstableDevWorker

	beforeAll(async () => {
		worker = await unstable_dev("functions/index.ts", {
			experimental: { 
				disableExperimentalWarning: true 
			} 
		})
	})

	afterAll(async () => {
		await worker.stop()
	})

	it("should return 404 response", async () => {
		const req = new Request("https://example.com", { method: "GET" })
		const resp = await worker.fetch(req.url)
		expect(resp.status).toBe(404)

		const text = await resp.text()
		expect(text).toBeDefined()
	})
})
