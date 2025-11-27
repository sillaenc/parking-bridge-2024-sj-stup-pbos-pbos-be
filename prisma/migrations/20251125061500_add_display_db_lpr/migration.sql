-- Add display_db_lpr column for LPR endpoint
ALTER TABLE "tb_db_setting" ADD COLUMN IF NOT EXISTS "display_db_lpr" TEXT;

-- Seed existing setting row with provided LPR address
UPDATE "tb_db_setting"
SET "display_db_lpr" = 'http://pb0007.iptime.org:12332/parking_db'
WHERE "display_db_lpr" IS NULL;
