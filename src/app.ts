import Fastify from "fastify";
import multipart from "@fastify/multipart";
import { SchedulingRepository } from "./features/scheduling.repository";
import { db } from "./shared/database/db";
import { logger } from "./shared/logger";
import { AwsS3FileStorage } from "./shared/storage/aws-s3-file-storage";
import { s3Client } from "./shared/storage/aws-s3-client";
import { SchedulingService } from "./features/scheduling.service";
import { SchedulingController } from "./features/scheduling.controller";

export default function startApp() {
  const prefix = "/api";

  const server = Fastify({
    logger: true,
  });

  if (!db) {
    logger.fatal("Database not found");
    throw new Error("Database not found");
  }

  // --- DI ---
  const awsS3Filestorage = new AwsS3FileStorage(s3Client);

  const schedulingRepository = new SchedulingRepository(db);
  const schedulingService = new SchedulingService(
    schedulingRepository,
    awsS3Filestorage,
  );
  const schedulingController = new SchedulingController(schedulingService);

  // Register file handling
  server.register(multipart, {
    limits: {
      fileSize: 15 * 1024 * 1024,
      files: 6,
    },
  });

  // Register routes
  server.register(schedulingController.register, { prefix });

  server.get("/health", async (_, reply) => {
    try {
      const plan = db.raw.sql`SELECT 1`
        .returnsRow({ result: "pg/int4@1" })
        .build();

      db.runtime().query(plan);

      reply.status(200).send({
        status: "ok",
      });
    } catch (errro) {
      reply.status(503).send({
        status: "unhealthy",
      });
    }
  });

  return server;
}
