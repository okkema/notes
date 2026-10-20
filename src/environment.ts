import { type R2Bucket } from "@cloudflare/workers-types"

export type Environment = {
	SENTRY_DSN: string
	BUCKET: R2Bucket
	GOOGLE_CREDENTIALS: string
	GOOGLE_FUNCTION_URL_OCR: string
}