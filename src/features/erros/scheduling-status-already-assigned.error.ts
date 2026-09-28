class ScheduleStatusAlreadyAssignedError extends Error{
    constructor() {
        super(`Status already assigned`);
        this.name = "StatusAlreadyAssignedError";
    }
}