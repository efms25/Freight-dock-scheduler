import { logger } from "../shared/logger";
import { ScheduleStatus } from "./schedule-status.enum";
import { CreateSchedulingProps, SchedulingProps } from "./scheduling.interface";

export class Scheduling {
  constructor(private readonly props: SchedulingProps) {}

  static create({
    carrier,
    dock,
    licensePlate,
    files,
  }: CreateSchedulingProps): Scheduling {
    return new Scheduling({
      carrier,
      dock,
      licensePlate,
      date: new Date(),
      status: ScheduleStatus.open,
      files: files ?? [],
    });
  }

  static restore(scheduling: SchedulingProps): Scheduling {
    return new Scheduling(scheduling);
  }

  public toObject(): SchedulingProps {
    return {
      dock: this.props.dock,
      carrier: this.props.carrier,
      licensePlate: this.props.licensePlate,
      status: this.props.status,
      date: this.props.date,
      files: this.props.files,
    };
  }

  public assignStatus(status: ScheduleStatus) {
    if (status === this.props.status) {
      logger.debug(`Status log already assigned for: ${status} of ${this.props.id} - ${this.props.licensePlate}`)
      throw new ScheduleStatusAlreadyAssignedError();
    }

    this.props.status = status;
  }
  
  public addFile(filename: string) {
    this.props.files.push(filename);
  }
}
