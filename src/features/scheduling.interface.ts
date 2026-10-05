import { UploadFile } from "../shared/upload-file.interface";
import { ScheduleStatus } from "./schedule-status.enum";

export type SchedulingId = number | string

export interface SchedulingProps {
  id?: SchedulingId;
  dock: string;
  carrier: string;
  licensePlate: string;
  status: ScheduleStatus;
  date: Date,
  files: string[]
}

export interface CreateSchedulingDto {
  dock: string;
  carrier: string;
  licensePlate: string;
  files?: UploadFile[]
}

export interface CreateSchedulingProps extends Omit<CreateSchedulingDto, "files"> {
  files?: string[]
}