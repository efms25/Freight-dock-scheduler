import { UploadFileError } from "../shared/errors/upload-file.error";
import { logger } from "../shared/logger";
import { DatabaseRepository } from "../shared/repository/database-repository.interface";
import { FileStorage } from "../shared/storage/file-storage";
import { UploadFile } from "../shared/upload-file.interface";
import { generateSchedulingKey } from "./helpers/storage-key.helper";
import { Scheduling } from "./scheduling.entity";
import {
  CreateSchedulingDto,
  SchedulingId,
  SchedulingProps,
} from "./scheduling.interface";

export class SchedulingService {
  constructor(
    private readonly schedulingRepository: DatabaseRepository<Scheduling>,
    private readonly fileStorage: FileStorage,
  ) {}

  async create(props: CreateSchedulingDto): Promise<Scheduling> {
    const files = props.files;
    let uploadedKeys: string[] = [];

    if (files?.length) {
      try {
        uploadedKeys = await this.loopUploads(files);
      } catch (caught) {
        throw caught;
      }
    }

    try {
      const scheduling = Scheduling.create({
        ...props,
        files: uploadedKeys,
      });

      const resultScheduling =
        await this.schedulingRepository.create(scheduling);

      logger.info(`New scheduling created: ${resultScheduling.toObject()}`);

      return resultScheduling;
    } catch (caught) {
      logger.error(`Error trying to create scheduling. Data: ${props}`);
      if (uploadedKeys.length) {
        this.loopRemoveFile(uploadedKeys);
      }
      throw caught;
    }
  }

  async list(): Promise<Scheduling[]> {
    try {
      return await this.schedulingRepository.findAll();
    } catch (caught) {
      logger.error(`Error trying return scheduling ${caught}`);
      throw new Error(`Error trying return scheduling`);
    }
  }

  async get(id: SchedulingId) {
    try {
      return await this.schedulingRepository.findById(id);
    } catch (caught) {
      logger.error(`Error trying return scheduling with ${id}. ${caught}`);
      throw new Error(`Error trying return scheduling`);
    }
  }

  async findByDate(date: Date): Promise<Scheduling[]> {
    try {
      return await this.schedulingRepository.findByDate(date);
    } catch (caught) {
      logger.error(
        `Error trying return scheduling with date ${date}. ${caught}`,
      );
      throw new Error(`Error trying return scheduling`);
    }
  }

  async update(id: SchedulingId, body: Partial<SchedulingProps>) {
    try {
      const originalScheduling = await this.schedulingRepository.findById(id);
      const updatedScheduling = await this.schedulingRepository.update(
        id,
        body,
      );

      logger.info(
        `Scheduling updated. Original: ${originalScheduling.toObject()}. new: ${updatedScheduling.toObject()}`,
      );

      return updatedScheduling;
    } catch (caught) {
      logger.error(`Error trying to update scheduling ${id}. ${caught}`);
      throw new Error(`Error trying to update scheduling.`);
    }
  }

  async delete(id: SchedulingId) {
    try {
      const deleted = await this.schedulingRepository.remove(id);
      logger.info(`Scheduling deleted. ${deleted}`);
      return deleted;
    } catch (caught) {
      logger.error(`Error trying to remove scheduling ${id}. ${caught}`);
    }
  }

  private async loopUploads(files: UploadFile[]): Promise<string[]> {
    const uploadKeys: string[] = [];

    try {
      for (let file of files) {
        const { Key } = await this.fileStorage.upload({
          Body: file.file,
          Key: generateSchedulingKey(file.filename),
        });
        uploadKeys.push(Key);
      }
      return uploadKeys;
    } catch (caught: any) {
      logger.error(caught);
      throw new UploadFileError();
    }
  }

  private async loopRemoveFile(keys: string[]) {
    try {
      for (let key of keys) {
        await this.fileStorage.delete(key);
      }
    } catch (caught: any) {
      throw caught;
    }
  }
}
