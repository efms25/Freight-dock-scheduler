import Fastify from "fastify";
import multipart from "@fastify/multipart";

export default function startApp() {
  const server = Fastify({
    logger: true,
  });

  server.register(multipart, {
    limits: {
      fileSize: 15 * 1024 * 1024,
      files: 6,
    },
  });

  server.get("/health", async (request, reply) => {
    return true;
  });

  return server;
}
