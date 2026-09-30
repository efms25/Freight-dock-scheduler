import { Readable } from "node:stream"

export interface S3ObjectOutput {
    Key: string
}
export interface ObjectResult {
    body: Readable,
    contentType?: string,
    contentLength?: number,
}