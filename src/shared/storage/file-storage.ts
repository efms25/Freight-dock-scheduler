import { S3PutObjectInput } from "./s3-put-object-input";
import { ObjectResult, S3ObjectOutput } from "./s3-object-output";

export interface FileStorage {
    upload(input: S3PutObjectInput): Promise<S3ObjectOutput>;
    download(key: string): Promise<ObjectResult>;
    delete(key: string): Promise<void>;
    exists(key: string): Promise<boolean>;
}