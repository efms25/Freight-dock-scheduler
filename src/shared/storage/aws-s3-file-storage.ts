import { Readable } from "node:stream";
import { FileStorage } from "./file-storage";
import { S3PutObjectInput } from "./s3-put-object-input";
import { S3Client } from "@aws-sdk/client-s3/dist-types/S3Client";
import {
  DeleteObjectCommand,
  GetObjectCommand,
  HeadObjectCommand,
  PutObjectCommand,
  S3ServiceException,
  waitUntilObjectNotExists,
} from "@aws-sdk/client-s3";
import { ObjectResult, S3ObjectOutput } from "./s3-object-output";
import { logger } from "../logger";

export class AwsS3FileStorage implements FileStorage {
  private bucketName = process.env.SCHEDULING_BUCKET;

  constructor(private readonly s3: S3Client) {}

  async upload(input: S3PutObjectInput): Promise<S3ObjectOutput> {
    const command = new PutObjectCommand({
      Bucket: this.bucketName,
      Key: input.Key,
      Body: input.Body,
    });

    try {
      const response = await this.s3.send(command);
      logger.info(`File uploaded to s3. ${response}`);


      return {
        Key: input.Key,
      };
    } catch (caught: any) {
      if (
        caught instanceof S3ServiceException &&
        caught.name === "EntityTooLarge"
      ) {
        logger.error(
          `Error from S3 while uploading object to ${this.bucketName}. \
The object was too large. To upload objects larger than 5GB, use the S3 console (160GB max) \
or the multipart upload API (5TB max)`,
        );
      } else if (caught instanceof S3ServiceException) {
        logger.error(
          `Error from S3 while uploading object to ${this.bucketName}.  ${caught.name}: ${caught.message}`,
        );
      }
      throw caught;
    }
  }
  async download(Key: string): Promise<ObjectResult> {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucketName,
        Key,
      });

      const s3Object = await this.s3.send(command);

      return {
        body: s3Object.Body as Readable,
        contentLength: s3Object.ContentLength,
        contentType: s3Object.ContentType,
      };
    } catch (caught) {
      throw caught;
    }
  }
  async delete(Key: string): Promise<void> {
    try {
      const command = new DeleteObjectCommand({
        Key,
        Bucket: this.bucketName,
      });
      await this.s3.send(command);

      await waitUntilObjectNotExists(
        {
          client: this.s3,
          maxWaitTime: 60 * 2,
        },
        { Bucket: this.bucketName, Key },
      );

      logger.info(`Object deleted. key: ${Key} - Bucket: ${this.bucketName}`);
    } catch (caught) {
      if (
        caught instanceof S3ServiceException &&
        caught.name === "NoSuchBucket"
      ) {
        logger.error(
          `Error from S3 while deleting from ${this.bucketName}. Bucket not found.`,
        );
      } else if (caught instanceof S3ServiceException) {
        logger.error(
          `Error from S3 while deleting object from ${this.bucketName}. ${caught.name}: ${caught.message}`,
        );
      }
    }
  }
  async exists(Key: string): Promise<boolean> {
    try {
      const command = new HeadObjectCommand({
        Key,
        Bucket: this.bucketName,
      });
      await this.s3.send(command);
      return true;
    } catch (caught) {
      if (caught instanceof S3ServiceException && caught.name === "NotFound") {
        return false;
      } else if (caught instanceof S3ServiceException) {
        logger.error(
          `Error trying to find ${Key} from ${this.bucketName}. ${caught.name}: ${caught.message}`,
        );
      }
      throw caught;
    }
  }
}
