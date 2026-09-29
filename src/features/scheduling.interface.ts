import { ScheduleStatus } from "./schedule-status.enum";

export type SchedulingId = number | string

export interface SchedulingProps {
  id?: SchedulingId;
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