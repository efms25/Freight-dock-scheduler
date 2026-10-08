import "dotenv/config";
import postgres from "@prisma/orm-postgres/runtime";
import type { Contract } from "./contract.d";
import contractJson from "./contract.json" with { type: "json" };
import { logger } from "../logger";

export type PostgresDatabase = ReturnType<typeof postgres<Contract>>;
const databaseUrl = process.env["DATABASE_URL"];

export const db = (function () {
  if(!databaseUrl) {
     throw new Error("DATABASE_URL is not defined")
  }
  try {
    return postgres<Contract>({
      contractJson,
      url: databaseUrl,
    });
  } catch (err) {
    logger.fatal(`Database connection error: ${err}`)
    throw err
  }
})();
