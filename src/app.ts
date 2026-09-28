import Fastify from "fastify";

export default function startApp() {
    const server = Fastify({
        logger: true
    });

    server.get('/health', async (request, reply) => {
        return true
    })

    return server;
}