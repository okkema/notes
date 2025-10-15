import { SentryWorker } from "@okkema/worker/sentry"
import type { Environment } from "./environment"
import { fetchDirectory } from "./directory"
import { fetchNotebook } from "./notebook"


export default SentryWorker<Environment>({
	// @ts-expect-error
	async fetch(request, env, ctx) {
		const url = new URL(request.url)
		const { pathname, hostname } = url
		const parts = hostname.split(".")
		const subdomain = parts.shift()
		const root = parts.join(".")
		let base = `${subdomain}${pathname.replace(/\/$/, "")}` // remove trailing slash
		if (subdomain === "private" && base === subdomain) return fetchDirectory(root, env)
		else return fetchNotebook(base, pathname, env)
	},
})
