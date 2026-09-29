export interface DatabaseRepository<T> {
    findAll(): Promise<Array<T>>;
    findByDate(date: Date): Promise<Array<T>>;
    findById(id: unknown): Promise<T>;
    create(props: T): Promise<T>;
    update(id: unknown, props: Partial<unknown>): Promise<T>;
    remove(id: unknown): Promise<T>;
}