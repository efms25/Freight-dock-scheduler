import { Readable } from "node:stream";

export interface S3PutObjectInput {
    Key: string;
    Body: Readable | Buffer | Uint8Array | string
}