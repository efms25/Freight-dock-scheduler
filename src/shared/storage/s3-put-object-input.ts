export interface S3PutObjectInput {
    Key: string;
    Body: Buffer | Uint8Array | string
}