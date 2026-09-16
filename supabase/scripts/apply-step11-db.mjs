import pg from 'pg';
import fs from 'fs';
import path from 'path';

const pool = new pg.Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:Ccm-main123%23%40@127.0.0.1:5432/postgres'
});

const migrationFiles = [
    '059_create_async_jobs.sql',
    '060_create_step11_permissions.sql',
    '061_create_step11_indexes.sql',
    '062_create_step11_rls.sql'
];

async function main() {
    const client = await pool.connect();
    try {
        console.log('Applying Step 11 database migrations...');
        for (const file of migrationFiles) {
            console.log(`Executing ${file}...`);
            const filePath = path.join(process.cwd(), 'supabase', 'migrations', file);
            const sql = fs.readFileSync(filePath, 'utf-8');
            await client.query(sql);

            // Append to schema_all.sql
            const schemaAllPath = path.join(process.cwd(), 'supabase', 'schema_all.sql');
            fs.appendFileSync(schemaAllPath, `\n\n-- ====================================\n-- ${file}\n-- ====================================\n${sql}\n`);
        }
        console.log('✅ All Step 11 database migrations applied successfully!');
    } catch (err) {
        console.error('❌ Failed to apply Step 11 migrations:', err);
        process.exit(1);
    } finally {
        client.release();
        await pool.end();
    }
}

main();
