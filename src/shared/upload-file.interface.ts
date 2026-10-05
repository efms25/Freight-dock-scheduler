import { Readable } from "node:stream";

export interface UploadFile {
    filename: string,
    mimetype: string,
    file: Readable
}