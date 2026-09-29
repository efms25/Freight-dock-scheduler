import { DeliveryId } from "../../features/scheduling.interface";

export interface DatabaseRepository<T> {
    findAll(): Promise<Array<T>>;
    findByDate(date: Date): Promise<Array<T>>;
    findById(id: DeliveryId): Promise<T>;
    create(props: T): Promise<T>;
    update(id: DeliveryId, props: Partial<T>): Promise<T>;
    remove(id: DeliveryId): Promise<T>;
}