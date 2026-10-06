import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { CreateSchedulingDto, SchedulingProps } from "./scheduling.interface";
import { SchedulingService } from "./scheduling.service";
import { UploadFile } from "../shared/upload-file.interface";

export class SchedulingController {
  constructor(private readonly schedulingService: SchedulingService) {}

  async createScheduling(
    request: FastifyRequest<{ Body: CreateSchedulingDto }>,
    reply: FastifyReply,
  ) {
    try {
      const requestFiles = request.files();
      const { dock, carrier, licensePlate } = request.body;
      const uploadedFiles: UploadFile[] = [];

      for await (const file of requestFiles) {
        uploadedFiles.push({
          file: file.file,
          filename: file.filename,
          mimetype: file.mimetype,
        });
      }

      if (!dock || !carrier || !licensePlate) {
        reply.status(400).send({
          error: "Bad Request",
          message: `The fields dock, carrier and licensePlate are required`,
        });
      }

      const result = await this.schedulingService.create({
        dock,
        carrier,
        licensePlate,
        files: uploadedFiles,
      });

      reply.status(201).send(result);
    } catch (error) {
      request.log.error(error, `Error trying to create error`);
      reply.status(500).send({
        error: "Internal Server Error",
        message: "An error occurred during scheduling creation.",
      });
    }
  }

  async listScheduling(request: FastifyRequest, reply: FastifyReply) {
    try {
      const results = await this.schedulingService.list();

      reply.status(200).send(results);
    } catch (error) {
      request.log.error(error, `Error on fetch scheduling data`);
      reply.status(500).send({
        error: "Internal Server Error",
        message: "An error occurred during scheduling fetching",
      });
    }
  }

  async getScheduling(
    request: FastifyRequest<{ Params: { id: string } }>,
    reply: FastifyReply,
  ) {
    const { id } = request.params;
    try {
      const results = await this.schedulingService.get(id);
      reply.status(200).send(results);
    } catch (error) {
      request.log.error(error, `Error on fetch scheduling data`);
      reply.status(500).send({
        error: "Internal Server Error",
        message: "An error occurred during scheduling fetching",
      });
    }
  }

  async findByDateScheduling(
    request: FastifyRequest<{ Params: { date: Date } }>,
    reply: FastifyReply,
  ) {
    const { date } = request.params;
    try {
      const results = await this.schedulingService.findByDate(date);
      reply.status(200).send(results);
    } catch (error) {
      request.log.error(error, `Error on fetching scheduling by date`);
      reply.status(500).send({
        error: "Internal Server Error",
        message: "An error occurred during scheduling fetching",
      });
    }
  }

  async updateScheduling(
    request: FastifyRequest<{
      Params: { id: string };
      Body: Partial<SchedulingProps>;
    }>,
    reply: FastifyReply,
  ) {
    const { id } = request.params;
    const body = request.body;
    const requestFiles = request.files();
    const uploadedFiles: UploadFile[] = [];

    try {
      for await (const file of requestFiles) {
        uploadedFiles.push({
          file: file.file,
          filename: file.filename,
          mimetype: file.mimetype,
        });
      }

      if (!id) {
        reply.status(400).send({
          error: "Bad Request",
          message: `Id param is required`,
        });
      }

      const result = this.schedulingService.update(id, body);

      request.log.info(`Scheduling with id ${id} updated.`);
      reply.status(200).send(result);
    } catch (error) {
      request.log.error(error, `Error on update scheduling by date`);
      reply.status(500).send({
        error: "Internal Server Error",
        message: "An error occurred during scheduling update",
      });
    }
  }

  async deleteScheduling(
    request: FastifyRequest<{ Params: { id: string } }>,
    reply: FastifyReply,
  ) {
    try {
      const { id } = request.params;
      await this.schedulingService.delete(id);

      reply.status(204).send();
    } catch (error) {
      request.log.error(error, `Error on deleting scheduling`);
      reply.status(500).send({
        error: "Internal Server Error",
        message: "An error on deleting scheduling",
      });
    }
  }

  public register = async (fastifyInstance: FastifyInstance) => {
    fastifyInstance.post("/scheduling", this.createScheduling.bind(this));
    fastifyInstance.get("/scheduling/", this.listScheduling.bind(this));
    fastifyInstance.get("/scheduling/:id", this.getScheduling.bind(this));
    fastifyInstance.get(
      "/scheduling/date/:date",
      this.findByDateScheduling.bind(this),
    );
    fastifyInstance.patch("/scheduling/:id", this.updateScheduling.bind(this));
    fastifyInstance.delete("/scheduling/:id", this.deleteScheduling.bind(this));
  };
}
