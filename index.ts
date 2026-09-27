import dotenv from "dotenv";
dotenv.config({ quiet: true });

import startApp from "./src/app";

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
        console.log(err);
        process.exit(1);
      }
      console.log(`Server listening at ${address}`);
    },
  );
} catch (err: any) {}
