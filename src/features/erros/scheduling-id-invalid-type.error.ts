class SchedulingIdInvalidType extends Error {
  constructor(value: number | string) {
    super(`Id ${value} has an inviled type`);
    this.name = "schedulingIdInvalidType";
  }
}
