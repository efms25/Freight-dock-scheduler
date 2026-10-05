import { randomUUID } from "node:crypto";

function generateSchedulingKey(filename: string): string {
    return `uploads/scheduling/${randomUUID()}-${filename}`;
}

export {
    generateSchedulingKey
}