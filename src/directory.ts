import type { Environment } from "./environment"

function keyToUrl(root: string, key: string): string {
  const parts = key.split("/")
  const subdomain = parts.shift()
  const domain = `${subdomain}.${root}`
  return `https://${domain}/${parts.join("/")}`
}

export async function fetchDirectory(root: string, env: Environment): Promise<Response> {
	const results = await env.BUCKET.list()
	let truncated = results.truncated
	// @ts-ignore
	let cursor = truncated ? results.cursor : undefined 
	while (truncated) {
		const next = await env.BUCKET.list({ cursor })
		results.objects.push(...next.objects)
		truncated = next.truncated
		// @ts-ignore
		cursor = next.cursor
	}
	const files = results.objects.sort(function(a, b) { return a.key < b.key ? -1 : 1 })
	const html = `
		<!doctype html>
		<html>
      <head>
        <title>directory</title>
      </head>
			<body>
				<ul>
					${files.reduce(function(prev, curr) {
						return prev + `<li><a href="${keyToUrl(root, curr.key)}">${curr.key}</a></li>`
					}, "")}
				</ul>
			</body>
		</html>
	`
	return new Response(html, { headers: { "Content-Type": "text/html" } })
}
