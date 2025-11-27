-- CreateTable
CREATE TABLE "tb_users" (
    "uid" SERIAL NOT NULL,
    "account" VARCHAR(30) NOT NULL,
    "passwd" TEXT NOT NULL,
    "username" VARCHAR(50),
    "userlevel" INTEGER NOT NULL,
    "isActivated" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "tb_users_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_parking" (
    "uid" SERIAL NOT NULL,
    "tag" VARCHAR(50),
    "use_tag" BOOLEAN,
    "logo" TEXT,
    "use_logo" BOOLEAN,
    "server_timeout" INTEGER,

    CONSTRAINT "tb_parking_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_lot_type" (
    "uid" SERIAL NOT NULL,
    "lot_type" VARCHAR(30),
    "tag" VARCHAR(30),
    "code_format" VARCHAR(5),
    "isUsed" BOOLEAN,

    CONSTRAINT "tb_lot_type_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_lots_image" (
    "uid" SERIAL NOT NULL,
    "xbottomright" DECIMAL(10,2),
    "ybottomright" DECIMAL(10,2),

    CONSTRAINT "tb_lots_image_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_lot_status" (
    "uid" SERIAL NOT NULL,
    "lot" INTEGER,
    "isParked" BOOLEAN,
    "added" TIMESTAMP(3),

    CONSTRAINT "tb_lot_status_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_db_setting" (
    "uid" SERIAL NOT NULL,
    "engine_db_addr" TEXT,
    "engine_db_id" VARCHAR(20),
    "engine_db_passwd" VARCHAR(20),
    "display_db_addr" TEXT,
    "display_db_id" VARCHAR(20),
    "display_db_passwd" VARCHAR(20),

    CONSTRAINT "tb_db_setting_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_lots" (
    "uid" SERIAL NOT NULL,
    "tag" VARCHAR(10),
    "lot_type" INTEGER,
    "point" VARCHAR(20),
    "parked" BOOLEAN DEFAULT true,
    "isUsed" BOOLEAN DEFAULT false,
    "asset" TEXT,
    "floor" TEXT,
    "plate" TEXT,
    "startTime" TIMESTAMP(3),

    CONSTRAINT "tb_lots_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "processed_db" (
    "uid" SERIAL NOT NULL,
    "lot" INTEGER,
    "car_type" INTEGER,
    "hour_parking" BOOLEAN,
    "recorded_hour" TIMESTAMP(3),

    CONSTRAINT "processed_db_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "perday" (
    "uid" SERIAL NOT NULL,
    "lot" INTEGER,
    "car_type" INTEGER,
    "day_parking" BOOLEAN,
    "recorded_day" TIMESTAMP(3),

    CONSTRAINT "perday_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "permonth" (
    "uid" SERIAL NOT NULL,
    "lot" INTEGER,
    "car_type" INTEGER,
    "month_parking" BOOLEAN,
    "recorded_month" TIMESTAMP(3),

    CONSTRAINT "permonth_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "peryear" (
    "uid" SERIAL NOT NULL,
    "lot" INTEGER,
    "car_type" INTEGER,
    "year_parking" BOOLEAN,
    "recorded_year" TIMESTAMP(3),

    CONSTRAINT "peryear_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_parking_zone" (
    "uid" SERIAL NOT NULL,
    "parking_name" VARCHAR(50) NOT NULL,
    "file_address" TEXT NOT NULL,
    "floor" TEXT,

    CONSTRAINT "tb_parking_zone_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_parking_surface" (
    "uid" SERIAL NOT NULL,
    "tag" VARCHAR(50) NOT NULL,
    "engine_code" VARCHAR(10) NOT NULL,
    "uri" TEXT NOT NULL,

    CONSTRAINT "tb_parking_surface_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "rawdata" (
    "uid" SERIAL NOT NULL,
    "id" INTEGER,
    "timestamp" TIMESTAMP(3),
    "parking_lot" TEXT,

    CONSTRAINT "rawdata_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "multiple_signs" (
    "uid" SERIAL NOT NULL,
    "parking_lot" TEXT NOT NULL,

    CONSTRAINT "multiple_signs_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "base" (
    "uid" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "latitude" VARCHAR(30),
    "longitude" VARCHAR(30),
    "manager" TEXT NOT NULL,
    "phone_number" VARCHAR(30) NOT NULL,

    CONSTRAINT "base_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "settings" (
    "uid" SERIAL NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT,

    CONSTRAINT "settings_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "display" (
    "uid" SERIAL NOT NULL,
    "tag" TEXT NOT NULL,
    "lot_type" INTEGER,
    "point" VARCHAR(20),
    "asset" TEXT,
    "floor" TEXT,

    CONSTRAINT "display_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "ping" (
    "uid" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "isalright" BOOLEAN,

    CONSTRAINT "ping_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_files" (
    "uid" SERIAL NOT NULL,
    "filename" VARCHAR(255) NOT NULL,
    "original_filename" VARCHAR(255),
    "file_path" TEXT NOT NULL,
    "file_type" VARCHAR(10),
    "file_category" VARCHAR(20),
    "file_size" INTEGER,
    "mime_type" VARCHAR(100),
    "description" TEXT,
    "uploaded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "tb_files_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_parking_zone_files" (
    "uid" SERIAL NOT NULL,
    "parking_zone_id" INTEGER NOT NULL,
    "file_id" INTEGER,
    "file_purpose" VARCHAR(50),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tb_parking_zone_files_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "tb_camera" (
    "uid" SERIAL NOT NULL,
    "tag" VARCHAR(50) NOT NULL,
    "camera_name" VARCHAR(100) NOT NULL,
    "image_link" VARCHAR(255),

    CONSTRAINT "tb_camera_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "rtsp_capture" (
    "uid" SERIAL NOT NULL,
    "tag" VARCHAR(50) NOT NULL,
    "rtsp_address" TEXT NOT NULL,
    "last_image_path" TEXT,

    CONSTRAINT "rtsp_capture_pkey" PRIMARY KEY ("uid")
);

-- CreateIndex
CREATE INDEX "tb_users_account_passwd_idx" ON "tb_users"("account", "passwd");

-- CreateIndex
CREATE UNIQUE INDEX "tb_users_account_key" ON "tb_users"("account");

-- CreateIndex
CREATE INDEX "tb_lot_type_lot_type_idx" ON "tb_lot_type"("lot_type");

-- CreateIndex
CREATE INDEX "tb_lot_type_isUsed_idx" ON "tb_lot_type"("isUsed");

-- CreateIndex
CREATE INDEX "tb_lot_status_added_idx" ON "tb_lot_status"("added");

-- CreateIndex
CREATE INDEX "tb_lots_floor_idx" ON "tb_lots"("floor");

-- CreateIndex
CREATE INDEX "tb_lots_tag_idx" ON "tb_lots"("tag");

-- CreateIndex
CREATE INDEX "tb_lots_lot_type_idx" ON "tb_lots"("lot_type");

-- CreateIndex
CREATE UNIQUE INDEX "tb_lots_tag_key" ON "tb_lots"("tag");

-- CreateIndex
CREATE INDEX "processed_db_recorded_hour_idx" ON "processed_db"("recorded_hour");

-- CreateIndex
CREATE INDEX "processed_db_lot_idx" ON "processed_db"("lot");

-- CreateIndex
CREATE INDEX "perday_recorded_day_idx" ON "perday"("recorded_day");

-- CreateIndex
CREATE INDEX "permonth_recorded_month_idx" ON "permonth"("recorded_month");

-- CreateIndex
CREATE INDEX "peryear_recorded_year_idx" ON "peryear"("recorded_year");

-- CreateIndex
CREATE INDEX "tb_parking_zone_parking_name_idx" ON "tb_parking_zone"("parking_name");

-- CreateIndex
CREATE UNIQUE INDEX "tb_parking_zone_parking_name_key" ON "tb_parking_zone"("parking_name");

-- CreateIndex
CREATE UNIQUE INDEX "tb_parking_zone_file_address_key" ON "tb_parking_zone"("file_address");

-- CreateIndex
CREATE INDEX "tb_parking_surface_tag_idx" ON "tb_parking_surface"("tag");

-- CreateIndex
CREATE UNIQUE INDEX "settings_key_key" ON "settings"("key");

-- CreateIndex
CREATE UNIQUE INDEX "display_tag_key" ON "display"("tag");

-- CreateIndex
CREATE UNIQUE INDEX "ping_name_address_key" ON "ping"("name", "address");

-- CreateIndex
CREATE INDEX "tb_files_file_category_idx" ON "tb_files"("file_category");

-- CreateIndex
CREATE INDEX "tb_files_file_type_idx" ON "tb_files"("file_type");

-- CreateIndex
CREATE INDEX "tb_files_filename_idx" ON "tb_files"("filename");

-- CreateIndex
CREATE INDEX "tb_files_is_active_idx" ON "tb_files"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "tb_files_file_path_key" ON "tb_files"("file_path");

-- CreateIndex
CREATE INDEX "tb_parking_zone_files_parking_zone_id_idx" ON "tb_parking_zone_files"("parking_zone_id");

-- CreateIndex
CREATE INDEX "tb_parking_zone_files_file_id_idx" ON "tb_parking_zone_files"("file_id");

-- CreateIndex
CREATE UNIQUE INDEX "tb_parking_zone_files_parking_zone_id_file_id_key" ON "tb_parking_zone_files"("parking_zone_id", "file_id");

-- CreateIndex
CREATE UNIQUE INDEX "tb_camera_tag_key" ON "tb_camera"("tag");

-- CreateIndex
CREATE INDEX "tb_camera_tag_idx" ON "tb_camera"("tag");

-- CreateIndex
CREATE UNIQUE INDEX "rtsp_capture_tag_key" ON "rtsp_capture"("tag");

-- CreateIndex
CREATE INDEX "rtsp_capture_tag_idx" ON "rtsp_capture"("tag");

-- CreateIndex
CREATE INDEX "rtsp_capture_rtsp_address_idx" ON "rtsp_capture"("rtsp_address");

-- AddForeignKey
ALTER TABLE "tb_lot_status" ADD CONSTRAINT "tb_lot_status_lot_fkey" FOREIGN KEY ("lot") REFERENCES "tb_lots"("uid") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tb_lots" ADD CONSTRAINT "tb_lots_lot_type_fkey" FOREIGN KEY ("lot_type") REFERENCES "tb_lot_type"("uid") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "processed_db" ADD CONSTRAINT "processed_db_lot_fkey" FOREIGN KEY ("lot") REFERENCES "tb_lots"("uid") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "perday" ADD CONSTRAINT "perday_lot_fkey" FOREIGN KEY ("lot") REFERENCES "tb_lots"("uid") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "permonth" ADD CONSTRAINT "permonth_lot_fkey" FOREIGN KEY ("lot") REFERENCES "tb_lots"("uid") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "peryear" ADD CONSTRAINT "peryear_lot_fkey" FOREIGN KEY ("lot") REFERENCES "tb_lots"("uid") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tb_parking_zone_files" ADD CONSTRAINT "tb_parking_zone_files_parking_zone_id_fkey" FOREIGN KEY ("parking_zone_id") REFERENCES "tb_parking_zone"("uid") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tb_parking_zone_files" ADD CONSTRAINT "tb_parking_zone_files_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "tb_files"("uid") ON DELETE SET NULL ON UPDATE CASCADE;
