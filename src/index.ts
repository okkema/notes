type Environment = {
	NOTES: R2Bucket
}

export default {
	async fetch(request: Request, env: Environment) {
		const url = new URL(request.url)
		const { pathname, hostname } = url
		console.log(pathname)
		const subdomain = hostname.split(".")[0]
		let base = `${subdomain}${pathname.replace(/\/$/, "")}`
		let html: R2ObjectBody | null
		if (pathname.endsWith(".html")) html = await env.NOTES.get(base)
		else html = await env.NOTES.get(`${base}.html`)
		if (!html) html = await env.NOTES.get(`${base}/index.html`)
		if (!html) return new Response("Not Found", { status: 404 })
		const headers = new Headers()
		html.writeHttpMetadata(headers)
		headers.set("etag", html.httpEtag)
		return new Response(html.body, { headers })
	},
};
