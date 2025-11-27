import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // 기본 DB 설정
  await prisma.dbSetting.createMany({
    data: [
      {
        engineDbAddr: 'http://pb0007.iptime.org:12322/parking_db',
        displayDbLpr: 'http://pb0007.iptime.org:12332/parking_db',
      },
    ],
    skipDuplicates: true,
  });

  // 주차 구역 타입 코드 시드
  await prisma.lotType.createMany({
    data: [
      { lotType: 'N', tag: '일반', codeFormat: 'N000', isUsed: true },
      { lotType: 'D', tag: '장애인', codeFormat: 'D000', isUsed: true },
      { lotType: 'M', tag: '유공자', codeFormat: 'M000', isUsed: true },
      { lotType: 'P', tag: '임산부', codeFormat: 'P000', isUsed: true },
      { lotType: 'O', tag: '공용차', codeFormat: 'O000', isUsed: true },
      { lotType: 'G', tag: '관용차', codeFormat: 'G000', isUsed: true },
      { lotType: 'E', tag: '전기차', codeFormat: 'E000', isUsed: true },
      { lotType: 'F', tag: '친환경', codeFormat: 'F000', isUsed: true },
      { lotType: 'L', tag: '경차', codeFormat: 'L000', isUsed: true },
    ],
    skipDuplicates: true,
  });

  // 기본 배경 이미지 크기
  const lotImageCount = await prisma.lotImage.count();
  if (lotImageCount === 0) {
    await prisma.lotImage.create({
      data: {
        xbottomright: 1920,
        ybottomright: 1080,
      },
    });
  }

  // settings 기본 값
  const settingsSeed = [
    { key: 'machine_display', value: '안녕하세요' },
    { key: 'park', value: null },
    { key: 'machine_display_time', value: '{"nightStart":20,"nightEnd":8}' },
    {
      key: 'address',
      value: JSON.stringify({
        graphEndPoint: {
          oneDay: '/statistics/cam_parking_area/oneDay',
          week: '/statistics/cam_parking_area/oneWeek',
          month: '/statistics/cam_parking_area/oneMonth',
          year: '/statistics/cam_parking_area/oneYear',
          search: '/statistics/cam_parking_area/searchDay',
          graphData: '/graphData',
          graphRangeData: '/statistics/cam_parking_area/searchgraph',
        },
        loginEndPoint: {
          login: '/login_setting',
          create: '/create_admin',
          confirm: '/confirm_account_list',
          modifypassword: '/settings/account/changePassword',
          insertUser: '/settings/account/insertUser',
        },
        parkingEndPoint: {
          base: '/login_setting/base',
          area: '/settings/parking_area',
          tag: '/pabi/tag',
          car: '/pabi/car',
        },
        settingEndPoint: {
          list: '/settings/account',
          delete: '/settings/account/deleteUser',
          update: '/settings/account/updateUser',
          reset: '/settings/account/resetPassword',
          postparkData: '/base',
          getparkData: '/base/get',
          postBujeValue: '/setOverride',
          ping: '/ping',
          isalive: '/isalive/isalive',
        },
        displayEndPoint: {
          display: '/display',
          led: '/led_cal',
        },
      }),
    },
  ];

  for (const entry of settingsSeed) {
    await prisma.setting.upsert({
      where: { key: entry.key },
      update: { value: entry.value },
      create: { key: entry.key, value: entry.value },
    });
  }

  console.log('✅ Seed data applied');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
