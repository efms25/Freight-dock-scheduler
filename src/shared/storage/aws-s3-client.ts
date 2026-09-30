import { S3Client } from "@aws-sdk/client-s3";
import { logger } from "../logger";

const region = process.env.AWS_S3_REGION ?? process.env.AWS_REGION;


export const s3Client = new S3Client({region, logger})