export default {
	async fetch(request: Request) {
		const url = new URL(request.url)
		return new Response(`pathname: ${url.pathname}`);
	},
};
