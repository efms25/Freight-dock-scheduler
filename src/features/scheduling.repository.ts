import { db } from "../shared/database/db";
import { DatabaseRepository } from "../shared/repository/database-repository.interface";
import { DeliveryId, SchedulingProps } from "./scheduling.interface";

export class SchedlingRepository implements DatabaseRepository<SchedulingProps> {
    findAll(): Promise<SchedulingProps[]> {
        throw new Error("Method not implemented.");
    }
    findByDate(date: Date): Promise<SchedulingProps[]> {
        throw new Error("Method not implemented.");
    }
    findById(id: DeliveryId): Promise<SchedulingProps> {
        throw new Error("Method not implemented.");
    }
    create(props: SchedulingProps): Promise<SchedulingProps> {
        throw new Error("Method not implemented.");
    }
    update(id: DeliveryId, props: Partial<SchedulingProps>): Promise<SchedulingProps> {
        throw new Error("Method not implemented.");
    }
    remove(id: DeliveryId): Promise<SchedulingProps> {
        throw new Error("Method not implemented.");
    }

}
