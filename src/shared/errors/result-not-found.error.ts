export class ResultNotFoundError extends Error {
    constructor(id: number | string = '', entity = 'entity') {
        super(`Not found result from ${entity}. ${id ? `ID: ${id}` : ''}`)
        this.name = "resultNotFoundError"
    }
}