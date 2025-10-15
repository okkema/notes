import type { R2ObjectBody } from "@cloudflare/workers-types"
import type { Environment } from "./environment"

export async function fetchNotebook(base: string, pathname: string, env: Environment): Promise<Response> {
	let html: R2ObjectBody | null
	html = await env.BUCKET.get(base)
	if(!html) html = await env.BUCKET.get(`${base}.html`)
	if (!html) html = await env.BUCKET.get(`${base}/index.html`)
	if (!html) return new Response("Not Found", { status: 404 })
	const headers = new Headers()
	// @ts-expect-error
	html.writeHttpMetadata(headers)
	headers.set("etag", html.httpEtag)
	// @ts-expect-error
	return new Response(html.body, { headers })
}