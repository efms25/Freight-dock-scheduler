import "dotenv/config";
import postgres from "@prisma/orm-postgres/runtime";
import type { Contract } from "./contract.d";
import contractJson from "./contract.json" with { type: "json" };
import { logger } from "../logger";

export type PostgresDatabase = ReturnType<typeof postgres<Contract>>;

export const db = (function () {
  try {
    return postgres<Contract>({
      contractJson,
      url: process.env["DATABASE_URL"]!,
    });
  } catch (err) {
    logger.fatal(`Database connection error: ${err}`)
  }
})();
