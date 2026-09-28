import { ScheduleStatus } from "./schedule-status.enum";
import { CreateSchedulingProps, SchedulingProps } from "./scheduling.interface";


export class Scheduling {
  constructor(private readonly props: SchedulingProps) {}

  static create({carrier, dock, licensePlate, files}: CreateSchedulingProps): Scheduling {
    return new Scheduling({
        carrier,
        dock,
        licensePlate,
        date: new Date(),
        status: ScheduleStatus.open,
        files: files ?? []
    })
  }

  static restore(scheduling: SchedulingProps) {
    return new Scheduling(scheduling);
  }

  public assignStatus(status: ScheduleStatus) {
    if(status === this.props.status) {
       throw new ScheduleStatusAlreadyAssignedError()
    }
    
    this.props.status = status;
  }

  public addFile(filename: string) {
    this.props.files.push(filename);
  }
}
