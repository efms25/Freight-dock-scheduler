import { db } from "../shared/database/db";
import { ResultNotFoundError } from "../shared/errors/result-not-found.error";
import { DatabaseRepository } from "../shared/repository/database-repository.interface";
import { schedulingPayloadToClass } from "./helpers/Scheduling-payload-to-class.helper";
import { Scheduling } from "./scheduling.entity";
import { SchedulingId, SchedulingProps } from "./scheduling.interface";

export class SchedulingRepository implements DatabaseRepository<Scheduling> {
  async findAll(): Promise<Scheduling[]> {
    const schedulingList = await db.orm.public.Scheduling.all();
    return schedulingList.map((scheduling) => {
      return schedulingPayloadToClass(scheduling);
    });
  }
  async findByDate(date: Date): Promise<Scheduling[]> {
    const schedulingList = await db.orm.public.Scheduling.where({ date })
      .orderBy((u) => u.date.desc())
      .all();
    return schedulingList.map((scheduling) => {
      return schedulingPayloadToClass(scheduling);
    });
  }
  async findById(id: SchedulingId): Promise<Scheduling> {
    const numericId = Number(id);

    if (!Number.isInteger(numericId)) {
      throw new SchedulingIdInvalidType(numericId);
    }

    const scheduling = await db.orm.public.Scheduling.where({
      id: numericId,
    }).first();

    if (!scheduling) {
      throw new ResultNotFoundError(id, Scheduling.name);
    }

    return schedulingPayloadToClass(scheduling);
  }
  async create(props: Scheduling): Promise<Scheduling> {
    const schedulingObject = props.toObject();
    const scheduling = await db.orm.public.Scheduling.create({
      carrier: schedulingObject.carrier,
      date: schedulingObject.date,
      dock: schedulingObject.dock,
      licensePlate: schedulingObject.licensePlate,
      status: schedulingObject.status,
      files: schedulingObject.files,
    });

    return schedulingPayloadToClass(scheduling);
  }
  async update(
    _id: SchedulingId,
    props: Partial<SchedulingProps>,
  ): Promise<Scheduling> {
    const numericId = Number(_id);

    if (!Number.isInteger(numericId)) {
      throw new SchedulingIdInvalidType(numericId);
    }

    const { id, ...updateScheduleData } = props;
    const scheduling = await db.orm.public.Scheduling.where({
      id: numericId,
    }).update(updateScheduleData);

    if (!scheduling) {
      throw new ResultNotFoundError(id, Scheduling.name);
    }

    return schedulingPayloadToClass(scheduling);
  }
  async remove(id: SchedulingId): Promise<Scheduling> {
    const numericId = Number(id);

    if (!Number.isInteger(numericId)) {
      throw new SchedulingIdInvalidType(numericId);
    }

    const scheduling = await db.orm.public.Scheduling.where({
      id: numericId,
    }).delete();

    if (!scheduling) {
      throw new ResultNotFoundError(id, Scheduling.name);
    }

    return schedulingPayloadToClass(scheduling);
  }
}
