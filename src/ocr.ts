import { GoogleFunction } from "@okkema/worker/google"
import type { Environment } from "./environment"

export async function fetchOcr(request: Request, env: Environment): Promise<Response> {
	const url = new URL(request.url)
	const doi = url.pathname.replace("/doi/", "")
	if (!doi) return new Response("Missing doi", { status: 400 })
	const search = /^\d{2}\./
	if (!search.test(doi)) return new Response("Invalid doi", { status: 400 })
	const body = await request.formData()
	body.set("doi", doi)
	const google = GoogleFunction(env.GOOGLE_CREDENTIALS, env.GOOGLE_FUNCTION_URL_OCR)
	const response = await google.fetch({
		method: "POST",
		body: body as any,
	})
	return new Response(await response.text(), { status: response.status })
}
