import dotenv from "dotenv";
dotenv.config({ quiet: true });

import startApp from "./src/app";
import { logger } from "./src/shared/logger";

const server = startApp();

try {
  server.listen(
    {
      port: process.env.SERVER_PORT
        ? Number.parseInt(process.env.SERVER_PORT)
        : 8080,
    },
    (err, address) => {
      if (err) {
        logger.fatal(`Exception: server not started. ${err.name}: ${err.message}`);
        process.exit(1);
      }
      logger.info(`Server listening at ${address}`);
    },
  );
} catch (err: any) {}
