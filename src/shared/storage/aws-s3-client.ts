import { S3Client } from "@aws-sdk/client-s3";

const region = process.env.AWS_S3_REGION ?? process.env.AWS_REGION;

// TODO: add logger
export const s3Client = new S3Client({region})