import fs from 'fs';
import path from 'path';
import { parse } from 'csv-parse/sync';
import { stringify } from 'csv-stringify/sync';

export const DB_PATH = path.resolve(__dirname, '../../DB');

// Ensure DB directory exists on module load
if (!fs.existsSync(DB_PATH)) {
  fs.mkdirSync(DB_PATH, { recursive: true });
}

/**
 * Read all records from a CSV file.
 * Returns an empty array if the file does not exist or is empty.
 * Automatically casts numeric and boolean strings to their native types.
 */
export function readAll<T>(filename: string): T[] {
  const filePath = path.join(DB_PATH, filename);
  if (!fs.existsSync(filePath)) return [];

  const content = fs.readFileSync(filePath, 'utf-8').trim();
  if (!content) return [];

  try {
    const rows = parse(content, {
      columns: true,
      skip_empty_lines: true,
      cast: (value: string) => {
        if (value === 'true') return true;
        if (value === 'false') return false;
        if (value !== '' && !isNaN(Number(value))) return Number(value);
        return value;
      },
      cast_date: false,
    });
    return rows as unknown as T[];
  } catch {
    return [];
  }
}

/**
 * Write all records to a CSV file, replacing existing content.
 * When records is empty, preserves the header row to keep schema intact.
 */
export function writeAll<T extends object>(filename: string, records: T[]): void {
  const filePath = path.join(DB_PATH, filename);

  if (records.length === 0) {
    if (fs.existsSync(filePath)) {
      const existing = fs.readFileSync(filePath, 'utf-8');
      const firstLine = existing.split('\n')[0];
      if (firstLine) {
        fs.writeFileSync(filePath, firstLine + '\n', 'utf-8');
        return;
      }
    }
    fs.writeFileSync(filePath, '', 'utf-8');
    return;
  }

  const content = stringify(records as Record<string, unknown>[], {
    header: true,
    cast: {
      boolean: (value: boolean) => (value ? 'true' : 'false'),
    },
  });

  fs.writeFileSync(filePath, content, 'utf-8');
}

/**
 * Find records matching a predicate.
 */
export function findWhere<T>(filename: string, predicate: (row: T) => boolean): T[] {
  return readAll<T>(filename).filter(predicate);
}

/**
 * Find a single record by a predicate.
 */
export function findOne<T>(filename: string, predicate: (row: T) => boolean): T | undefined {
  return readAll<T>(filename).find(predicate);
}

/**
 * Insert a new record at the end of the file.
 */
export function insert<T extends object>(filename: string, record: T): T {
  const records = readAll<T>(filename);
  records.push(record);
  writeAll(filename, records);
  return record;
}

/**
 * Update records matching a predicate, applying a partial update.
 */
export function updateWhere<T extends object>(
  filename: string,
  predicate: (row: T) => boolean,
  updater: (row: T) => T,
): void {
  const records = readAll<T>(filename).map((row) =>
    predicate(row) ? updater(row) : row,
  );
  writeAll(filename, records);
}

/**
 * Delete records matching a predicate.
 */
export function deleteWhere<T extends object>(
  filename: string,
  predicate: (row: T) => boolean,
): void {
  const records = readAll<T>(filename).filter((row) => !predicate(row));
  writeAll(filename, records);
}
