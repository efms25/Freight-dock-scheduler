#!/usr/bin/env -S node
import type { Contract as End } from '../../snapshots/64d0b0b8677ccd3ea9e1dff88c9e9b45edfcaea3f799b183cb7fe8420ee6784e/contract';
import endContract from '../../snapshots/64d0b0b8677ccd3ea9e1dff88c9e9b45edfcaea3f799b183cb7fe8420ee6784e/contract.json' with { type: 'json' };
import {
  Migration,
  MigrationCLI,
  checkExpression,
  col,
  lit,
  primaryKey,
} from '@prisma/orm-postgres/migration';

export default class M extends Migration<never, End> {
  override readonly endContractJson = endContract;

  override get operations() {
    return [
      this.createSchema({ schema: 'public' }),
      this.createTable({
        schema: 'public',
        table: 'Scheduling',
        columns: [
          col('carrier', 'text', { notNull: true, codecRef: { codecId: 'pg/text@1' } }),
          col('date', 'timestamptz', {
            notNull: true,
            codecRef: { codecId: 'pg/timestamptz-temporal@1' },
          }),
          col('dock', 'text', { notNull: true, codecRef: { codecId: 'pg/text@1' } }),
          col('files', 'text[]', {
            notNull: true,
            default: lit([]),
            codecRef: { codecId: 'pg/text@1', many: true },
          }),
          col('id', 'SERIAL', { notNull: true, codecRef: { codecId: 'pg/int4@1' } }),
          col('licensePlate', 'text', { notNull: true, codecRef: { codecId: 'pg/text@1' } }),
          col('status', 'text', {
            notNull: true,
            default: lit('OPEN'),
            codecRef: { codecId: 'pg/text@1' },
          }),
        ],
        constraints: [
          primaryKey(['id']),
          checkExpression(
            'Scheduling_files_elem_not_null_ae5875f6',
            'array_position("files", NULL) IS NULL',
          ),
          checkExpression(
            'Scheduling_status_check_917782b3',
            "\"status\" IN ('SCHEDULED', 'OPEN', 'CLOSED', 'CANCELED', 'DELIVERED')",
          ),
        ],
      }),
    ];
  }
}

MigrationCLI.run(import.meta.url, M);
