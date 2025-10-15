import { type R2Bucket } from "@cloudflare/workers-types"

export type Environment = {
	SENTRY_DSN: string
	BUCKET: R2Bucket
}