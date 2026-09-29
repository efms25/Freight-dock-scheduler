import { ScheduleStatus } from "../schedule-status.enum";
import { Scheduling } from "../scheduling.entity";
import { Models } from "../../shared/database/contract";

export function schedulingPayloadToClass(
  scheduling: Models.public_Scheduling,
): Scheduling {
  return Scheduling.restore({
    id: scheduling.id,
    carrier: scheduling.carrier,
    date: scheduling.date,
    dock: scheduling.dock,
    licensePlate: scheduling.licensePlate,
    files: [...scheduling.files],
    status: scheduling.status as ScheduleStatus,
  });
}
