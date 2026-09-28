import { ScheduleStatus } from "./schedule-status.enum";

export interface SchedulingProps {
  dock: string;
  carrier: string;
  licensePlate: string;
  status: ScheduleStatus;
  date: Date,
  files: Array<string>
}

export interface CreateSchedulingProps {
  dock: string;
  carrier: string;
  licensePlate: string;
  files?: Array<string>
}